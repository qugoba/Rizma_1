import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/db/daos/content_dao.dart';

void main() {
  late AppDatabase db;
  late ContentDao dao;
  final now = DateTime(2026, 10, 26, 9);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.contentDao;
  });

  tearDown(() => db.close());

  Future<void> have(String sha, {BlobKind kind = BlobKind.core}) =>
      dao.completeDownload(sha256: sha, size: 10, kind: kind, now: now);

  Future<void> queue(
    String sha, {
    int priority = 2,
    BlobKind kind = BlobKind.core,
    int size = 100,
    DateTime? at,
  }) => dao.enqueue(
    sha256: sha,
    size: size,
    kind: kind,
    priority: priority,
    now: at ?? now,
  );

  group('الفهارس', () {
    Future<bool> accept(int seq, {String? catalog}) => dao.acceptManifest(
      grade: 5,
      sequence: seq,
      body: '{"sequence":$seq}',
      catalogSha256: catalog,
      now: now,
    );

    test('فهرس رقمه أقل مما عندنا يُرفض ولا يغيّر شيئًا', () async {
      expect(await accept(5), isTrue);
      expect(await accept(4), isFalse);
      expect((await dao.manifest(5))!.sequence, 5);
      expect((await dao.manifest(5))!.body, '{"sequence":5}');
    });

    test(
      'الرقم نفسه مقبول (فحص ثانٍ لم يجد جديدًا)، والأعلى يحل محله',
      () async {
        await accept(5);
        expect(await accept(5), isTrue);
        expect(await accept(6), isTrue);
        expect((await dao.manifest(5))!.sequence, 6);
      },
    );

    test('الكتالوج الجديد ينتظر ملفه، ثم يُفعَّل', () async {
      await accept(1, catalog: 'cat1');
      var m = (await dao.manifest(5))!;
      expect(m.catalogSha256, isNull, reason: 'كتالوج التطبيق ما زال المعروض');
      expect(m.pendingCatalogSha256, 'cat1');

      await dao.activateReady(now);
      expect(
        (await dao.manifest(5))!.catalogSha256,
        isNull,
        reason: 'لم يُنزَّل',
      );

      await have('cat1');
      await dao.activateReady(now);
      m = (await dao.manifest(5))!;
      expect(m.catalogSha256, 'cat1');
      expect(m.pendingCatalogSha256, isNull);

      await accept(2, catalog: 'cat1');
      expect((await dao.manifest(5))!.pendingCatalogSha256, isNull);
    });
  });

  group('نسخ الدروس', () {
    Future<bool> plan(
      int version,
      Map<String, String> files, {
      String? video,
    }) => dao.planLesson(
      lessonId: 'math.u1.l1',
      version: version,
      contentFormat: 1,
      files: files,
      videoSha256: video,
      videoSize: video == null ? null : 17000000,
    );

    test(
      'لا تُفعَّل النسخة حتى تكتمل كل ملفاتها، ثم تُفعَّل دفعة واحدة',
      () async {
        expect(await plan(1, {'lesson.json': 'a', 'img/1.webp': 'b'}), isTrue);
        await have('a');
        expect(await dao.activateReady(now), isEmpty);
        expect((await dao.lesson('math.u1.l1'))!.version, 0);

        await have('b');
        expect(await dao.activateReady(now), ['math.u1.l1']);
        final l = (await dao.lesson('math.u1.l1'))!;
        expect(l.version, 1);
        expect(ContentDao.decodeFiles(l.files), {
          'lesson.json': 'a',
          'img/1.webp': 'b',
        });
        expect(l.pendingVersion, isNull);
        expect(l.installedAt, now);
      },
    );

    test('الفيديو لا يؤخّر تفعيل الدرس', () async {
      await plan(1, {'lesson.json': 'a'}, video: 'v');
      await have('a');
      expect(await dao.activateReady(now), ['math.u1.l1']);
      expect((await dao.lesson('math.u1.l1'))!.videoSha256, 'v');
    });

    test('نسخة مثل المثبّتة أو أقدم لا تُخطَّط', () async {
      await plan(2, {'lesson.json': 'a'});
      await have('a');
      await dao.activateReady(now);
      expect(await plan(2, {'lesson.json': 'x'}), isFalse);
      expect(await plan(1, {'lesson.json': 'y'}), isFalse);
      expect((await dao.lesson('math.u1.l1'))!.pendingVersion, isNull);
    });

    test('نسخة أحدث تحل محل المنتظرة، والمثبّتة تبقى معروضة', () async {
      await plan(1, {'lesson.json': 'a'});
      await have('a');
      await dao.activateReady(now);

      await plan(2, {'lesson.json': 'b'});
      expect(await plan(3, {'lesson.json': 'c'}), isTrue);
      final l = (await dao.lesson('math.u1.l1'))!;
      expect(l.version, 1);
      expect(l.pendingVersion, 3);
      expect(ContentDao.decodeFiles(l.pendingFiles), {'lesson.json': 'c'});
    });

    test('نسيان المثبّت يرجع الدرس لنسخة التطبيق', () async {
      await plan(1, {'lesson.json': 'a'});
      await have('a');
      await dao.activateReady(now);
      await dao.forgetInstalled('math.u1.l1');
      final l = (await dao.lesson('math.u1.l1'))!;
      expect(l.version, 0);
      expect(ContentDao.decodeFiles(l.files), isEmpty);
      expect(await plan(1, {'lesson.json': 'a'}), isTrue);
    });
  });

  group('قائمة التنزيل', () {
    test('الأولوية ثم الأقدم', () async {
      await queue('video', priority: 3, kind: BlobKind.video);
      await queue('late', at: now.add(const Duration(minutes: 1)));
      await queue('early');
      await queue('catalog', priority: 0);
      final order = <String>[];
      for (
        var d = await dao.nextDownload();
        d != null;
        d = await dao.nextDownload()
      ) {
        order.add(d.sha256);
        await have(d.sha256, kind: d.kind);
      }
      expect(order, ['catalog', 'early', 'late', 'video']);
    });

    test('ملف موجود لا يدخل القائمة', () async {
      await have('a');
      await queue('a');
      expect(await dao.nextDownload(), isNull);
    });

    test('إضافته مرة ثانية: الأولوية الأعلى تبقى وما نُزِّل لا يضيع', () async {
      await queue('a', priority: 2);
      await dao.recordProgress('a', 40);
      await queue('a', priority: 1);
      await queue('a', priority: 3);
      final d = (await dao.nextDownload())!;
      expect(d.priority, 1);
      expect(d.received, 40);
    });

    test('الانقطاع يُبقي ما نُزِّل ولا يُحسب فشلًا', () async {
      await queue('a');
      await dao.recordProgress('a', 60);
      await dao.recordInterruption('a', 'timeout');
      final d = (await dao.nextDownload())!;
      expect(d.received, 60);
      expect(d.failures, 0);
      expect(d.lastError, 'timeout');
    });

    test(
      'ملف تالف يبدأ من الصفر، وبعد 3 مرات يتوقف حتى الفهرس التالي',
      () async {
        await queue('a', size: 100);
        for (var i = 1; i <= ContentDao.maxFailures; i++) {
          await dao.recordProgress('a', 100);
          await dao.recordCorrupt('a', 'sha mismatch');
          if (i < ContentDao.maxFailures) {
            final d = (await dao.nextDownload())!;
            expect(d.received, 0);
            expect(d.failures, i);
          }
        }
        expect(await dao.nextDownload(), isNull);
        expect(await dao.pendingBytes(), 0);

        await queue('a');
        expect((await dao.nextDownload())!.failures, 0);
      },
    );

    test('الاكتمال ينقل الملف من القائمة إلى الموجود معًا', () async {
      await queue('a', size: 100);
      await dao.completeDownload(
        sha256: 'a',
        size: 100,
        kind: BlobKind.core,
        now: now,
      );
      expect(await dao.nextDownload(), isNull);
      expect(await dao.hasBlob('a'), isTrue);
    });

    test('ما بقي بالبايت', () async {
      await queue('a', size: 100);
      await queue('b', size: 50);
      await dao.recordProgress('a', 30);
      expect(await dao.pendingBytes(), 120);
    });
  });

  group('التنظيف', () {
    test('ملفات النسخة القديمة تُحذف، والمستعمل يبقى', () async {
      await dao.acceptManifest(
        grade: 5,
        sequence: 1,
        body: '{}',
        catalogSha256: 'cat',
        now: now,
      );
      await dao.planLesson(
        lessonId: 'l1',
        version: 1,
        contentFormat: 1,
        files: {'lesson.json': 'old', 'img/1.webp': 'shared'},
        videoSha256: 'video1',
        videoSize: 10,
      );
      for (final s in ['cat', 'old', 'shared']) {
        await have(s);
      }
      await have('video1', kind: BlobKind.video);
      await have('stray');
      await dao.activateReady(now);

      await dao.planLesson(
        lessonId: 'l1',
        version: 2,
        contentFormat: 1,
        files: {'lesson.json': 'new', 'img/1.webp': 'shared'},
      );
      await have('new');
      expect(
        (await dao.unreferencedBlobs()).map((b) => b.sha256),
        ['stray'],
        reason: 'old ما زالت المثبّتة، وnew المنتظرة',
      );

      await dao.activateReady(now);
      expect(
        (await dao.unreferencedBlobs()).map((b) => b.sha256),
        unorderedEquals(['old', 'video1', 'stray']),
        reason: 'النسخة 2 بلا فيديو؛ الكتالوج والصورة المشتركة مستعملان',
      );
      await dao.removeBlob('old');
      expect(await dao.hasBlob('old'), isFalse);
    });
  });
}
