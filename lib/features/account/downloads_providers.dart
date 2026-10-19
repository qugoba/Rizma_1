import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/enums.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_providers.dart';
import '../content/content_providers.dart';

class InstalledLesson {
  const InstalledLesson({
    required this.lesson,
    required this.parts,
    required this.bytes,
    this.quizCount = 0,
  });

  final CatalogLesson lesson;
  final List<LessonPart> parts;
  final int bytes;

  final int quizCount;

  bool get hasSummary => parts.contains(LessonPart.summary);
}

final installedLessonsProvider =
    FutureProvider.autoDispose<List<InstalledLesson>>((ref) async {
      final catalog = await ref.watch(catalogProvider.future);
      final repo = ref.watch(contentRepositoryProvider);
      final ids = await repo.availableLessonIds();
      final result = <InstalledLesson>[];
      for (final lesson in catalog.allLessons) {
        if (!ids.contains(lesson.id)) continue;
        final content = await repo.load(lesson.id);
        if (content == null) continue;
        result.add(
          InstalledLesson(
            lesson: lesson,
            parts: content.parts,
            bytes: await repo.byteSize(lesson.id),
            quizCount: content.quiz.length,
          ),
        );
      }
      return result;
    });

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
