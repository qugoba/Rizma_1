import '../../core/db/app_database.dart';
import '../catalog/catalog_models.dart';

class LearningIndex {
  LearningIndex({
    required Iterable<LessonProgressEntry> progress,
    required Iterable<LessonPartEntry> parts,
  }) : _progress = {for (final p in progress) p.lessonId: p},
       _parts = _groupParts(parts);

  const LearningIndex.empty() : _progress = const {}, _parts = const {};

  final Map<String, LessonProgressEntry> _progress;
  final Map<String, Set<LessonPart>> _parts;

  static Map<String, Set<LessonPart>> _groupParts(
    Iterable<LessonPartEntry> parts,
  ) {
    final out = <String, Set<LessonPart>>{};
    for (final p in parts) {
      (out[p.lessonId] ??= <LessonPart>{}).add(p.part);
    }
    return out;
  }

  LessonStatus statusOf(String lessonId) =>
      _progress[lessonId]?.status ?? LessonStatus.notStarted;

  double progressOf(String lessonId) => _progress[lessonId]?.progress ?? 0;

  Set<LessonPart> partsDone(String lessonId) =>
      _parts[lessonId] ?? const <LessonPart>{};

  DateTime? updatedAtOf(String lessonId) => _progress[lessonId]?.updatedAt;

  bool isCompleted(String lessonId) =>
      statusOf(lessonId) == LessonStatus.completed;

  bool isStarted(String lessonId) =>
      statusOf(lessonId) != LessonStatus.notStarted;

  int completedCount(Iterable<CatalogLesson> lessons) =>
      lessons.where((l) => isCompleted(l.id)).length;

  double fraction(List<CatalogLesson> lessons) =>
      lessons.isEmpty ? 0 : completedCount(lessons) / lessons.length;

  bool startedAny(Iterable<CatalogLesson> lessons) =>
      lessons.any((l) => isStarted(l.id));

  CatalogLesson? resumeLesson(List<CatalogLesson> lessons) {
    CatalogLesson? best;
    DateTime? bestAt;
    for (final l in lessons) {
      if (statusOf(l.id) != LessonStatus.inProgress) continue;
      final at = updatedAtOf(l.id);
      if (best == null ||
          (at != null && (bestAt == null || at.isAfter(bestAt)))) {
        best = l;
        bestAt = at;
      }
    }
    if (best != null) return best;
    for (final l in lessons) {
      if (!isCompleted(l.id)) return l;
    }
    return null;
  }
}
