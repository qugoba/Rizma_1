import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database_provider.dart';
import '../catalog/catalog_providers.dart';
import '../content/content_providers.dart';
import '../home/home_providers.dart';
import '../learning/learning_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'progress_state.dart';

final progressStateProvider = Provider.autoDispose<ProgressState?>((ref) {
  final profile = ref.watch(activeProfileProvider).value;
  final catalog = ref.watch(catalogProvider).value;
  final content = ref.watch(contentIndexProvider).value;
  if (profile == null || catalog == null || content == null) return null;

  final progress = ref.watch(lessonProgressProvider(profile.id)).value;
  final parts = ref.watch(lessonPartsProvider(profile.id)).value;
  final attempts = ref.watch(attemptsProvider(profile.id)).value;
  final mastery = ref.watch(masteryProvider(profile.id)).value;
  if (progress == null ||
      parts == null ||
      attempts == null ||
      mastery == null) {
    return null;
  }

  return ProgressState.derive(
    profile: profile,
    catalog: catalog,
    contentLessonIds: content,
    progress: progress,
    parts: parts,
    attempts: attempts,
    mastery: mastery,
    now: ref.watch(clockProvider)(),
  );
});
