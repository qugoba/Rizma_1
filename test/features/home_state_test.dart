import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/catalog/catalog_models.dart';
import 'package:rizma/features/catalog/catalog_repository.dart';
import 'package:rizma/features/home/home_state.dart';

void main() {
  late Catalog catalog;
  final now = DateTime(2026, 10, 8, 15);

  final profile = Profile(
    id: 'p1',
    name: 'أنس',
    grade: 5,
    color: ProfileColor.teal,
    pinHash: null,
    pinSalt: null,
    studentCode: 'RZ-AAAA-AAAA',
    classCode: null,
    equipped: '',
    createdAt: DateTime(2026, 10, 1),
    lastActiveAt: DateTime(2026, 10, 1),
    revision: 0,
    localVersion: 0,
  );

  setUpAll(() async {
    catalog = await CatalogRepository(
      loadString: (path) => File(path).readAsString(),
    ).load();
  });

  LessonProgressEntry lessonRow(
    String lessonId,
    LessonStatus status, {
    double progress = 0,
    DateTime? at,
  }) {
    return LessonProgressEntry(
      profileId: 'p1',
      lessonId: lessonId,
      status: status,
      progress: progress,
      updatedAt: at ?? now,
    );
  }

  var attemptId = 0;
  Attempt attempt(
    AttemptKind kind, {
    int stars = 0,
    DateTime? at,
    String activity = 'a',
  }) {
    return Attempt(
      id: 'a${++attemptId}',
      profileId: 'p1',
      activityId: activity,
      kind: kind,
      score: 3,
      total: 5,
      starsEarned: stars,
      hintsUsed: 0,
      createdAt: at ?? now,
    );
  }

  ConceptMasteryEntry masteryRow(String conceptId, double value) {
    return ConceptMasteryEntry(
      profileId: 'p1',
      conceptId: conceptId,
      mastery: value,
      updatedAt: now,
    );
  }

  HomeState derive({
    List<LessonProgressEntry> progress = const [],
    List<Attempt> attempts = const [],
    List<ConceptMasteryEntry> mastery = const [],
  }) {
    return HomeState.derive(
      profile: profile,
      catalog: catalog,
      progress: progress,
      attempts: attempts,
      mastery: mastery,
      now: now,
    );
  }

  group('ملف جديد = أول يوم', () {
    test('لا نجوم ولا سلسلة ولا مراجعة ولا تقدّم', () {
      final s = derive();
      expect(s.isFirstDay, isTrue);
      expect(s.hasActivity, isFalse);
      expect(s.stars, 0);
      expect(s.streak, 0);
      expect(s.hasQuizAttempt, isFalse);
      expect(s.review, isEmpty);
      expect(s.showReviewSection, isFalse);
      expect(s.showReviewPlaceholder, isTrue);
      expect(s.firstSteps.done, 0);
    });

    test('البطاقة تعرض أول درس في الكتالوج بتقدّم صفر', () {
      final f = derive().featured!;
      expect(f.lesson.id, catalog.firstLesson!.id);
      expect(f.progress, 0);
      expect(f.subject.id, 'math');
    });

    test('كل المواد «لم تبدأ» ونسبها صفر', () {
      final s = derive();
      expect(s.subjects, hasLength(6));
      for (final subject in s.subjects) {
        expect(subject.started, isFalse);
        expect(subject.fraction, 0);
      }
    });
  });

  group('بعد النشاط', () {
    test('درس قيد التقدّم يظهر في بطاقة المتابعة بنسبته الحقيقية', () {
      final s = derive(
        progress: [
          lessonRow('math.u1.l2', LessonStatus.inProgress, progress: 0.4),
        ],
      );
      expect(s.hasActivity, isTrue);
      expect(s.isFirstDay, isFalse);
      expect(s.showReviewPlaceholder, isFalse);
      expect(s.featured!.lesson.id, 'math.u1.l2');
      expect(s.featured!.progress, closeTo(0.4, 1e-9));
    });

    test('أحدث درس قيد التقدّم هو الذي يُعرض', () {
      final s = derive(
        progress: [
          lessonRow(
            'math.u1.l1',
            LessonStatus.inProgress,
            progress: 0.9,
            at: now.subtract(const Duration(days: 2)),
          ),
          lessonRow(
            'arabic.u1.l1',
            LessonStatus.inProgress,
            progress: 0.2,
            at: now,
          ),
        ],
      );
      expect(s.featured!.lesson.id, 'arabic.u1.l1');
    });

    test('بلا درس قيد التقدّم: يُعرض الدرس التالي بعد آخر درس مكتمل', () {
      final s = derive(
        progress: [
          lessonRow('math.u1.l1', LessonStatus.completed, progress: 1),
        ],
      );
      expect(s.featured!.lesson.id, 'math.u1.l2');
      expect(s.featured!.progress, 0);
    });

    test('درس محمَّل لم يبدأ يُعرض هو نفسه', () {
      final s = derive(
        progress: [lessonRow('math.u1.l3', LessonStatus.downloaded)],
      );
      expect(s.featured!.lesson.id, 'math.u1.l3');
      expect(s.firstSteps.downloaded, isTrue);
    });

    test('النجوم مجموع starsEarned', () {
      final s = derive(
        attempts: [
          attempt(AttemptKind.practice, stars: 3),
          attempt(AttemptKind.quiz, stars: 2),
        ],
      );
      expect(s.stars, 5);
    });

    test('السلسلة تُحسب من أيام النشاط المتتالية', () {
      final s = derive(
        attempts: [
          attempt(AttemptKind.practice, at: now),
          attempt(
            AttemptKind.practice,
            at: now.subtract(const Duration(days: 1)),
          ),
          attempt(
            AttemptKind.practice,
            at: now.subtract(const Duration(days: 2)),
          ),
          attempt(
            AttemptKind.practice,
            at: now.subtract(const Duration(days: 4)),
          ),
        ],
      );
      expect(s.streak, 3);
    });

    test('تقدّم المادة = المكتمل ÷ دروس المادة', () {
      final math = catalog.subjectById('math')!;
      final s = derive(
        progress: [
          lessonRow('math.u1.l1', LessonStatus.completed, progress: 1),
          lessonRow('math.u1.l2', LessonStatus.completed, progress: 1),
          lessonRow('math.u1.l3', LessonStatus.inProgress, progress: 0.5),
        ],
      );
      final p = s.subjects.firstWhere((x) => x.subject.id == 'math');
      expect(p.completed, 2);
      expect(p.total, math.lessons.length);
      expect(p.fraction, closeTo(2 / math.lessons.length, 1e-9));
      expect(p.started, isTrue);
      expect(
        s.subjects.firstWhere((x) => x.subject.id == 'arabic').started,
        isFalse,
      );
    });

    test('خطواتك الأولى تُحسب من البيانات', () {
      expect(
        derive(attempts: [attempt(AttemptKind.practice)]).firstSteps.done,
        1,
      );
      final all = derive(
        progress: [lessonRow('math.u1.l1', LessonStatus.downloaded)],
        attempts: [attempt(AttemptKind.practice), attempt(AttemptKind.quiz)],
      );
      expect(all.firstSteps.done, 3);
    });
  });

  group('قسم «يحتاج إلى مراجعة»', () {
    test('لا يظهر دون محاولة اختبار حتى لو وُجد إتقان منخفض', () {
      final s = derive(
        attempts: [attempt(AttemptKind.practice, stars: 1)],
        mastery: [masteryRow('math.u2.l2.c1', 0.2)],
      );
      expect(s.hasQuizAttempt, isFalse);
      expect(s.showReviewSection, isFalse);
    });

    test('بعد اختبار يُبنى من المفاهيم الضعيفة فقط ومرتبة من الأضعف', () {
      final s = derive(
        attempts: [attempt(AttemptKind.quiz, stars: 1)],
        mastery: [
          masteryRow('math.u2.l2.c1', 0.4),
          masteryRow('math.u2.l2.c2', 0.9),
          masteryRow('math.u1.l1.c1', 0.1),
          masteryRow('math.u1.l1.c2', kReviewMasteryThreshold),
        ],
      );
      expect(s.showReviewSection, isTrue);
      expect(s.review.map((r) => r.concept.id), [
        'math.u1.l1.c1',
        'math.u2.l2.c1',
      ]);
      expect(s.review.first.mastery, 0.1);
      expect(s.review.first.lesson.id, 'math.u1.l1');
    });

    test('بعد اختبار بلا مفهوم ضعيف لا يظهر القسم', () {
      final s = derive(
        attempts: [attempt(AttemptKind.quiz, stars: 3)],
        mastery: [masteryRow('math.u1.l1.c1', 0.95)],
      );
      expect(s.hasQuizAttempt, isTrue);
      expect(s.showReviewSection, isFalse);
    });

    test('أقصى عدد بطاقات $kMaxReviewItems', () {
      final s = derive(
        attempts: [attempt(AttemptKind.quiz)],
        mastery: [
          masteryRow('math.u1.l1.c1', 0.1),
          masteryRow('math.u1.l1.c2', 0.2),
          masteryRow('math.u1.l2.c1', 0.3),
          masteryRow('math.u1.l2.c2', 0.4),
        ],
      );
      expect(s.review, hasLength(kMaxReviewItems));
    });

    test('مفهوم غير موجود في الكتالوج يُتجاهل', () {
      final s = derive(
        attempts: [attempt(AttemptKind.quiz)],
        mastery: [masteryRow('unknown.concept', 0.1)],
      );
      expect(s.review, isEmpty);
    });
  });
}
