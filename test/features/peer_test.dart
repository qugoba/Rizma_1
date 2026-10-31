import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/downloads/blob_store.dart';
import 'package:rizma/features/downloads/download_service.dart';
import 'package:rizma/features/sharing/peer.dart';
import 'package:rizma/features/sharing/sharing_service.dart';

import '../helpers/fake_content_server.dart';

List<int> bytesOf(int n, int seed) {
  final r = Random(seed);
  return List.generate(n, (_) => r.nextInt(256));
}

void main() {
  late Directory tmp;
  late FakeContentServer server;
  late AppDatabase senderDb;
  late BlobStore senderStore;
  late AppDatabase receiverDb;
  late BlobStore receiverStore;
  late PeerServer peer;
  final now = DateTime(2026, 10, 30, 9);

  final video = bytesOf(300000, 2);
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
      idleTimeout: const Duration(seconds: 5),
      localSource: true,
    ),
  );

  PeerFinder finder() => PeerFinder(
    port: peer.port,
    addresses: () async => ['127.0.0.9'],
    timeout: const Duration(seconds: 2),
  );

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('rizma_peer');
    server = await FakeContentServer.create();
    senderDb = AppDatabase(NativeDatabase.memory());
    senderStore = BlobStore(await Directory('${tmp.path}/s').create());
    receiverDb = AppDatabase(NativeDatabase.memory());
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

    peer = await PeerServer.start(
      await sharing(senderDb, senderStore).inventory(),
      senderStore,
      port: 0,
      code: '4821',
      address: InternetAddress.loopbackIPv4,
    );
  });

  tearDown(() async {
    await peer.close();
    await senderDb.close();
    await receiverDb.close();
    await tmp.delete(recursive: true);
  });

  test('يجد الهاتف على الشبكة برمزه، ويستلم منه بلا إنترنت', () async {
    final found = await finder().scan().toList();
    expect(found.map((p) => (p.host, p.code)), [('127.0.0.1', '4821')]);

    final source = (await finder().connect(found.single))!;
    expect(source.grades, {5});
    expect(source.blobs, containsAll([shaOf(video), shaOf(pdf)]));

    final service = sharing(receiverDb, receiverStore);
    final plan = await service.open(source);
    expect(plan.accepted, isTrue);
    expect(
      plan.items.map((i) => i.id),
      unorderedEquals([
        'lesson:math.u1.l1',
        'video:math.u1.l1',
        'attachment:math.u1.l1',
      ]),
    );
    expect(
      await service.receive(source, {for (final i in plan.items) i.id}),
      RunResult.done,
    );
    expect(receiverStore.blob(shaOf(video)).readAsBytesSync(), video);
    expect(await receiverDb.contentDao.hasBlob(shaOf(pdf)), isTrue);
    expect((await receiverDb.contentDao.lesson('math.u1.l1'))!.version, 1);
    expect(peer.sentBytes, greaterThanOrEqualTo(video.length + pdf.length));
  });

  test('يكمل من حيث توقف (Range)', () async {
    final base = Uri.parse('http://127.0.0.1:${peer.port}/');
    final res = await http.get(
      base.resolve('v1/blobs/${shaOf(video)}'),
      headers: {'Range': 'bytes=1000-'},
    );
    expect(res.statusCode, 206);
    expect(
      res.headers['content-range'],
      'bytes 1000-${video.length - 1}/${video.length}',
    );
    expect(res.bodyBytes, video.sublist(1000));
  });

  test(
    'لا يقدّم إلا الدروس: لا ملف خارجها، ولا مسار غريب، ولا كتابة',
    () async {
      final base = Uri.parse('http://127.0.0.1:${peer.port}/');
      expect(
        (await http.get(base.resolve('v1/blobs/${'0' * 64}'))).statusCode,
        404,
      );
      expect(
        (await http.get(base.resolve('v1/blobs/..%2F..%2Fsecret'))).statusCode,
        404,
      );
      expect(
        (await http.get(base.resolve('v1/grades/6/manifest.json'))).statusCode,
        404,
      );
      expect((await http.post(base.resolve('rizma/hello'))).statusCode, 405);
    },
  );

  test('عنوان ليس هاتف رزمة: لا يُعرض', () async {
    final other = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    other.listen((r) {
      r.response.write('{"app":"other"}');
      r.response.close();
    });
    addTearDown(other.close);
    final f = PeerFinder(port: other.port, timeout: const Duration(seconds: 2));
    expect(await f.hello('127.0.0.1'), isNull);
  });

  test('عناوين الشبكة: كل عنوان حقيقي، لا الهاتف نفسه ولا «بلا شبكة»', () {
    expect(Peer.isUsable('192.168.43.1'), isTrue);
    expect(Peer.isUsable('10.0.0.7'), isTrue);
    expect(Peer.isUsable('2.2.8.41'), isTrue, reason: 'شبكة مزوّد في غزة');
    expect(Peer.isUsable('127.0.0.1'), isFalse);
    expect(Peer.isUsable('169.254.3.4'), isFalse);
    expect(Peer.isUsable('0.0.0.0'), isFalse);
    expect(Peer.isUsable('fe80::1'), isFalse);
    expect(Peer.isUsable('300.1.1.1'), isFalse);
  });

  test('واجهات الشبكة: الـ Wi-Fi والهوتسبوت أولًا، وبيانات الهاتف مستبعدة', () {
    expect(Peer.interfaceRank('wlan0'), 0);
    expect(Peer.interfaceRank('swlan0'), 0);
    expect(Peer.interfaceRank('ap0'), 0);
    expect(Peer.interfaceRank('p2p-wlan0-0'), 1);
    expect(Peer.interfaceRank('rmnet_data0'), isNull);
    expect(Peer.interfaceRank('ccmni1'), isNull);
    expect(Peer.interfaceRank('tun0'), isNull);
  });

  test('عنوان مكتوب لا يرد: يُعرف السبب ليعرف الطالب ما يفعل', () async {
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = closed.port;
    await closed.close();
    final f = PeerFinder(
      port: port,
      client: IOClient(
        HttpClient()..connectionTimeout = const Duration(seconds: 8),
      ),
      timeout: const Duration(seconds: 10),
    );
    expect(await f.hello('127.0.0.1'), isNull);
    expect(f.lastFailure, PeerFailure.refused);

    final ok = PeerFinder(port: peer.port);
    expect(await ok.hello('127.0.0.1'), isNotNull);
    expect(ok.lastFailure, isNull);

    expect(PeerFailure.of(TimeoutException('x')), PeerFailure.timeout);
    expect(
      PeerFailure.of(const SocketException('Network is unreachable')),
      PeerFailure.unreachable,
    );
  });

  group('عنوان الهاتف من أندرويد', () {
    test('Dart فشل (أندرويد 11+): العنوان من شبكة الـ Wi-Fi', () {
      expect(
        Peer.pickAddresses([
          'wifi|wlan0|192.168.1.23',
          'iface|rmnet_data0|10.71.4.9',
          'iface|wlan0|192.168.1.23',
          'wm|wlan|192.168.1.23',
          'error|dart|SocketException',
        ]),
        ['192.168.1.23'],
      );
    });

    test('هاتف هو الهوتسبوت: عنوانه من واجهة ap0', () {
      expect(
        Peer.pickAddresses([
          'iface|rmnet_data1|10.20.30.40',
          'iface|ap0|192.168.43.1',
        ]),
        ['192.168.43.1'],
      );
    });

    test('الـ Wi-Fi كما يراه أندرويد قبل غيره', () {
      expect(
        Peer.pickAddresses([
          'iface|p2p0|192.168.49.1',
          'wm|wlan|172.20.10.4',
          'wifi|wlan0|172.20.10.4',
          'iface|lo|127.0.0.1',
          'kaputt',
        ]),
        ['172.20.10.4', '192.168.49.1'],
      );
    });

    test('شبكة بعناوين ليست 192.168 (هاتف صاحب المشروع): تُقبل', () {
      expect(
        Peer.pickAddresses([
          'wifi|wlan0|2.2.8.41',
          'iface|wlan0|2.2.8.41',
          'wm|wlan|2.2.8.41',
          'dart|wlan0|2.2.8.41',
        ]),
        ['2.2.8.41'],
      );
    });

    test('لا شيء من أي مصدر: قائمة فارغة لا خطأ', () {
      expect(
        Peer.pickAddresses([
          'error|android|MissingPluginException',
          'error|dart|SocketException',
        ]),
        isEmpty,
      );
    });
  });

  group('عناوين البحث بحسب حجم الشبكة', () {
    test('/24: 253 عنوانًا، والمنتهي بـ .1 أولًا', () {
      final hosts = Peer.hostsAround('192.168.1.23', 24);
      expect(hosts, hasLength(253));
      expect(hosts.first, '192.168.1.1');
      expect(hosts, isNot(contains('192.168.1.23')));
      expect(hosts, isNot(contains('192.168.1.0')));
      expect(hosts, isNot(contains('192.168.1.255')));
    });

    test(
      '/23 (شبكة مزوّد): الجارة 2.2.9.x أيضًا، بعد عناوين الـ /24 نفسها',
      () {
        final hosts = Peer.hostsAround('2.2.8.41', 23);
        expect(hosts, hasLength(509));
        expect(hosts.first, '2.2.8.1');
        expect(hosts, contains('2.2.9.17'));
        expect(hosts.indexOf('2.2.8.200'), lessThan(hosts.indexOf('2.2.9.2')));
      },
    );

    test('شبكة ضخمة أو مجهولة: أول 254 حوله، والباقي يُكتب يدويًا', () {
      expect(Peer.hostsAround('10.5.6.7', 8), hasLength(253));
      expect(Peer.hostsAround('10.5.6.7', null), hasLength(253));
    });

    test('الطول يُقرأ من أسطر أندرويد', () {
      Peer.prefixes.clear();
      expect(Peer.pickAddresses(['wifi|wlan0|2.2.8.41/23']), ['2.2.8.41']);
      expect(Peer.prefixes['2.2.8.41'], 23);
    });
  });
}
