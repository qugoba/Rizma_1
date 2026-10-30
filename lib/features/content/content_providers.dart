import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../downloads/download_providers.dart';
import 'content_repository.dart';
import 'lesson_content.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(installed: ref.watch(installedContentProvider));
});

final contentIndexProvider = FutureProvider<Set<String>>((ref) {
  return ref.watch(contentRepositoryProvider).availableLessonIds();
});

final lessonContentProvider = FutureProvider.family<LessonContent?, String>((
  ref,
  lessonId,
) {
  return ref.watch(contentRepositoryProvider).load(lessonId);
});
