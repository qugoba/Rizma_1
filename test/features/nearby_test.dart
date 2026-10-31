import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/downloads/blob_store.dart';
import 'package:rizma/features/downloads/download_service.dart';
import 'package:rizma/features/sharing/nearby_protocol.dart';
import 'package:rizma/features/sharing/sharing_service.dart';

import '../helpers/fake_content_server.dart';

List<int> bytesOf(int n, int seed) {
  final r = Random(seed);
  return List.generate(n, (_) => r.nextInt(256));
}

class FakeChannel implements NearbyChannel {
  FakeChannel(this.dir);

  final Directory dir;
  late FakeChannel other;
  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  final _files = StreamController<(int, File)>.broadcast();
  final _progress = StreamController<(int, int, int)>.broadcast();
  static var _pid = 1000;

  bool fileLate = false;

  bool corrupt = false;
  final sentFiles = <String>[];

  static (FakeChannel, FakeChannel) pair(Directory dir) {
    final a = FakeChannel(dir), b = FakeChannel(dir);
    a.other = b;
    b.other = a;
    return (a, b);
  }

  @override
  Stream<Map<String, dynamic>> get messages => _messages.stream;
  @override
  Stream<(int, File)> get files => _files.stream;
  @override
  Stream<(int, int, int)> get progress => _progress.stream;

  @override
  Future<void> sendMessage(Map<String, Object?> message) async {
    final json = jsonDecode(jsonEncode(message)) as Map<String, dynamic>;
    unawaited(Future(() => other._messages.add(json)));
  }

  @override
  Future<int> sendFile(File file) async {
    final pid = _pid++;
    sentFiles.add(file.path);
    final bytes = await file.readAsBytes();
    if (corrupt && bytes.isNotEmpty) bytes[bytes.length ~/ 2] ^= 0xff;
    final copy = File('${dir.path}/in-$pid');
    await copy.writeAsBytes(bytes);
    unawaited(
      Future.delayed(Duration(milliseconds: fileLate ? 30 : 0), () {
        other._progress.add((pid, bytes.length, bytes.length));
        other._files.add((pid, copy));
      }),
    );
    return pid;
  }

  @override
  Future<void> close() async {}
}

void main() {
  late Directory tmp;
  late FakeContentServer server;
  late AppDatabase senderDb, receiverDb;
  late BlobStore senderStore, receiverStore;
  final now = DateTime(2026, 10, 31, 9);
  final video = bytesOf(200000, 2);
  final pdf = bytesOf(9000, 3);

  DownloadService online(AppDatabase db, BlobStore store) => DownloadService(
    db,
    store,
    server.config(),
    client: server.client,
    now: () => now,
    idleTimeout: const Duration(seconds: 2),
  );

  SharingService sharing(AppDatabase db, BlobStore store) => SharingService(
    store: store,
    downloads: online(db, store),
    localDownloads: (source) => DownloadService(
      db,
      store,
      ContentConfig(baseUrl: source.baseUrl, publicKeys: [server.publicKey]),
      client: source.client,
      now: () => now,
      idleTimeout: source.idleTimeout ?? const Duration(seconds: 5),
      localSource: true,
    ),
  );

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('rizma_nearby');
    server = await FakeContentServer.create();
    senderDb = AppDatabase(NativeDatabase.memory());
    receiverDb = AppDatabase(NativeDatabase.memory());
    senderStore = BlobStore(await Directory('${tmp.path}/s').create());
    receiverStore = BlobStore(await Directory('${tmp.path}/r').create());
    await server.publish(5, 1, [
      FakeLesson(
        'math.u1.l1',
        1,
        {
          'lesson.json': utf8.encode(
            jsonEncode({'lessonId': 'math.u1.l1', 'title': 'الأعداد'}),
          ),
        },
        video: video,
        attachments: [pdf],
      ),
    ]);
    final s = online(senderDb, senderStore);
    await s.checkGrade(5, autoVideo: true);
    await s.applySelection({
      'lesson:math.u1.l1',
      'video:math.u1.l1',
      'attachment:math.u1.l1',
    });
    await s.runQueue();
    server.offline = true;
  });

  tearDown(() async {
    await senderDb.close();
    await receiverDb.close();
    await tmp.delete(recursive: true);
  });

  Future<(NearbyShareSession, NearbyClient, FakeChannel)> link() async {
    final (a, b) = FakeChannel.pair(await Directory('${tmp.path}/x').create());
    final session = NearbyShareSession(
      a,
      await sharing(senderDb, senderStore).inventory(),
      senderStore,
      await Directory('${tmp.path}/out').create(),
    );
    return (session, NearbyClient(b), a);
  }

  for (final late in [false, true]) {
    test('بلا إنترنت ولا شبكة: الدرس والفيديو والملخص من الهاتف القريب'
        '${late ? ' (الملف بعد رسالته)' : ''}', () async {
      final (session, client, sender) = await link();
      sender.fileLate = late;
      final source = (await client.connect())!;
      expect(source.grades, {5});
      expect(source.blobs, containsAll([shaOf(video), shaOf(pdf)]));

      final service = sharing(receiverDb, receiverStore);
      final plan = await service.open(source);
      expect(plan.accepted, isTrue);
      expect(
        await service.receive(source, {for (final i in plan.items) i.id}),
        RunResult.done,
      );
      expect(receiverStore.blob(shaOf(video)).readAsBytesSync(), video);
      expect(await receiverDb.contentDao.hasBlob(shaOf(pdf)), isTrue);
      expect((await receiverDb.contentDao.lesson('math.u1.l1'))!.version, 1);
      expect(
        session.sentBytes,
        greaterThanOrEqualTo(video.length + pdf.length),
      );
      await session.close();
    });
  }

  test('ما ليس عند المرسل: 404، ولا يُرسل غير الدروس', () async {
    final (session, client, sender) = await link();
    final res = await client.get(
      NearbyClient.baseUrl.resolve('v1/blobs/${'0' * 64}'),
    );
    expect(res.statusCode, 404);
    final odd = await client.get(
      NearbyClient.baseUrl.resolve('rizma/../../secret'),
    );
    expect(odd.statusCode, 404);
    expect(sender.sentFiles, isEmpty);
    await session.close();
  });

  test('هاتف سيئ يرسل ملفات معدّلة: لا يُقبل منها شيء ولا تُحسب', () async {
    final (session, client, sender) = await link();
    final source = (await client.connect())!;
    final service = sharing(receiverDb, receiverStore);
    await service.open(source);
    sender.corrupt = true;
    await service.receive(source, {'video:math.u1.l1'});
    expect(await receiverDb.contentDao.hasBlob(shaOf(video)), isFalse);
    final d = (await receiverDb.contentDao.watchDownloads().first).single;
    expect(d.failures, 0);
    await session.close();
  });

  test('فهرس معدَّل من الهاتف القريب: لا يُقبل شيء', () async {
    final (session, client, sender) = await link();
    sender.corrupt = true;
    final source = await client.connect();
    if (source != null) {
      final plan = await sharing(receiverDb, receiverStore).open(source);
      expect(plan.accepted, isFalse);
      expect(plan.items, isEmpty);
    }
    expect(await receiverDb.contentDao.manifest(5), isNull);
    await session.close();
  });
}
