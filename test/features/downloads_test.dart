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
import 'package:rizma/features/downloads/manifest.dart';

import '../helpers/fake_content_server.dart';

List<int> bytesOf(int n, int seed) {
  final r = Random(seed);
  return List.generate(n, (_) => r.nextInt(256));
}

List<int> lessonJson(String id, String title) =>
    utf8.encode(jsonEncode({'lessonId': id, 'title': title}));

void main() {
  late AppDatabase db;
  late Directory dir;
  late BlobStore store;
  late FakeContentServer server;
  late DownloadService service;
  final now = DateTime(2026, 10, 26, 9);

  DownloadService make({
    Future<List<int>?> Function(String, String)? bundled,
    ContentConfig? config,
  }) => DownloadService(
    db,
    store,
    config ?? server.config(),
    client: server.client,
    now: () => now,
    bundledLessonFile: bundled,
    idleTimeout: const Duration(seconds: 2),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dir = await Directory.systemTemp.createTemp('rizma_blobs');
    store = BlobStore(dir);
    server = await FakeContentServer.create();
    service = make();
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  ContentDao dao() => db.contentDao;

  Future<int> installed(String id) async =>
      (await dao().lesson(id))?.version ?? 0;

  Future<String> installedJson(String id) async {
    final l = (await dao().lesson(id))!;
    return store.readString(ContentDao.decodeFiles(l.files)['lesson.json']!);
  }

  final image = bytesOf(30000, 1);
  FakeLesson math1(int v, {String title = 'الأعداد', List<int>? video}) =>
      FakeLesson('math.u1.l1', v, {
        'lesson.json': lessonJson('math.u1.l1', title),
        'img/bar.webp': image,
      }, video: video);

  group('الفهرس', () {
    test('قراءة الفهرس ترفض أي حقل غريب', () {
      final good = {
        'format': 1,
        'grade': 5,
        'sequence': 1,
        'published_at': '2026-10-26T10:00:00Z',
        'lessons': [
          {
            'id': 'math.u1.l1',
            'version': 1,
            'content_format': 1,
            'files': [
              {'path': 'lesson.json', 'sha256': 'a' * 64, 'size': 10},
            ],
          },
        ],
      };
      expect(Manifest.parse(jsonEncode(good)).lessons.single.id, 'math.u1.l1');

      Map<String, Object?> withLesson(Map<String, Object?> change) => {
        ...good,
        'lessons': [
          {
            ...(good['lessons']! as List).single as Map<String, Object?>,
            ...change,
          },
        ],
      };
      for (final (why, bad) in [
        ('شكل أحدث', {...good, 'format': 2}),
        ('صف خارج 1–12', {...good, 'grade': 13}),
        (
          'بصمة قصيرة',
          withLesson({
            'files': [
              {'path': 'lesson.json', 'sha256': 'abc', 'size': 10},
            ],
          }),
        ),
        (
          'مسار يخرج من المجلد',
          withLesson({
            'files': [
              {'path': 'lesson.json', 'sha256': 'a' * 64, 'size': 10},
              {'path': '../evil.json', 'sha256': 'b' * 64, 'size': 10},
            ],
          }),
        ),
        (
          'بلا lesson.json',
          withLesson({
            'files': [
              {'path': 'img/a.webp', 'sha256': 'a' * 64, 'size': 10},
            ],
          }),
        ),
        (
          'حجم أكبر من الحد',
          withLesson({
            'files': [
              {
                'path': 'lesson.json',
                'sha256': 'a' * 64,
                'size': Manifest.maxCoreFileSize + 1,
              },
            ],
          }),
        ),
        ('معرّف درس غريب', withLesson({'id': 'Math U1'})),
      ]) {
        expect(
          () => Manifest.parse(jsonEncode(bad)),
          throwsFormatException,
          reason: why,
        );
      }
      expect(() => Manifest.parse('not json'), throwsFormatException);
    });

    test(
      'توقيع خاطئ أو فهرس معدَّل بعد التوقيع: يُرفض ولا يُحفظ شيء',
      () async {
        await server.publish(5, 1, [math1(1)]);
        final text = await server.publish(5, 1, [math1(1)]);
        server.tamper(
          5,
          utf8.encode(text.replaceAll('"version":1', '"version":9')),
        );
        expect(
          await service.checkGrade(5, autoVideo: false),
          CheckResult.rejected,
        );
        expect(await dao().manifest(5), isNull);

        final other = await Ed25519().newKeyPair();
        await server.sign(5, utf8.encode(text), keyPair: other);
        expect(
          await service.checkGrade(5, autoVideo: false),
          CheckResult.rejected,
          reason: 'موقّع بمفتاح غير مفتاح الفريق',
        );
        expect(await dao().manifest(5), isNull);
      },
    );

    test('المفتاح الثاني مقبول (تغيير المفتاح دون أن تتوقف الهواتف)', () async {
      final oldKey = await Ed25519().newKeyPair();
      final oldPub = (await oldKey.extractPublicKey()).bytes;
      final text = await server.publish(5, 1, [math1(1)]);
      await server.sign(5, utf8.encode(text), keyPair: oldKey);
      service = make(config: server.config(keys: [server.publicKey, oldPub]));
      expect(
        await service.checkGrade(5, autoVideo: false),
        CheckResult.updated,
      );
    });

    test('فهرس أقدم مما عندنا يُرفض', () async {
      await server.publish(5, 2, [math1(1)]);
      expect(
        await service.checkGrade(5, autoVideo: false),
        CheckResult.updated,
      );
      await server.publish(5, 1, [math1(5)]);
      expect(
        await service.checkGrade(5, autoVideo: false),
        CheckResult.rejected,
      );
      expect((await dao().lesson('math.u1.l1'))!.pendingVersion, 1);
    });

    test('لا اتصال، أو لا فهرس للصف بعد', () async {
      server.offline = true;
      expect(
        await service.checkGrade(5, autoVideo: false),
        CheckResult.offline,
      );
      server.offline = false;
      expect(
        await service.checkGrade(7, autoVideo: false),
        CheckResult.unchanged,
      );
    });

    test('درس بصيغة أحدث من التطبيق يبقى على الخادم', () async {
      await server.publish(5, 1, [
        FakeLesson('math.u1.l2', 1, {
          'lesson.json': lessonJson('math.u1.l2', 'x'),
        }, format: 2),
      ]);
      await service.checkGrade(5, autoVideo: false);
      expect(await dao().lesson('math.u1.l2'), isNull);
      expect(await dao().nextDownload(), isNull);
    });
  });

  group('التنزيل', () {
    test('درس جديد: يُنزَّل، تُفحص بصمته، ويُفعَّل', () async {
      await server.publish(5, 1, [math1(1)], catalog: utf8.encode('{"g":5}'));
      expect(
        await service.checkGrade(5, autoVideo: false),
        CheckResult.updated,
      );
      expect(await installed('math.u1.l1'), 0, reason: 'لم يُنزَّل بعد');

      expect(await service.runQueue(), RunResult.done);
      expect(await installed('math.u1.l1'), 1);
      expect(await installedJson('math.u1.l1'), contains('الأعداد'));
      expect(
        (await dao().manifest(5))!.catalogSha256,
        shaOf(utf8.encode('{"g":5}')),
      );
      expect(await dao().nextDownload(), isNull);
    });

    test('انقطاع بنص الملف: يكمل من حيث توقف ولا يُعيد ما نُزِّل', () async {
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      server.cutAfter[shaOf(image)] = 10000;

      expect(await service.runQueue(), RunResult.offline);
      expect(await store.partLength(shaOf(image)), 10000);
      expect(
        await installed('math.u1.l1'),
        0,
        reason: 'الدرس ناقص فلا يُفعَّل',
      );

      expect(await service.runQueue(), RunResult.done);
      expect(await installed('math.u1.l1'), 1);
      expect(server.requests.where((r) => r.$2 != null).map((r) => r.$2), [
        'bytes=10000-',
      ]);
      final json = lessonJson('math.u1.l1', 'الأعداد');
      expect(server.blobBytesSent, image.length + json.length);
    });

    test('خادم يتجاهل Range: يبدأ من الصفر وينجح', () async {
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      server.cutAfter[shaOf(image)] = 10000;
      await service.runQueue();
      server.ignoreRange = true;
      expect(await service.runQueue(), RunResult.done);
      expect(await installed('math.u1.l1'), 1);
    });

    test('ملف تالف على الخادم: لا يُفعَّل، ويتوقف بعد 3 محاولات', () async {
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      final bad = List<int>.of(image)..[0] ^= 0xff;
      server.corrupt[shaOf(image)] = bad;

      expect(await service.runQueue(), RunResult.done);
      expect(await installed('math.u1.l1'), 0);
      expect(await dao().nextDownload(), isNull);
      final queued = (await dao().watchDownloads().first).single;
      expect(queued.failures, ContentDao.maxFailures);
      expect(await store.hasBlob(shaOf(image)), isFalse);
      expect(await store.partLength(shaOf(image)), 0);
    });

    test('ملف أكبر من حجمه في الفهرس يُقطع ويُرفض', () async {
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      server.corrupt[shaOf(image)] = [...image, ...bytesOf(5000, 2)];
      await service.runQueue();
      expect(await installed('math.u1.l1'), 0);
      expect(
        (await dao().watchDownloads().first).single.lastError,
        contains('larger'),
      );
    });

    test('ما في التطبيق ومطابق للبصمة يُنسخ بدل تنزيله', () async {
      final json = lessonJson('math.u1.l1', 'الأعداد');
      service = make(
        bundled: (id, path) async => path == 'lesson.json' ? json : null,
      );
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      await service.runQueue();
      expect(await installed('math.u1.l1'), 1);
      expect(server.blobBytesSent, image.length, reason: 'الصورة فقط نُزِّلت');
    });

    test('نسخة في التطبيق تختلف عن الفهرس: تُنزَّل الجديدة', () async {
      service = make(
        bundled: (id, path) async => lessonJson('math.u1.l1', 'قديم'),
      );
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      await service.runQueue();
      expect(await installedJson('math.u1.l1'), contains('الأعداد'));
    });

    test('التوقف عند الطلب (خرج من Wi-Fi)', () async {
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      var allowed = 1;
      expect(
        await service.runQueue(mayContinue: () => allowed-- > 0),
        RunResult.stopped,
      );
      expect(await installed('math.u1.l1'), 0);
    });
  });

  group('التحديث والتنظيف', () {
    test('نسخة 2: الصورة المشتركة لا تُنزَّل ثانية، والقديم يُنظَّف', () async {
      await server.publish(5, 1, [math1(1)]);
      await service.checkGrade(5, autoVideo: false);
      await service.runQueue();
      final oldJson = shaOf(lessonJson('math.u1.l1', 'الأعداد'));
      final sentBefore = server.blobBytesSent;

      await server.publish(5, 2, [math1(2, title: 'الأعداد الكبيرة')]);
      expect(
        await service.checkGrade(5, autoVideo: false),
        CheckResult.updated,
      );
      expect(
        await installedJson('math.u1.l1'),
        contains('الأعداد'),
        reason: 'القديمة تبقى معروضة حتى تكتمل الجديدة',
      );
      await service.runQueue();

      expect(await installed('math.u1.l1'), 2);
      expect(await installedJson('math.u1.l1'), contains('الكبيرة'));
      expect(
        server.blobBytesSent - sentBefore,
        lessonJson('math.u1.l1', 'الأعداد الكبيرة').length,
      );
      expect(await store.hasBlob(oldJson), isFalse, reason: 'نُظِّف');
      expect(await dao().hasBlob(oldJson), isFalse);
      expect(await store.hasBlob(shaOf(image)), isTrue);
    });

    test(
      'الفيديو: تلقائيًا إن فُعِّل، أو بطلب الطالب، ويُحذف لتوفير المساحة',
      () async {
        final video = bytesOf(50000, 3);
        await server.publish(5, 1, [math1(1, video: video)]);

        await service.checkGrade(5, autoVideo: false);
        await service.runQueue();
        expect(await installed('math.u1.l1'), 1);
        expect(await store.hasBlob(shaOf(video)), isFalse);

        expect(await service.requestVideo('math.u1.l1'), isTrue);
        await service.runQueue();
        expect(await store.hasBlob(shaOf(video)), isTrue);
        expect(await installed('math.u1.l1'), 1);

        await service.removeVideo('math.u1.l1');
        expect(await store.hasBlob(shaOf(video)), isFalse);
        expect(await dao().hasBlob(shaOf(video)), isFalse);
        expect(await installed('math.u1.l1'), 1, reason: 'نص الدرس باقٍ');

        await service.checkGrade(5, autoVideo: true);
        final queued = (await dao().watchDownloads().first).single;
        expect(queued.kind, BlobKind.video);
        expect(queued.priority, DownloadService.videoPriority);
      },
    );

    test('بقايا ملف جزئي لم يعد في القائمة تُحذف', () async {
      final sink = await store.openPart('f' * 64, append: false);
      sink.add([1, 2, 3]);
      await sink.close();
      await service.collectGarbage();
      expect(await store.partLength('f' * 64), 0);
    });
  });

  group('اختيار ما يُنزَّل', () {
    final video = bytesOf(40000, 7);
    FakeLesson math2() => FakeLesson('math.u1.l2', 1, {
      'lesson.json': lessonJson('math.u1.l2', 'مقارنة'),
      'img/bar.webp': image,
    });

    test(
      '«تحديث الدروس تلقائيًا» مطفأ: لا شيء يُنزَّل حتى يختار الطالب',
      () async {
        await server.publish(5, 1, [math1(1, video: video), math2()]);
        expect(
          await service.checkGrade(5, autoVideo: false, autoUpdate: false),
          CheckResult.updated,
        );
        expect(await dao().nextDownload(), isNull);

        final items = await service.items();
        expect(
          items.map((i) => i.id),
          unorderedEquals([
            'lesson:math.u1.l1',
            'video:math.u1.l1',
            'lesson:math.u1.l2',
          ]),
        );
        final lesson = items.firstWhere((i) => i.id == 'lesson:math.u1.l1');
        expect(lesson.isNew, isTrue);
        expect(lesson.state, DownloadItemState.available);
        expect(
          lesson.size,
          lessonJson('math.u1.l1', 'الأعداد').length + image.length,
        );

        await service.applySelection({'lesson:math.u1.l1'});
        await service.runQueue();
        expect(await installed('math.u1.l1'), 1);
        expect(await installed('math.u1.l2'), 0, reason: 'لم يُختر');
        final after = await service.items();
        expect(after.any((i) => i.id == 'lesson:math.u1.l1'), isFalse);
        expect(
          after.firstWhere((i) => i.id == 'video:math.u1.l1').state,
          DownloadItemState.available,
        );
      },
    );

    test('إلغاء اختيار ما في القائمة يخرجه منها ويحذف ما نُزِّل منه', () async {
      await server.publish(5, 1, [math1(1, video: video)]);
      await service.checkGrade(5, autoVideo: true);
      server.cutAfter[shaOf(video)] = 8000;
      await service.runQueue();
      expect(await store.partLength(shaOf(video)), 8000);
      expect(
        (await service.items())
            .firstWhere((i) => i.id == 'video:math.u1.l1')
            .state,
        DownloadItemState.queued,
      );

      await service.applySelection({});
      expect(await dao().nextDownload(), isNull);
      expect(await store.partLength(shaOf(video)), 0);
    });

    test('ملف يشترك فيه درسان يبقى ما دام أحدهما مختارًا', () async {
      await server.publish(5, 1, [math1(1), math2()]);
      await service.checkGrade(5, autoVideo: false, autoUpdate: false);
      await service.applySelection({'lesson:math.u1.l2'});
      final queued = {
        for (final d in await dao().watchDownloads().first) d.sha256,
      };
      expect(queued, contains(shaOf(image)));
      expect(
        queued,
        isNot(contains(shaOf(lessonJson('math.u1.l1', 'الأعداد')))),
      );
    });

    test('التقدّم يصل مع كل قطعة حتى نهاية الملف', () async {
      await server.publish(5, 1, [math1(1, video: video)]);
      await service.checkGrade(5, autoVideo: false, autoUpdate: false);
      await service.applySelection({'video:math.u1.l1'});
      final seen = <DownloadProgress>[];
      await service.runQueue(onProgress: seen.add);
      expect(seen, isNotEmpty);
      expect(seen.every((p) => p.sha256 == shaOf(video)), isTrue);
      final received = seen.map((p) => p.received).toList();
      expect(received, orderedEquals([...received]..sort()));
      expect(received.last, video.length);
      expect(seen.first.size, video.length);
    });
  });

  group('ملفات الدرس المرفقة', () {
    final pdf = bytesOf(12000, 9);
    final pdf2 = bytesOf(5000, 10);
    FakeLesson withFiles({List<List<int>>? files}) => FakeLesson(
      'math.u1.l1',
      1,
      {'lesson.json': lessonJson('math.u1.l1', 'الأعداد')},
      attachments: files ?? [pdf, pdf2],
    );

    test('الفهرس يقرأ المرفقات، ويرفض ملفًا أكبر من الحد', () async {
      final text = await server.publish(5, 1, [withFiles()]);
      final lesson = Manifest.parse(text).lessons.single;
      expect(lesson.attachmentSizes, {
        shaOf(pdf): pdf.length,
        shaOf(pdf2): pdf2.length,
      });

      final json = jsonDecode(text) as Map<String, dynamic>;
      ((json['lessons'] as List).single as Map)['attachments'] = [
        {'sha256': shaOf(pdf), 'size': Manifest.maxAttachmentSize + 1},
      ];
      expect(
        () => Manifest.parse(jsonEncode(json)),
        throwsA(isA<FormatException>()),
      );
    });

    test('لا تُنزَّل وحدها: تنتظر اختيار الطالب، ثم تُنزَّل وتُفحص', () async {
      await server.publish(5, 1, [withFiles()]);
      await service.checkGrade(5, autoVideo: true);
      await service.runQueue();
      expect(await installed('math.u1.l1'), 1, reason: 'الدرس نفسه نزل');
      expect(await dao().hasBlob(shaOf(pdf)), isFalse);
      expect(
        ContentDao.decodeSizes((await dao().lesson('math.u1.l1'))!.attachments),
        {shaOf(pdf): pdf.length, shaOf(pdf2): pdf2.length},
      );

      final item = (await service.items()).singleWhere(
        (i) => i.kind == DownloadItemKind.attachment,
      );
      expect(item.id, 'attachment:math.u1.l1');
      expect(item.size, pdf.length + pdf2.length);
      expect(item.state, DownloadItemState.available);

      expect(await service.requestAttachment('math.u1.l1', shaOf(pdf)), isTrue);
      final queued = (await dao().watchDownloads().first).single;
      expect(queued.kind, BlobKind.attachment);
      expect(queued.priority, DownloadService.attachmentPriority);
      await service.runQueue();
      expect(store.blob(shaOf(pdf)).readAsBytesSync(), pdf);
      expect(
        (await service.items())
            .singleWhere((i) => i.kind == DownloadItemKind.attachment)
            .state,
        DownloadItemState.available,
        reason: 'الملف الثاني لم يُطلب بعد',
      );

      await service.applySelection({'attachment:math.u1.l1'});
      await service.runQueue();
      expect(await dao().hasBlob(shaOf(pdf2)), isTrue);
    });

    test('ملف غير موجود في الفهرس لا يُطلب', () async {
      await server.publish(5, 1, [withFiles()]);
      await service.checkGrade(5, autoVideo: false);
      expect(
        await service.requestAttachment('math.u1.l1', shaOf(bytesOf(10, 99))),
        isFalse,
      );
      expect(
        await service.requestAttachment('math.u9.l9', shaOf(pdf)),
        isFalse,
      );
    });

    test(
      'الحذف يوفّر المساحة، والتنظيف لا يمسّ مرفقًا ما زال في الدرس',
      () async {
        await server.publish(5, 1, [withFiles()]);
        await service.checkGrade(5, autoVideo: false);
        await service.applySelection({'attachment:math.u1.l1'});
        await service.runQueue();
        expect(
          (await dao().unreferencedBlobs()).map((b) => b.sha256),
          isNot(contains(shaOf(pdf))),
        );

        await service.removeAttachment(shaOf(pdf));
        expect(await dao().hasBlob(shaOf(pdf)), isFalse);
        expect(store.blob(shaOf(pdf)).existsSync(), isFalse);
        expect(await dao().hasBlob(shaOf(pdf2)), isTrue);

        await server.publish(5, 2, [
          FakeLesson(
            'math.u1.l1',
            2,
            {'lesson.json': lessonJson('math.u1.l1', 'الأعداد ٢')},
            attachments: [pdf],
          ),
        ]);
        await service.checkGrade(5, autoVideo: false);
        await service.runQueue();
        expect(await installed('math.u1.l1'), 2);
        expect(await dao().hasBlob(shaOf(pdf2)), isFalse);
      },
    );
  });
}
