import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar_learning.dart';
import 'package:rizma/core/strings/ar_progress.dart';
import 'package:rizma/features/account/downloads_providers.dart';
import 'package:rizma/features/downloads/download_providers.dart';
import 'package:rizma/features/downloads/download_service.dart';
import 'package:rizma/features/learning/attachment_screen.dart';
import 'package:rizma/features/learning/widgets/lesson_video_area.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

import '../helpers/app_harness.dart';
import '../helpers/load_fonts.dart';

class FakeDownloadController extends DownloadController {
  FakeDownloadController([this.initial = const DownloadStatus()]);

  final DownloadStatus initial;
  final calls = <String>[];

  @override
  DownloadStatus build() => initial;

  @override
  Future<void> applySelection(
    Set<String> itemIds, {
    bool allowMobile = false,
  }) async => calls.add('select:${(itemIds.toList()..sort()).join(',')}');

  @override
  bool get available => true;

  @override
  Future<void> refresh({bool force = false}) async =>
      calls.add('refresh:$force');

  @override
  Future<void> runNow({bool allowMobile = false}) async =>
      calls.add('run:$allowMobile');

  @override
  Future<void> requestVideo(String lessonId) async =>
      calls.add('video:$lessonId');

  @override
  Future<void> removeVideo(String lessonId) async =>
      calls.add('remove:$lessonId');

  @override
  Future<void> requestAttachment(String lessonId, String sha256) async =>
      calls.add('file:$lessonId:$sha256');

  @override
  Future<void> removeAttachment(String sha256) async =>
      calls.add('removeFile:$sha256');
}

void main() {
  setUpAll(loadCairoFont);

  final now = DateTime(2026, 10, 27, 9);
  const videoSha =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
  const videoSize = 17 * 1024 * 1024;

  Future<void> seed(ProfileRepository repo) =>
      repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);

  Future<void> open(WidgetTester tester, String location) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RizmaApp)),
    );
    container.read(routerProvider).push(location);
    await tester.pumpAndSettle();
  }

  Future<void> lessonWithVideo(
    WidgetTester tester,
    AppDatabase db,
    String id,
  ) => onDb(
    tester,
    () => db
        .into(db.contentLessons)
        .insert(
          ContentLessonsCompanion.insert(
            lessonId: id,
            version: const Value(1),
            videoSha256: const Value(videoSha),
            videoSize: const Value(videoSize),
          ),
        ),
  );

  Future<void> queue(
    WidgetTester tester,
    AppDatabase db,
    String sha,
    int size, {
    int received = 0,
    BlobKind kind = BlobKind.core,
  }) => onDb(
    tester,
    () => db
        .into(db.contentDownloads)
        .insert(
          ContentDownloadsCompanion.insert(
            sha256: sha,
            size: size,
            kind: kind,
            priority: 2,
            received: Value(received),
            createdAt: now,
          ),
        ),
  );

  Future<void> run(
    WidgetTester tester,
    FakeDownloadController fake,
    List<ConnectivityResult> network,
    Future<void> Function(AppDatabase db) body, {
    bool store = false,
    List<DownloadItem>? items,
    List<Override> extra = const [],
  }) => scenario(
    tester,
    seed: seed,
    overrides: [
      downloadControllerProvider.overrideWith(() => fake),
      networkProvider.overrideWith((ref) => Stream.value(network)),
      if (items != null) downloadItemsProvider.overrideWith((ref) => items),
      ...extra,
      if (store)
        contentConfigProvider.overrideWithValue(
          ContentConfig(
            baseUrl: Uri.parse('https://content.test/'),
            publicKeys: const [],
          ),
        ),
    ],
    body,
  );

  const wifi = [ConnectivityResult.wifi];
  const mobile = [ConnectivityResult.mobile];
  const none = [ConnectivityResult.none];

  testWidgets('التنزيل مضبوط: التطبيق يفحص التحديثات عند فتحه', (tester) {
    final fake = FakeDownloadController();
    return run(tester, fake, wifi, (db) async {
      expect(fake.calls, contains('refresh:false'));
    });
  });

  testWidgets(
    'لا شيء ينتظر: «كل الدروس محدّثة»، و«ابحث عن تحديثات» يفحص الآن',
    (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await open(tester, '/account/downloads');
        expect(find.text(ArProgress.updatesTitle), findsOneWidget);
        expect(find.text(ArProgress.updatesNone), findsOneWidget);
        expect(find.text(ArProgress.installedNoteDownloads), findsOneWidget);

        await tester.tap(find.text(ArProgress.updatesCheck));
        await tester.pumpAndSettle();
        expect(fake.calls, contains('refresh:true'));
      });
    },
  );

  testWidgets('على بيانات الهاتف مع «Wi-Fi فقط»: ينتظر، و«نزّل الآن» بحجمه', (
    tester,
  ) {
    final fake = FakeDownloadController();
    return run(tester, fake, mobile, (db) async {
      await queue(tester, db, 'b' * 64, 3 * 1024 * 1024, received: 1024 * 1024);
      await open(tester, '/account/downloads');
      expect(find.text(ArProgress.updatesWaitingWifi), findsOneWidget);
      final button = find.text(
        ArProgress.updatesDownloadNow(formatBytes(2 * 1024 * 1024)),
      );
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(fake.calls, contains('run:true'));
    });
  });

  testWidgets('على Wi-Fi: ما ينتظر بحجمه، و«نزّل الآن» دون استثناء', (tester) {
    final fake = FakeDownloadController();
    return run(tester, fake, wifi, (db) async {
      await queue(tester, db, 'c' * 64, 1024 * 1024);
      await open(tester, '/account/downloads');
      expect(
        find.text(ArProgress.updatesPending(formatBytes(1024 * 1024))),
        findsOneWidget,
      );
      await tester.tap(
        find.text(ArProgress.updatesDownloadNow(formatBytes(1024 * 1024))),
      );
      await tester.pumpAndSettle();
      expect(fake.calls, contains('run:false'));
    });
  });

  testWidgets('بلا اتصال: يقول إنه يكمل حين يعود، بلا زر', (tester) {
    final fake = FakeDownloadController();
    return run(tester, fake, none, (db) async {
      await queue(tester, db, 'd' * 64, 1024 * 1024);
      await open(tester, '/account/downloads');
      expect(find.textContaining(ArProgress.updatesOffline), findsOneWidget);
      expect(find.byType(TextButton), findsWidgets);
      expect(find.textContaining('نزّل الآن'), findsNothing);
    });
  });

  testWidgets('ملفات توقفت لتلفها تُذكر بعددها', (tester) {
    final fake = FakeDownloadController();
    return run(tester, fake, wifi, (db) async {
      await queue(tester, db, 'e' * 64, 100);
      await onDb(tester, () async {
        for (var i = 0; i < 3; i++) {
          await db.contentDao.recordCorrupt('e' * 64, 'sha256 mismatch');
        }
      });
      await open(tester, '/account/downloads');
      expect(find.text(ArProgress.updatesFailed(1)), findsOneWidget);
      expect(find.text(ArProgress.updatesNone), findsOneWidget);
    });
  });

  group('سطر الفيديو', () {
    final size = ArProgress.videoRowSize(formatBytes(videoSize));

    testWidgets('غير منزَّل: حجمه وزر تنزيل', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithVideo(tester, db, 'math.u1.l1');
        await open(tester, '/account/downloads');
        await tester.ensureVisible(find.text(size));
        await tester.tap(find.text(ArProgress.videoRowDownload));
        await tester.pumpAndSettle();
        expect(fake.calls, contains('video:math.u1.l1'));
      });
    });

    testWidgets('يُنزَّل: نسبته', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithVideo(tester, db, 'math.u1.l1');
        await queue(
          tester,
          db,
          videoSha,
          videoSize,
          received: videoSize ~/ 4,
          kind: BlobKind.video,
        );
        await open(tester, '/account/downloads');
        final queued = find.text(ArProgress.videoRowQueued(25));
        await tester.ensureVisible(queued);
        expect(queued, findsOneWidget);
        expect(find.text(ArProgress.videoRowDownload), findsNothing);
      });
    });

    testWidgets('على الهاتف: حجمه وزر حذف', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithVideo(tester, db, 'math.u1.l1');
        await onDb(
          tester,
          () => db
              .into(db.contentBlobs)
              .insert(
                ContentBlobsCompanion.insert(
                  sha256: videoSha,
                  size: videoSize,
                  kind: BlobKind.video,
                  verifiedAt: now,
                ),
              ),
        );
        await open(tester, '/account/downloads');
        await tester.ensureVisible(find.text(size));
        await tester.tap(find.text(ArProgress.videoRowRemove));
        await tester.pumpAndSettle();
        expect(fake.calls, contains('remove:math.u1.l1'));
      });
    });
  });

  testWidgets('بلا تنزيل مضبوط: الشاشة كما كانت', (tester) {
    return scenario(tester, seed: seed, (db) async {
      await open(tester, '/account/downloads');
      expect(find.text(ArProgress.updatesTitle), findsNothing);
      expect(find.text(ArProgress.installedNote), findsOneWidget);
    });
  });

  group('اختر ما تنزّله', () {
    const mb = 1024 * 1024;
    final items = [
      DownloadItem.test(
        lessonId: 'math.u1.l2',
        kind: DownloadItemKind.lesson,
        blobs: {'a' * 64: 40 * 1024},
        isNew: true,
      ),
      DownloadItem.test(
        lessonId: 'english.u1.l1',
        kind: DownloadItemKind.video,
        blobs: {'b' * 64: 30 * mb},
        state: DownloadItemState.queued,
        received: 15 * mb,
      ),
      DownloadItem.test(
        lessonId: 'math.u3.l3',
        kind: DownloadItemKind.video,
        blobs: {'c' * 64: 10 * mb},
      ),
      DownloadItem.test(
        lessonId: 'math.u1.l1',
        kind: DownloadItemKind.video,
        blobs: {'d' * 64: 5 * mb},
        state: DownloadItemState.onPhone,
      ),
    ];

    testWidgets('ملفات الدروس قسم وحدها، بعددها وحجمها', (tester) {
      final fake = FakeDownloadController();
      final withFiles = [
        ...items,
        DownloadItem.test(
          lessonId: 'english.u1.l1',
          kind: DownloadItemKind.attachment,
          blobs: {'e' * 64: 300 * 1024, 'f' * 64: 200 * 1024},
        ),
      ];
      return run(tester, fake, wifi, items: withFiles, (db) async {
        await open(tester, '/account/downloads/choose');
        final section = find.text(ArProgress.chooseFiles);
        await tester.ensureVisible(section);
        expect(section, findsOneWidget);
        expect(
          find.textContaining(ArProgress.chooseFilesCount(2)),
          findsOneWidget,
        );
        await tester.tap(find.textContaining(ArProgress.chooseFilesCount(2)));
        await tester.pumpAndSettle();
        final button = find.text(
          ArProgress.chooseDownload(formatBytes(15 * mb + 500 * 1024)),
        );
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(
          fake.calls,
          contains('select:attachment:english.u1.l1,video:english.u1.l1'),
        );
      });
    });

    testWidgets('العناصر بأحجامها، وما في القائمة مختار، والمجموع يتغيّر', (
      tester,
    ) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, items: items, (db) async {
        await open(tester, '/account/downloads/choose');
        expect(find.text(ArProgress.chooseLessons), findsOneWidget);
        expect(find.text(ArProgress.chooseVideos), findsOneWidget);
        expect(find.textContaining(ArProgress.chooseNew), findsOneWidget);
        expect(find.textContaining(ArProgress.chooseOnPhone), findsOneWidget);
        expect(
          find.text(ArProgress.chooseDownload(formatBytes(15 * mb))),
          findsOneWidget,
        );

        await tester.tap(find.text('مقارنة الأعداد وترتيبها'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            ArProgress.chooseDownload(formatBytes(15 * mb + 40 * 1024)),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.text(
            ArProgress.chooseDownload(formatBytes(15 * mb + 40 * 1024)),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          fake.calls,
          contains('select:lesson:math.u1.l2,video:english.u1.l1'),
        );
      });
    });

    testWidgets('«اختر الكل» ثم «إلغاء الكل»', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, items: items, (db) async {
        await open(tester, '/account/downloads/choose');
        await tester.tap(find.text(ArProgress.chooseAll));
        await tester.pumpAndSettle();
        expect(
          find.text(
            ArProgress.chooseDownload(
              formatBytes(40 * 1024 + 15 * mb + 10 * mb),
            ),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text(ArProgress.chooseNone));
        await tester.pumpAndSettle();
        expect(
          find.text(ArProgress.chooseDownload(formatBytes(0))),
          findsOneWidget,
        );
      });
    });

    testWidgets('بلا إنترنت: الزر معطّل ويقول ذلك', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, none, items: items, (db) async {
        await open(tester, '/account/downloads/choose');
        expect(find.text(ArProgress.chooseOffline), findsOneWidget);
        await tester.tap(
          find.text(ArProgress.chooseDownload(formatBytes(15 * mb))),
        );
        await tester.pumpAndSettle();
        expect(fake.calls.where((c) => c.startsWith('select')), isEmpty);
      });
    });

    testWidgets('أثناء التنزيل: الاسم والنسبة والسرعة والوقت الباقي', (tester) {
      final fake = FakeDownloadController(
        DownloadStatus(
          running: true,
          current: DownloadProgress(
            sha256: 'b' * 64,
            received: 15 * mb,
            size: 30 * mb,
          ),
          bytesPerSecond: 1.5 * mb,
        ),
      );
      return run(tester, fake, wifi, items: items, (db) async {
        await open(tester, '/account/downloads/choose');
        expect(find.textContaining('New friends'), findsWidgets);
        expect(
          find.text(ArProgress.progressLine(50, '1.5 MB/s', '10 ث')),
          findsOneWidget,
        );
      });
    });

    test('صيغة السرعة والوقت الباقي', () {
      expect(formatDownloadSpeed(850 * 1024), '850 KB/s');
      expect(formatDownloadSpeed(1.4 * mb), '1.4 MB/s');
      expect(formatRemaining(const Duration(seconds: 12)), '12 ث');
      expect(formatRemaining(const Duration(seconds: 125)), '3 د');
      expect(
        const DownloadStatus(
          current: DownloadProgress(sha256: 'x', received: 0, size: 3 * mb),
          bytesPerSecond: 1.0 * mb,
        ).remaining,
        const Duration(seconds: 3),
      );
    });
  });

  group('جزء الفيديو في الدرس', () {
    testWidgets('غير منزَّل: زر تنزيل بحجمه', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithVideo(tester, db, 'math.u3.l3');
        await open(tester, '/lesson/math.u3.l3/video');
        expect(find.text(ArLearn.videoUnavailable), findsOneWidget);
        final button = find.text(ArLearn.videoDownload(formatBytes(videoSize)));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(fake.calls, contains('video:math.u3.l3'));
      });
    });

    testWidgets(
      'ينتظر Wi-Fi على بيانات الهاتف: يقول ذلك، ويسمح بالتنزيل الآن',
      (tester) {
        final fake = FakeDownloadController();
        return run(tester, fake, mobile, (db) async {
          await lessonWithVideo(tester, db, 'math.u3.l3');
          await queue(
            tester,
            db,
            videoSha,
            videoSize,
            received: videoSize ~/ 2,
            kind: BlobKind.video,
          );
          await open(tester, '/lesson/math.u3.l3/video');
          expect(find.text(ArLearn.videoWaitingWifi), findsOneWidget);
          final button = find.text(
            ArLearn.videoDownload(formatBytes(videoSize - videoSize ~/ 2)),
          );
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(fake.calls, contains('run:true'));
        });
      },
    );

    testWidgets('يُنزَّل على Wi-Fi: النسبة', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithVideo(tester, db, 'math.u3.l3');
        await queue(
          tester,
          db,
          videoSha,
          videoSize,
          received: videoSize ~/ 2,
          kind: BlobKind.video,
        );
        await open(tester, '/lesson/math.u3.l3/video');
        expect(find.text(ArLearn.videoDownloading(50)), findsOneWidget);
      });
    });

    testWidgets(
      'في إنترنت ولم يُنزَّل: «شاهد الآن» من الإنترنت، والتنزيل اختياري',
      (tester) {
        final fake = FakeDownloadController();
        return run(tester, fake, wifi, store: true, (db) async {
          await lessonWithVideo(tester, db, 'math.u3.l3');
          await open(tester, '/lesson/math.u3.l3/video');
          expect(find.text(ArLearn.videoWatchNow), findsOneWidget);
          expect(find.text(ArLearn.videoStreamNote), findsOneWidget);
          expect(find.text(ArLearn.videoUnavailable), findsNothing);
          final download = find.text(
            ArLearn.videoDownload(formatBytes(videoSize)),
          );
          await tester.ensureVisible(download);
          await tester.tap(download);
          await tester.pumpAndSettle();
          expect(fake.calls, contains('video:math.u3.l3'));
        });
      },
    );

    testWidgets(
      'بصمة الفيديو في ملف الدرس: «شاهد الآن» فورًا قبل أي فحص للفهرس (والويب)',
      (tester) {
        final fake = FakeDownloadController();
        return run(tester, fake, wifi, store: true, (db) async {
          await open(tester, '/lesson/english.u1.l1/video');
          expect(find.text(ArLearn.videoWatchNow), findsOneWidget);
          expect(find.text(ArLearn.videoUnavailable), findsNothing);
          expect(find.textContaining('تنزيل الفيديو'), findsNothing);
        });
      },
    );

    testWidgets('على بيانات الهاتف: يذكر الاستهلاك قبل المشاهدة', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, mobile, store: true, (db) async {
        await lessonWithVideo(tester, db, 'math.u3.l3');
        await open(tester, '/lesson/math.u3.l3/video');
        expect(find.text(ArLearn.videoWatchNow), findsOneWidget);
        expect(find.textContaining('بيانات الهاتف تستهلك'), findsOneWidget);
      });
    });

    testWidgets('بلا إنترنت ولم يُنزَّل: يقول ذلك، بلا مشاهدة ولا تنزيل', (
      tester,
    ) {
      final fake = FakeDownloadController();
      return run(tester, fake, none, store: true, (db) async {
        await lessonWithVideo(tester, db, 'math.u3.l3');
        await open(tester, '/lesson/math.u3.l3/video');
        expect(find.text(ArLearn.videoNeedsInternet), findsOneWidget);
        expect(find.text(ArLearn.videoWatchNow), findsNothing);
        expect(find.textContaining('تنزيل الفيديو'), findsNothing);
      });
    });

    testWidgets('تعذّر التشغيل من الإنترنت: رسالة صريحة تقترح التنزيل', (
      tester,
    ) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, store: true, (db) async {
        await lessonWithVideo(tester, db, 'math.u3.l3');
        await open(tester, '/lesson/math.u3.l3/video');
        await tester.tap(find.text(ArLearn.videoWatchNow));
        await tester.pumpAndSettle();
        expect(find.text(ArLearn.videoStreamFailed), findsOneWidget);
      });
    });

    test('وقت بداية الجزء', () {
      expect(parseVideoTime('1:05'), const Duration(minutes: 1, seconds: 5));
      expect(parseVideoTime('0:00'), Duration.zero);
      expect(parseVideoTime('1:75'), isNull);
      expect(parseVideoTime('abc'), isNull);
    });
  });

  group('ملفات الدرس', () {
    const pdfSha =
        '5d0f3312cc94c828f0b874715e1ce35dfd0fefe1732926f97a1078d05a0c1ae7';
    const pdfSize = 506927;
    const lessonId = 'english.u1.l1';

    Future<void> lessonWithFile(WidgetTester tester, AppDatabase db) => onDb(
      tester,
      () => db
          .into(db.contentLessons)
          .insert(
            ContentLessonsCompanion.insert(
              lessonId: lessonId,
              version: const Value(1),
              attachments: const Value('{"$pdfSha":$pdfSize}'),
            ),
          ),
    );

    Future<Finder> filesRow(WidgetTester tester) async {
      final title = find.text('ملخص الطالب: الدرس الأول');
      await tester.ensureVisible(title);
      await tester.pumpAndSettle();
      return title;
    }

    testWidgets('غير منزَّل: يفتح من الإنترنت، وزر تنزيل', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithFile(tester, db);
        await open(tester, '/lesson/$lessonId');
        await filesRow(tester);
        expect(find.text(ArLearn.filesTitle), findsOneWidget);
        expect(find.textContaining(ArLearn.filesOnline), findsOneWidget);
        await tester.tap(find.byKey(const Key('file-download-0')));
        await tester.pumpAndSettle();
        expect(fake.calls, contains('file:$lessonId:$pdfSha'));
      });
    });

    testWidgets('يُنزَّل: نسبته', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithFile(tester, db);
        await queue(
          tester,
          db,
          pdfSha,
          pdfSize,
          received: pdfSize ~/ 2,
          kind: BlobKind.attachment,
        );
        await open(tester, '/lesson/$lessonId');
        await filesRow(tester);
        expect(
          find.textContaining(ArLearn.filesDownloading(50)),
          findsOneWidget,
        );
      });
    });

    testWidgets('على الهاتف: يفتح دون إنترنت، وزر حذف', (tester) {
      final fake = FakeDownloadController();
      return run(tester, fake, wifi, (db) async {
        await lessonWithFile(tester, db);
        await onDb(
          tester,
          () => db
              .into(db.contentBlobs)
              .insert(
                ContentBlobsCompanion.insert(
                  sha256: pdfSha,
                  size: pdfSize,
                  kind: BlobKind.attachment,
                  verifiedAt: now,
                ),
              ),
        );
        await open(tester, '/lesson/$lessonId');
        await filesRow(tester);
        expect(find.textContaining(ArLearn.filesOnPhone), findsOneWidget);
        await tester.tap(find.byKey(const Key('file-remove-0')));
        await tester.pumpAndSettle();
        expect(fake.calls, contains('removeFile:$pdfSha'));
      });
    });

    testWidgets('الضغط على الملف يفتحه في العارض، مع زر تنزيل', (tester) {
      final fake = FakeDownloadController();
      return run(
        tester,
        fake,
        wifi,
        extra: [
          attachmentBytesProvider.overrideWith(
            (ref, sha) async => Uint8List.fromList([1, 2, 3]),
          ),
          pdfViewerProvider.overrideWithValue(
            (bytes) => Text('pdf:${bytes.length}'),
          ),
        ],
        (db) async {
          await lessonWithFile(tester, db);
          await open(tester, '/lesson/$lessonId');
          await tester.tap(await filesRow(tester));
          await tester.pumpAndSettle();
          expect(find.byType(AttachmentScreen), findsOneWidget);
          expect(find.text('pdf:3'), findsOneWidget);
          await tester.tap(
            find.text(ArLearn.filesDownload(formatBytes(pdfSize))),
          );
          await tester.pumpAndSettle();
          expect(fake.calls, contains('file:$lessonId:$pdfSha'));
        },
      );
    });

    testWidgets('بلا إنترنت ولم يُنزَّل: يقول ذلك ويعرض «حاول مرة أخرى»', (
      tester,
    ) {
      final fake = FakeDownloadController();
      return run(
        tester,
        fake,
        none,
        extra: [
          attachmentBytesProvider.overrideWith(
            (ref, sha) async =>
                throw const AttachmentUnavailable(offline: true),
          ),
        ],
        (db) async {
          await open(tester, '/lesson/$lessonId/file/0');
          expect(find.text(ArLearn.filesOffline), findsOneWidget);
          expect(find.text(ArLearn.filesRetry), findsOneWidget);
        },
      );
    });
  });
}
