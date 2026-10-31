import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/db/daos/content_dao.dart';
import 'package:rizma/features/downloads/blob_store.dart';
import 'package:rizma/features/downloads/download_service.dart';
import 'package:rizma/features/sharing/rizma_package.dart';
import 'package:rizma/features/sharing/sharing_service.dart';

import '../helpers/fake_content_server.dart';

List<int> bytesOf(int n, int seed) {
  final r = Random(seed);
  return List.generate(n, (_) => r.nextInt(256));
}

List<int> lessonJson(String id, String title) =>
    utf8.encode(jsonEncode({'lessonId': id, 'title': title}));

class Phone {
  Phone(this.db, this.store);
  final AppDatabase db;
  final BlobStore store;
  ContentDao get dao => db.contentDao;
}

void main() {
  late Directory tmp;
  late FakeContentServer server;
  late Phone sender;
  late Phone receiver;
  final now = DateTime(2026, 10, 30, 9);

  final image = bytesOf(20000, 1);
  final video = bytesOf(60000, 2);
  final pdf = bytesOf(9000, 3);
  FakeLesson math1(int v, {String title = 'الأعداد'}) => FakeLesson(
    'math.u1.l1',
    v,
    {'lesson.json': lessonJson('math.u1.l1', title), 'img/bar.webp': image},
    video: video,
    attachments: [pdf],
  );

  Future<Phone> phone(String name) async {
    final dir = await Directory('${tmp.path}/$name').create();
    return Phone(AppDatabase(NativeDatabase.memory()), BlobStore(dir));
  }

  DownloadService online(Phone p) => DownloadService(
    p.db,
    p.store,
    server.config(),
    client: server.client,
    now: () => now,
    idleTimeout: const Duration(seconds: 2),
  );

  SharingService sharing(Phone p, {List<List<int>>? keys}) => SharingService(
    store: p.store,
    downloads: online(p),
    localDownloads: (source) => DownloadService(
      p.db,
      p.store,
      ContentConfig(
        baseUrl: source.baseUrl,
        publicKeys: keys ?? [server.publicKey],
      ),
      client: source.client,
      now: () => now,
      idleTimeout: const Duration(seconds: 2),
      localSource: true,
    ),
  );

  Future<void> senderDownloadsAll() async {
    await server.publish(5, 1, [math1(1)]);
    final s = online(sender);
    await s.checkGrade(5, autoVideo: true);
    await s.applySelection({
      'lesson:math.u1.l1',
      'video:math.u1.l1',
      'attachment:math.u1.l1',
    });
    expect(await s.runQueue(), RunResult.done);
  }

  Future<File> pack(Set<String> media) async {
    final service = sharing(sender);
    final inv = await service.inventory();
    final entries = service.packEntries(inv, media);
    final out = File('${tmp.path}/out.rizma');
    await service.writePackage(out, entries);
    expect(await out.length(), RizmaPackage.sizeOf(entries));
    return out;
  }

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('rizma_share');
    server = await FakeContentServer.create();
    sender = await phone('sender');
    receiver = await phone('receiver');
  });

  tearDown(() async {
    await sender.db.close();
    await receiver.db.close();
    await tmp.delete(recursive: true);
  });

  test('ما على الهاتف: الفهرس بتوقيعه، والدروس، والفيديو والملخص', () async {
    await senderDownloadsAll();
    final inv = await sharing(sender).inventory();
    expect(inv.manifests.keys, [5]);
    final (body, sig) = inv.manifests[5]!;
    expect(
      await Ed25519().verify(
        body,
        signature: Signature(
          sig,
          publicKey: SimplePublicKey(
            server.publicKey,
            type: KeyPairType.ed25519,
          ),
        ),
      ),
      isTrue,
    );
    expect(inv.core.keys, containsAll([shaOf(image)]));
    expect(inv.media.map((i) => i.id), [
      'video:math.u1.l1',
      'attachment:math.u1.l1',
    ]);
  });

  test('من ملف «رزمة» إلى هاتف بلا إنترنت: الدرس والفيديو المختار', () async {
    await senderDownloadsAll();
    final file = await pack({'video:math.u1.l1'});
    server.offline = true;
    final requestsBefore = server.requests.length;

    final source = LocalSource.package(await PackageReader.open(file));
    expect(source.grades, {5});
    expect(source.blobs, isNot(contains(shaOf(pdf))), reason: 'لم يُختر');

    final service = sharing(receiver);
    final plan = await service.open(source);
    expect(plan.accepted, isTrue);
    expect(
      plan.items.map((i) => i.id),
      unorderedEquals(['lesson:math.u1.l1', 'video:math.u1.l1']),
    );

    expect(
      await service.receive(source, {'lesson:math.u1.l1', 'video:math.u1.l1'}),
      RunResult.done,
    );
    expect((await receiver.dao.lesson('math.u1.l1'))!.version, 1);
    expect(receiver.store.blob(shaOf(video)).readAsBytesSync(), video);
    expect(await receiver.dao.hasBlob(shaOf(pdf)), isFalse);
    expect(server.requests.length, requestsBefore);

    final items = await online(receiver).items();
    expect(
      items.singleWhere((i) => i.id == 'attachment:math.u1.l1').state,
      DownloadItemState.available,
    );
  });

  test('ما لم يُختر من الملف لا يُنزَّل، وما ينتظر الإنترنت لا يُمس', () async {
    await senderDownloadsAll();
    final file = await pack({'video:math.u1.l1', 'attachment:math.u1.l1'});
    final source = LocalSource.package(await PackageReader.open(file));
    final service = sharing(receiver);
    await service.open(source);
    final other = bytesOf(100, 9);
    await receiver.dao.enqueue(
      sha256: shaOf(other),
      size: other.length,
      kind: BlobKind.video,
      priority: 3,
      now: now,
    );

    await service.receive(source, {'attachment:math.u1.l1'});
    expect(await receiver.dao.hasBlob(shaOf(pdf)), isTrue);
    expect(await receiver.dao.hasBlob(shaOf(video)), isFalse);
    final queue = await receiver.dao.watchDownloads().first;
    expect(queue.map((d) => d.sha256), [shaOf(other)]);
  });

  test('ملف معدَّل داخل الرزمة يُرمى ولا يُحسب على الملف', () async {
    await senderDownloadsAll();
    final file = await pack({'video:math.u1.l1'});
    final bytes = await file.readAsBytes();
    bytes[bytes.length - 10] ^= 0xff;
    await file.writeAsBytes(bytes);

    final source = LocalSource.package(await PackageReader.open(file));
    final service = sharing(receiver);
    await service.open(source);
    await service.receive(source, {'video:math.u1.l1'});
    expect(await receiver.dao.hasBlob(shaOf(video)), isFalse);
    final d = (await receiver.dao.watchDownloads().first).single;
    expect(d.failures, 0, reason: 'المصدر المحلي لا يوقف التنزيل من الإنترنت');
    expect(await receiver.store.partLength(shaOf(video)), 0);

    expect(await online(receiver).runQueue(), RunResult.done);
    expect(await receiver.dao.hasBlob(shaOf(video)), isTrue);
  });

  test('توقيع من مفتاح غير مفتاحنا: لا يُقبل شيء', () async {
    await senderDownloadsAll();
    final file = await pack({'video:math.u1.l1'});
    final source = LocalSource.package(await PackageReader.open(file));
    final stranger = await FakeContentServer.create();
    final service = sharing(receiver, keys: [stranger.publicKey]);
    final plan = await service.open(source);
    expect(plan.accepted, isFalse);
    expect(plan.items, isEmpty);
    expect(await receiver.dao.manifest(5), isNull);
  });

  test('فهرس أقدم مما عند المستلم لا يُرجعه، وما يطابق منه يُؤخذ', () async {
    await senderDownloadsAll();
    final file = await pack({'video:math.u1.l1'});

    await server.publish(5, 2, [math1(2, title: 'الأعداد ٢')]);
    await online(receiver).checkGrade(5, autoVideo: false, autoUpdate: false);

    final source = LocalSource.package(await PackageReader.open(file));
    final service = sharing(receiver);
    final plan = await service.open(source);
    expect(plan.accepted, isFalse);
    expect((await receiver.dao.manifest(5))!.sequence, 2);
    expect(plan.items.map((i) => i.id), ['video:math.u1.l1']);
  });

  test('يكمل من حيث توقف: ما نزل من الإنترنت يكمله الملف', () async {
    await senderDownloadsAll();
    final file = await pack({'video:math.u1.l1'});

    await online(receiver).checkGrade(5, autoVideo: true);
    server.cutAfter[shaOf(video)] = 25000;
    await online(receiver).runQueue();
    expect(await receiver.store.partLength(shaOf(video)), 25000);

    final source = LocalSource.package(await PackageReader.open(file));
    final service = sharing(receiver);
    await service.open(source);
    await service.receive(source, {'video:math.u1.l1'});
    expect(receiver.store.blob(shaOf(video)).readAsBytesSync(), video);
  });

  group('قراءة الملف', () {
    test('ملف ليس «رزمة»، أو مقطوع، أو بمسار غريب: يُرفض', () async {
      final notPack = File('${tmp.path}/x.rizma')..writeAsStringSync('hello');
      expect(
        () => PackageReader.open(notPack),
        throwsA(isA<FormatException>()),
      );

      final good = File('${tmp.path}/good.rizma');
      await RizmaPackage.write(good, [
        PackEntry.bytes('v1/blobs/${shaOf(pdf)}', pdf),
      ]);
      final bytes = await good.readAsBytes();
      final cut = File('${tmp.path}/cut.rizma')
        ..writeAsBytesSync(bytes.sublist(0, bytes.length - 5));
      expect(() => PackageReader.open(cut), throwsA(isA<FormatException>()));

      expect(
        () => RizmaPackage.write(File('${tmp.path}/bad.rizma'), [
          PackEntry.bytes('../../etc/passwd', [1]),
        ]),
        throwsArgumentError,
      );
    });

    test('يُقرأ كمخزن: Range يكمل من المنتصف', () async {
      final file = File('${tmp.path}/r.rizma');
      await RizmaPackage.write(file, [
        PackEntry.bytes('v1/blobs/${shaOf(pdf)}', pdf),
        PackEntry.bytes('v1/blobs/${shaOf(image)}', image),
      ]);
      final client = PackageClient(await PackageReader.open(file));
      final full = await client.get(
        PackageClient.baseUrl.resolve('v1/blobs/${shaOf(image)}'),
      );
      expect(full.statusCode, 200);
      expect(full.bodyBytes, image);

      final part = await client.get(
        PackageClient.baseUrl.resolve('v1/blobs/${shaOf(image)}'),
        headers: {'Range': 'bytes=100-'},
      );
      expect(part.statusCode, 206);
      expect(part.headers['content-range'], 'bytes 100-19999/20000');
      expect(part.bodyBytes, image.sublist(100));

      final missing = await client.get(
        PackageClient.baseUrl.resolve('v1/blobs/${'0' * 64}'),
      );
      expect(missing.statusCode, 404);
    });
  });
}
