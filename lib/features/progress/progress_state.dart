import '../../core/db/app_database.dart';
import '../../core/utils/streak.dart';
import '../catalog/catalog_models.dart';
import '../home/home_state.dart';

enum BadgeKind { firstLesson, streak, stars, listener, quizAce }

class BadgeStatus {
  const BadgeStatus(this.kind, this.earned);

  final BadgeKind kind;
  final bool earned;
}

class SubjectBar {
  const SubjectBar({
    required this.subject,
    required this.fraction,
    required this.hasContent,
  });

  final CatalogSubject subject;

  final double fraction;
  final bool hasContent;
}

class ProgressState {
  const ProgressState({
    required this.grade,
    required this.overall,
    required this.hasActivity,
    required this.streak,
    required this.completedLessons,
    required this.reviewCount,
    required this.quizzes,
    required this.stars,
    required this.week,
    required this.subjects,
    required this.review,
    required this.badges,
  });

  final int grade;

  final double overall;
  final bool hasActivity;
  final int streak;
  final int completedLessons;
  final int reviewCount;
  final int quizzes;
  final int stars;

  final List<int> week;
  final List<SubjectBar> subjects;
  final List<ReviewItem> review;
  final List<BadgeStatus> badges;

  int get weekTotal => week.fold(0, (a, b) => a + b);

  static int weekdayIndex(DateTime d) =>
      (d.weekday - DateTime.saturday + 7) % 7;

  static ProgressState derive({
    required Profile profile,
    required Catalog catalog,
    required Set<String> contentLessonIds,
    required List<LessonProgressEntry> progress,
    required List<LessonPartEntry> parts,
    required List<Attempt> attempts,
    required List<ConceptMasteryEntry> mastery,
    required DateTime now,
  }) {
    final byLesson = {for (final p in progress) p.lessonId: p};
    double fractionOf(String lessonId) {
      final e = byLesson[lessonId];
      return switch (e?.status) {
        LessonStatus.completed => 1.0,
        LessonStatus.inProgress => e!.progress.clamp(0.0, 1.0),
        _ => 0.0,
      };
    }

    double average(Iterable<CatalogLesson> lessons) {
      final list = lessons
          .where((l) => contentLessonIds.contains(l.id))
          .toList();
      if (list.isEmpty) return 0;
      return list.fold<double>(0, (a, l) => a + fractionOf(l.id)) / list.length;
    }

    final started = progress
        .where((p) => p.status != LessonStatus.notStarted)
        .toList();
    final stars = attempts.fold<int>(0, (s, a) => s + a.starsEarned);
    final streak = currentStreak([
      for (final a in attempts) a.createdAt,
      for (final p in started) p.updatedAt,
      for (final p in parts) p.completedAt,
    ], now);

    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: weekdayIndex(today)));
    final week = List.filled(7, 0);
    void count(DateTime t) {
      final day = DateTime(t.year, t.month, t.day);
      final i = day.difference(weekStart).inDays;
      if (i >= 0 && i < 7) week[i]++;
    }

    for (final a in attempts) {
      count(a.createdAt);
    }
    for (final p in parts) {
      count(p.completedAt);
    }

    final weak =
        mastery.where((m) => m.mastery < kReviewMasteryThreshold).toList()
          ..sort((a, b) => a.mastery.compareTo(b.mastery));
    final review = <ReviewItem>[];
    for (final m in weak) {
      final hit = catalog.conceptById(m.conceptId);
      if (hit == null) continue;
      review.add(
        ReviewItem(
          concept: hit.concept,
          lesson: hit.lesson,
          mastery: m.mastery,
        ),
      );
    }

    final completed = progress
        .where((p) => p.status == LessonStatus.completed)
        .length;
    final quizAttempts = attempts.where((a) => a.kind == AttemptKind.quiz);

    return ProgressState(
      grade: profile.grade,
      overall: average(catalog.allLessons),
      hasActivity:
          attempts.isNotEmpty || started.isNotEmpty || parts.isNotEmpty,
      streak: streak,
      completedLessons: completed,
      reviewCount: review.length,
      quizzes: quizAttempts.length,
      stars: stars,
      week: week,
      subjects: [
        for (final s in catalog.subjects)
          SubjectBar(
            subject: s,
            fraction: average(s.lessons),
            hasContent: s.lessons.any((l) => contentLessonIds.contains(l.id)),
          ),
      ],
      review: review.take(5).toList(),
      badges: [
        BadgeStatus(BadgeKind.firstLesson, completed > 0),
        BadgeStatus(BadgeKind.streak, streak >= 3),
        BadgeStatus(BadgeKind.stars, stars >= 100),
        BadgeStatus(
          BadgeKind.listener,
          parts.any((p) => p.part == LessonPart.words),
        ),
        BadgeStatus(
          BadgeKind.quizAce,
          quizAttempts.any((a) => a.total > 0 && a.score == a.total),
        ),
      ],
    );
  }
}
