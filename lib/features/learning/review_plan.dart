import '../../core/constants/learning_rules.dart';
import '../../app/routes.dart';
import '../../core/db/enums.dart';
import '../content/lesson_content.dart';

class ReviewStep {
  const ReviewStep({
    required this.part,
    required this.route,
    required this.done,
    this.count = 0,
    this.minutes = 0,
  });

  final LessonPart part;
  final String route;
  final bool done;

  final int count;

  final int minutes;
}

class ReviewPlan {
  const ReviewPlan({
    required this.conceptId,
    required this.mastery,
    required this.steps,
  });

  final String conceptId;

  final double mastery;
  final List<ReviewStep> steps;

  ReviewStep? get current {
    for (final s in steps) {
      if (!s.done) return s;
    }
    return null;
  }
}

abstract final class ReviewPlanner {
  static const target = kMasteryThreshold;

  static const maxPractice = 5;

  static String? weakest(
    List<String> lessonConcepts,
    Map<String, double> mastery,
  ) {
    String? worst;
    var worstValue = 1.0;
    for (final id in lessonConcepts) {
      final v = mastery[id] ?? 0;
      if (v >= target) continue;
      if (worst == null || v < worstValue) {
        worst = id;
        worstValue = v;
      }
    }
    return worst;
  }

  static ReviewPlan? build({
    required String lessonId,
    required List<String> lessonConcepts,
    required Map<String, double> mastery,
    required LessonContent? content,
    required Set<LessonPart> partsDone,
  }) {
    final concept = weakest(lessonConcepts, mastery);
    if (concept == null || content == null) return null;

    final steps = <ReviewStep>[];
    if (content.has(LessonPart.explanation)) {
      steps.add(
        ReviewStep(
          part: LessonPart.explanation,
          route: AppRoutes.lessonPart(lessonId, LessonPart.explanation.name),
          done: partsDone.contains(LessonPart.explanation),
          minutes: content.steps.length,
        ),
      );
    }
    if (content.has(LessonPart.video)) {
      steps.add(
        ReviewStep(
          part: LessonPart.video,
          route: AppRoutes.lessonPart(lessonId, LessonPart.video.name),
          done: partsDone.contains(LessonPart.video),
          minutes: content.video!.minutes,
        ),
      );
    }
    if (content.has(LessonPart.practice)) {
      final own = content.practice.where((q) => q.concept == concept).length;
      final n = (own > 0 ? own : content.practice.length).clamp(1, maxPractice);
      steps.add(
        ReviewStep(
          part: LessonPart.practice,
          route: '${AppRoutes.round(lessonId)}?concept=$concept',
          done: false,
          count: n,
        ),
      );
    }
    if (content.has(LessonPart.quiz)) {
      steps.add(
        ReviewStep(
          part: LessonPart.quiz,
          route: AppRoutes.quiz(lessonId),
          done: false,
        ),
      );
    }
    if (steps.isEmpty) return null;
    return ReviewPlan(
      conceptId: concept,
      mastery: mastery[concept] ?? 0,
      steps: steps,
    );
  }
}
