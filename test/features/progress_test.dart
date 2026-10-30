import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar_learning.dart';
import 'package:rizma/core/strings/ar_progress.dart';
import 'package:rizma/features/catalog/catalog_models.dart';
import 'package:rizma/features/profiles/profile_repository.dart';
import 'package:rizma/features/progress/progress_state.dart';

import '../helpers/app_harness.dart';
import '../helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  final catalog = Catalog.fromJson(
    jsonDecode(File('assets/content/catalog_grade5.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final now = DateTime(2026, 10, 14, 12);

  group('ProgressState.derive', () {
    late AppDatabase db;
    late Profile profile;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      profile = await ProfileRepository(
        db,
      ).create(name: 'أنس', grade: 5, color: ProfileColor.teal);
    });

    tearDown(() => db.close());

    Future<ProgressState> derive({
      Set<String> content = const {'math.u1.l1', 'math.u1.l2'},
    }) async => ProgressState.derive(
      profile: profile,
      catalog: catalog,
      contentLessonIds: content,
      progress: await (db.select(db.lessonProgress)).get(),
      parts: await db.activityDao.getLessonParts(profile.id),
      attempts: await (db.select(db.attempts)).get(),
      mastery: await db.activityDao.getMastery(profile.id),
      now: now,
    );

    test('ملف جديد: صفر في كل شيء وكل الشارات مقفلة', () async {
      final s = await derive();
      expect(s.overall, 0);
      expect(s.hasActivity, isFalse);
      expect(s.streak, 0);
      expect(s.week, List.filled(7, 0));
      expect(s.badges.every((b) => !b.earned), isTrue);
      expect(s.review, isEmpty);
    });

    test('فهرس يوم الأسبوع يبدأ بالسبت', () {
      expect(ProgressState.weekdayIndex(DateTime(2026, 10, 10)), 0);
      expect(ProgressState.weekdayIndex(DateTime(2026, 10, 11)), 1);
      expect(ProgressState.weekdayIndex(DateTime(2026, 10, 14)), 4);
      expect(ProgressState.weekdayIndex(DateTime(2026, 10, 16)), 6);
    });

    test('التقدّم العام يحسب دروس المحتوى فقط', () async {
      await db.activityDao.upsertLessonProgress(
        profileId: profile.id,
        lessonId: 'math.u1.l1',
        status: LessonStatus.completed,
        progress: 1,
        now: now,
      );
      await db.activityDao.upsertLessonProgress(
        profileId: profile.id,
        lessonId: 'math.u1.l2',
        status: LessonStatus.inProgress,
        progress: 0.5,
        now: now,
      );
      await db.activityDao.upsertLessonProgress(
        profileId: profile.id,
        lessonId: 'math.u2.l1',
        status: LessonStatus.inProgress,
        progress: 0.1,
        now: now,
      );
      final s = await derive();
      expect(s.overall, closeTo(0.75, 1e-9));
      expect(s.completedLessons, 1);
      final math = s.subjects.firstWhere((b) => b.subject.id == 'math');
      expect(math.hasContent, isTrue);
      final arabic = s.subjects.firstWhere((b) => b.subject.id == 'arabic');
      expect(arabic.hasContent, isFalse);
      expect(arabic.fraction, 0);
      expect(
        s.badges.firstWhere((b) => b.kind == BadgeKind.firstLesson).earned,
        isTrue,
      );
    });

    test('نشاط الأسبوع يُوزَّع على الأيام ويستثني الأسبوع السابق', () async {
      Future<void> attempt(DateTime at) => db.activityDao.insertAttempt(
        profileId: profile.id,
        activityId: 'x',
        kind: AttemptKind.practice,
        score: 1,
        total: 2,
        starsEarned: 1,
        now: at,
      );
      await attempt(DateTime(2026, 10, 9, 10));
      await attempt(DateTime(2026, 10, 10, 10));
      await attempt(DateTime(2026, 10, 10, 18));
      await attempt(DateTime(2026, 10, 14, 9));
      await db.activityDao.markPartDone(
        profileId: profile.id,
        lessonId: 'math.u1.l1',
        part: LessonPart.pack,
        now: DateTime(2026, 10, 12, 9),
      );
      final s = await derive();
      expect(s.week, [2, 0, 1, 0, 1, 0, 0]);
      expect(s.weekTotal, 4);
      expect(s.hasActivity, isTrue);
    });

    test('الشارات: نجوم ومتتالية واختبار كامل ومستمع', () async {
      Future<void> attempt(
        DateTime at,
        AttemptKind kind,
        int score,
        int total,
        int stars,
      ) => db.activityDao.insertAttempt(
        profileId: profile.id,
        activityId: 'x',
        kind: kind,
        score: score,
        total: total,
        starsEarned: stars,
        now: at,
      );
      await attempt(DateTime(2026, 10, 12), AttemptKind.practice, 3, 4, 60);
      await attempt(DateTime(2026, 10, 13), AttemptKind.quiz, 5, 5, 45);
      await attempt(DateTime(2026, 10, 14), AttemptKind.practice, 1, 4, 0);
      await db.activityDao.markPartDone(
        profileId: profile.id,
        lessonId: 'english.u2.l1',
        part: LessonPart.words,
        now: now,
      );
      final s = await derive();
      bool earned(BadgeKind k) =>
          s.badges.firstWhere((b) => b.kind == k).earned;
      expect(s.streak, 3);
      expect(s.stars, 105);
      expect(s.quizzes, 1);
      expect(earned(BadgeKind.streak), isTrue);
      expect(earned(BadgeKind.stars), isTrue);
      expect(earned(BadgeKind.quizAce), isTrue);
      expect(earned(BadgeKind.listener), isTrue);
    });

    test('المراجعة: المفاهيم الضعيفة فقط مرتّبة من الأضعف', () async {
      Future<void> m(String id, double v) => db.activityDao.upsertMastery(
        profileId: profile.id,
        conceptId: id,
        mastery: v,
        now: now,
      );
      await m('math.u1.l1.c1', 0.9);
      await m('math.u1.l1.c2', 0.5);
      await m('math.u1.l2.c1', 0.2);
      final s = await derive();
      expect(s.review.map((r) => r.concept.id), [
        'math.u1.l2.c1',
        'math.u1.l1.c2',
      ]);
      expect(s.reviewCount, 2);
    });
  });

  testWidgets(
    'شاشة تقدّمي من التبويب: أرقام حقيقية وفتح المراجعة',
    (tester) => scenario(
      tester,
      seed: (repo) async {
        await repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);
      },
      (db) async {
        final profile = (await tester.runAsync(
          () => db.profilesDao.getAll(),
        ))!.single;
        await onDb(
          tester,
          () => db.activityDao.upsertMastery(
            profileId: profile.id,
            conceptId: 'math.u1.l1.c1',
            mastery: 0.3,
            now: DateTime.now(),
          ),
        );

        final container = ProviderScope.containerOf(
          tester.element(find.byType(RizmaApp)),
        );
        container.read(routerProvider).go('/progress');
        await tester.pumpAndSettle();

        expect(find.text(ArProgress.overall), findsOneWidget);
        expect(find.text('0%'), findsWidgets);
        expect(find.text(ArProgress.overallNoActivity), findsOneWidget);
        expect(find.text(ArProgress.weekTotal(0)), findsOneWidget);
        expect(find.text(ArProgress.statStars), findsOneWidget);

        final title = catalog.conceptById('math.u1.l1.c1')!.concept.title;
        await tester.ensureVisible(find.text(title));
        await tester.pumpAndSettle();
        expect(find.text(ArProgress.reviewEmpty), findsNothing);
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.text(ArLearn.reviewTitle), findsOneWidget);
      },
    ),
  );
}
