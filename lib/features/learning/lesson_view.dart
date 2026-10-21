import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/enums.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_providers.dart';
import '../content/content_providers.dart';
import '../content/lesson_content.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_providers.dart';

class LessonView {
  const LessonView({
    required this.lesson,
    required this.unit,
    required this.subject,
    required this.content,
  });

  final CatalogLesson lesson;
  final CatalogUnit unit;
  final CatalogSubject subject;

  final LessonContent? content;
}

final lessonViewProvider = FutureProvider.family<LessonView?, String>((
  ref,
  lessonId,
) async {
  final catalog = await ref.watch(catalogProvider.future);
  final lesson = catalog.lessonById(lessonId);
  if (lesson == null) return null;
  final unit = catalog.unitOfLesson(lesson);
  final subject = catalog.subjectById(lesson.subjectId);
  if (unit == null || subject == null) return null;
  final content = await ref.watch(lessonContentProvider(lessonId).future);
  return LessonView(
    lesson: lesson,
    unit: unit,
    subject: subject,
    content: content,
  );
});

Future<void> completeLessonPart(
  WidgetRef ref, {
  required String lessonId,
  required LessonPart part,
}) async {
  final profileId = ref.read(activeProfileIdProvider).value;
  if (profileId == null) return;
  final content = await ref.read(lessonContentProvider(lessonId).future);
  await ref
      .read(learningRepositoryProvider)
      .completePart(
        profileId: profileId,
        lessonId: lessonId,
        part: part,
        content: content,
      );
}
