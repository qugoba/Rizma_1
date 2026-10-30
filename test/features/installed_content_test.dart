import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/catalog/catalog_repository.dart';
import 'package:rizma/features/content/content_repository.dart';
import 'package:rizma/features/downloads/blob_store.dart';
import 'package:rizma/features/downloads/download_providers.dart';
import 'package:rizma/features/downloads/download_service.dart';
import 'package:rizma/features/downloads/installed_content.dart';

import '../helpers/fake_content_server.dart';

void main() {
  late AppDatabase db;
  late Directory dir;
  late BlobStore store;
  late FakeContentServer server;
  late DownloadService service;

  final bundledFile = File('assets/content/lessons/math.u1.l1.json');
  final catalogFile = File('assets/content/catalog_grade5.json');

  List<int> lessonWithTitle(String id, String title) {
    final json =
        jsonDecode(bundledFile.readAsStringSync()) as Map<String, dynamic>;
    json['lessonId'] = id;
    ((json['pack'] as List).first as Map<String, dynamic>)['title'] = title;
    return utf8.encode(jsonEncode(json));
  }

  ContentRepository repo() => ContentRepository(
    loadString: (path) async => File(path).readAsString(),
    listAssets: () async => ['assets/content/lessons/math.u1.l1.json'],
    installed: DbInstalledContent(db, () async => store),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('rizma_installed');
    store = BlobStore(dir);
    server = await FakeContentServer.create();
    service = DownloadService(
      db,
      store,
      server.config(),
      client: server.client,
      idleTimeout: const Duration(seconds: 2),
    );
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> publishAndDownload(
    List<FakeLesson> lessons, {
    List<int>? catalog,
  }) async {
    await server.publish(5, 1, lessons, catalog: catalog);
    await service.checkGrade(5, autoVideo: false);
    expect(await service.runQueue(), RunResult.done);
  }

  test('بلا تنزيل: نسخة التطبيق كما اليوم', () async {
    final content = (await repo().load('math.u1.l1'))!;
    expect(content.pages.first.title, 'الدرس الأول: الأعداد');
  });

  test('النسخة المنزَّلة تُقرأ بدل نسخة التطبيق', () async {
    await publishAndDownload([
      FakeLesson('math.u1.l1', 2, {
        'lesson.json': lessonWithTitle('math.u1.l1', 'الأعداد (مُصحَّح)'),
      }),
    ]);
    final r = repo();
    expect(
      (await r.load('math.u1.l1'))!.pages.first.title,
      'الأعداد (مُصحَّح)',
    );
    expect(await r.byteSize('math.u1.l1'), greaterThan(0));
  });

  test('درس جديد غير موجود في التطبيق يظهر ويُفتح', () async {
    await publishAndDownload([
      FakeLesson('math.u2.l2', 1, {
        'lesson.json': lessonWithTitle('math.u2.l2', 'درس جديد'),
      }),
    ]);
    final r = repo();
    expect(
      await r.availableLessonIds(),
      containsAll(['math.u1.l1', 'math.u2.l2']),
    );
    expect((await r.load('math.u2.l2'))!.pages.first.title, 'درس جديد');
  });

  test(
    'ملف منزَّل حُذف من القرص: نسخة التطبيق، ويُعاد تنزيله لاحقًا',
    () async {
      final json = lessonWithTitle('math.u1.l1', 'منزَّل');
      await publishAndDownload([
        FakeLesson('math.u1.l1', 2, {'lesson.json': json}),
      ]);
      await store.deleteBlob(shaOf(json));

      expect(
        (await repo().load('math.u1.l1'))!.pages.first.title,
        'الدرس الأول: الأعداد',
      );
      expect((await db.contentDao.lesson('math.u1.l1'))!.version, 0);

      await server.publish(5, 2, [
        FakeLesson('math.u1.l1', 2, {'lesson.json': json}),
      ]);
      await service.checkGrade(5, autoVideo: false);
      await service.runQueue();
      expect((await repo().load('math.u1.l1'))!.pages.first.title, 'منزَّل');
    },
  );

  test(
    'ملف منزَّل لا يُحلَّل (بصمته صحيحة لكن شكله خاطئ): نسخة التطبيق',
    () async {
      final broken = utf8.encode('{"lessonId": 5}');
      await publishAndDownload([
        FakeLesson('math.u1.l1', 2, {'lesson.json': broken}),
      ]);
      expect(
        (await repo().load('math.u1.l1'))!.pages.first.title,
        'الدرس الأول: الأعداد',
      );
      expect((await db.contentDao.lesson('math.u1.l1'))!.version, 0);
    },
  );

  test('الكتالوج المنزَّل يُقرأ، والتالف يرجع لكتالوج التطبيق', () async {
    final catalog =
        jsonDecode(catalogFile.readAsStringSync()) as Map<String, dynamic>;
    ((catalog['subjects'] as List).first as Map<String, dynamic>)['title'] =
        'الرياضيات (منزَّل)';
    await publishAndDownload([], catalog: utf8.encode(jsonEncode(catalog)));

    final installed = DbInstalledContent(db, () async => store);
    CatalogRepository catalogRepo() => CatalogRepository(
      loadString: (path) async => File(path).readAsString(),
      installed: () => installed.catalog(5),
    );
    expect(
      (await catalogRepo().load()).subjects.first.title,
      'الرياضيات (منزَّل)',
    );

    await store.deleteBlob((await db.contentDao.manifest(5))!.catalogSha256!);
    expect((await catalogRepo().load()).subjects.first.title, 'الرياضيات');
  });

  test('Wi-Fi فقط: بيانات الهاتف لا تنزّل، وبلا اتصال لا شيء', () {
    const wifi = [ConnectivityResult.wifi];
    const mobile = [ConnectivityResult.mobile];
    const none = [ConnectivityResult.none];
    expect(downloadAllowed(wifi, wifiOnly: true), isTrue);
    expect(downloadAllowed(mobile, wifiOnly: true), isFalse);
    expect(downloadAllowed(mobile, wifiOnly: false), isTrue);
    expect(downloadAllowed(none, wifiOnly: false), isFalse);
    expect(downloadAllowed(const [], wifiOnly: false), isFalse);
    expect(
      downloadAllowed(const [ConnectivityResult.ethernet], wifiOnly: true),
      isTrue,
    );
  });
}
