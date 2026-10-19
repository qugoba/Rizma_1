import '../../core/constants/learning_rules.dart';
import '../../core/db/app_database.dart';
import '../../core/utils/streak.dart';
import '../catalog/catalog_models.dart';

const double kReviewMasteryThreshold = kMasteryThreshold;

const int kMaxReviewItems = 3;

class LessonRef {
  const LessonRef({
    required this.lesson,
    required this.subject,
    required this.unit,
    required this.progress,
  });

  final CatalogLesson lesson;
  final CatalogSubject subject;
  final CatalogUnit unit;

  final double progress;
}

class SubjectProgress {
  const SubjectProgress({
    required this.subject,
    required this.completed,
    required this.total,
    required this.started,
  });

  final CatalogSubject subject;
  final int completed;
  final int total;

  final bool started;

  double get fraction => total == 0 ? 0 : completed / total;
}

class ReviewItem {
  const ReviewItem({
    required this.concept,
    required this.lesson,
    required this.mastery,
  });

  final CatalogConcept concept;
  final CatalogLesson lesson;

  final double mastery;
}

class FirstSteps {
  const FirstSteps({
    required this.downloaded,
    required this.practiced,
    required this.quizzed,
  });

  final bool downloaded;

  final bool practiced;

  final bool quizzed;

  int get done => [downloaded, practiced, quizzed].where((d) => d).length;
}

class HomeState {
  const HomeState({
    required this.profile,
    required this.hasActivity,
    required this.stars,
    required this.streak,
    required this.featured,
    required this.firstSteps,
    required this.subjects,
    required this.hasQuizAttempt,
    required this.review,
  });

  final Profile profile;

  final bool hasActivity;

  final int stars;

  final int streak;

  final LessonRef? featured;

  final FirstSteps firstSteps;
  final List<SubjectProgress> subjects;
  final bool hasQuizAttempt;
  final List<ReviewItem> review;

  bool get isFirstDay => !hasActivity;

  bool get showReviewSection => hasQuizAttempt && review.isNotEmpty;

  bool get showReviewPlaceholder => isFirstDay;

  factory HomeState.derive({
    required Profile profile,
    required Catalog catalog,
    required List<LessonProgressEntry> progress,
    required List<Attempt> attempts,
    required List<ConceptMasteryEntry> mastery,
    required DateTime now,
  }) {
    final progressByLesson = {for (final p in progress) p.lessonId: p};
    final started = progress
        .where((p) => p.status != LessonStatus.notStarted)
        .toList();

    final hasActivity = attempts.isNotEmpty || started.isNotEmpty;
    final stars = attempts.fold<int>(0, (sum, a) => sum + a.starsEarned);
    final streak = currentStreak([
      for (final a in attempts) a.createdAt,
      for (final p in started) p.updatedAt,
    ], now);

    LessonRef refOf(CatalogLesson lesson) {
      final subject = catalog.subjectById(lesson.subjectId)!;
      final unit = catalog.unitOfLesson(lesson)!;
      final entry = progressByLesson[lesson.id];
      final fraction = switch (entry?.status) {
        LessonStatus.completed => 1.0,
        LessonStatus.inProgress => entry!.progress.clamp(0.0, 1.0),
        _ => 0.0,
      };
      return LessonRef(
        lesson: lesson,
        subject: subject,
        unit: unit,
        progress: fraction,
      );
    }

    final featuredLesson = _pickFeatured(catalog, started, hasActivity);

    final subjects = [
      for (final s in catalog.subjects)
        SubjectProgress(
          subject: s,
          total: s.lessons.length,
          completed: s.lessons
              .where(
                (l) => progressByLesson[l.id]?.status == LessonStatus.completed,
              )
              .length,
          started: s.lessons.any(
            (l) =>
                (progressByLesson[l.id]?.status ?? LessonStatus.notStarted) !=
                LessonStatus.notStarted,
          ),
        ),
    ];

    final review = <ReviewItem>[];
    final weak =
        mastery.where((m) => m.mastery < kReviewMasteryThreshold).toList()
          ..sort((a, b) => a.mastery.compareTo(b.mastery));
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
      if (review.length == kMaxReviewItems) break;
    }

    return HomeState(
      profile: profile,
      hasActivity: hasActivity,
      stars: stars,
      streak: streak,
      featured: featuredLesson == null ? null : refOf(featuredLesson),
      firstSteps: FirstSteps(
        downloaded: started.isNotEmpty,
        practiced: attempts.any((a) => a.kind == AttemptKind.practice),
        quizzed: attempts.any((a) => a.kind == AttemptKind.quiz),
      ),
      subjects: subjects,
      hasQuizAttempt: attempts.any((a) => a.kind == AttemptKind.quiz),
      review: review,
    );
  }

  static CatalogLesson? _pickFeatured(
    Catalog catalog,
    List<LessonProgressEntry> started,
    bool hasActivity,
  ) {
    if (!hasActivity || started.isEmpty) return catalog.firstLesson;

    int byRecent(LessonProgressEntry a, LessonProgressEntry b) =>
        b.updatedAt.compareTo(a.updatedAt);

    final inProgress =
        started.where((p) => p.status == LessonStatus.inProgress).toList()
          ..sort(byRecent);
    if (inProgress.isNotEmpty) {
      return catalog.lessonById(inProgress.first.lessonId);
    }

    final recent = [...started]..sort(byRecent);
    final last = catalog.lessonById(recent.first.lessonId);
    if (last == null) return catalog.firstLesson;
    if (recent.first.status != LessonStatus.completed) return last;

    final completedIds = {
      for (final p in started)
        if (p.status == LessonStatus.completed) p.lessonId,
    };
    final next = catalog.nextLessonInSubject(last);
    if (next != null && !completedIds.contains(next.id)) return next;

    for (final lesson in catalog.allLessons) {
      if (!completedIds.contains(lesson.id)) return lesson;
    }
    return last;
  }
}
