import '../../app/routes.dart';
import '../../core/db/app_database.dart';
import '../account/downloads_providers.dart';
import '../catalog/catalog_models.dart';

class WeakConcept {
  const WeakConcept({
    required this.concept,
    required this.lesson,
    required this.mastery,
  });

  final CatalogConcept concept;
  final CatalogLesson lesson;
  final double mastery;
}

enum PlanKind { review, practice, quiz, start }

class PlanItem {
  const PlanItem({
    required this.kind,
    required this.route,
    this.concept,
    this.count = 0,
  });

  final PlanKind kind;
  final String route;
  final String? concept;
  final int count;
}

class ExamPrep {
  const ExamPrep({
    required this.readiness,
    required this.basedOn,
    required this.weak,
    required this.summaryLessons,
    required this.mockLesson,
    required this.plan,
  });

  final int? readiness;

  final int basedOn;

  final List<WeakConcept> weak;

  final int summaryLessons;

  final InstalledLesson? mockLesson;
  final List<PlanItem> plan;

  static const lastQuizzes = 3;
  static const maxWeak = 3;

  static ExamPrep derive({
    required Catalog catalog,
    required List<InstalledLesson> installed,
    required List<Attempt> attempts,
    required List<ConceptMasteryEntry> mastery,
  }) {
    final quizzes =
        attempts
            .where((a) => a.kind == AttemptKind.quiz && a.total > 0)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = quizzes.take(lastQuizzes).toList();
    final readiness = recent.isEmpty
        ? null
        : (recent.fold<double>(0, (s, a) => s + a.score / a.total) /
                  recent.length *
                  100)
              .round();

    final byMastery = [...mastery]
      ..sort((a, b) => a.mastery.compareTo(b.mastery));
    final weak = <WeakConcept>[];
    for (final m in byMastery) {
      final hit = catalog.conceptById(m.conceptId);
      if (hit == null) continue;
      weak.add(
        WeakConcept(
          concept: hit.concept,
          lesson: hit.lesson,
          mastery: m.mastery,
        ),
      );
      if (weak.length == maxWeak) break;
    }

    InstalledLesson? lessonById(String id) {
      for (final l in installed) {
        if (l.lesson.id == id) return l;
      }
      return null;
    }

    final target = weak.isEmpty ? null : lessonById(weak.first.lesson.id);
    final mock = target ?? (installed.isEmpty ? null : installed.first);

    final plan = <PlanItem>[];
    if (mock != null) {
      final concept = weak.isEmpty ? null : weak.first.concept.id;
      plan.add(
        PlanItem(
          kind: PlanKind.review,
          route: AppRoutes.review(mock.lesson.id),
          concept: concept,
        ),
      );
      plan.add(
        PlanItem(
          kind: PlanKind.practice,
          route: concept == null
              ? AppRoutes.round(mock.lesson.id)
              : '${AppRoutes.round(mock.lesson.id)}?concept=$concept',
          count: 5,
        ),
      );
      if (mock.quizCount > 0) {
        plan.add(
          PlanItem(kind: PlanKind.quiz, route: AppRoutes.quiz(mock.lesson.id)),
        );
      }
    } else {
      plan.add(const PlanItem(kind: PlanKind.start, route: AppRoutes.subjects));
    }

    return ExamPrep(
      readiness: readiness,
      basedOn: recent.length,
      weak: weak,
      summaryLessons: installed.where((l) => l.hasSummary).length,
      mockLesson: mock != null && mock.quizCount > 0 ? mock : null,
      plan: plan,
    );
  }
}
