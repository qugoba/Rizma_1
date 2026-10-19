import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/database_provider.dart';
import '../catalog/catalog_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'home_state.dart';

final lessonProgressProvider = StreamProvider.autoDispose
    .family<List<LessonProgressEntry>, String>(
      (ref, profileId) => ref
          .watch(appDatabaseProvider)
          .activityDao
          .watchLessonProgress(profileId),
    );

final attemptsProvider = StreamProvider.autoDispose
    .family<List<Attempt>, String>(
      (ref, profileId) =>
          ref.watch(appDatabaseProvider).activityDao.watchAttempts(profileId),
    );

final masteryProvider = StreamProvider.autoDispose
    .family<List<ConceptMasteryEntry>, String>(
      (ref, profileId) =>
          ref.watch(appDatabaseProvider).activityDao.watchMastery(profileId),
    );

final homeStateProvider = Provider.autoDispose<AsyncValue<HomeState?>>((ref) {
  final profileAsync = ref.watch(activeProfileProvider);
  final catalogAsync = ref.watch(catalogProvider);

  if (profileAsync.hasError) {
    return AsyncError(profileAsync.error!, profileAsync.stackTrace!);
  }
  if (catalogAsync.hasError) {
    return AsyncError(catalogAsync.error!, catalogAsync.stackTrace!);
  }

  final profile = profileAsync.value;
  if (profile == null) {
    return profileAsync.isLoading
        ? const AsyncLoading()
        : const AsyncData(null);
  }

  final catalog = catalogAsync.value;
  final progress = ref.watch(lessonProgressProvider(profile.id));
  final attempts = ref.watch(attemptsProvider(profile.id));
  final mastery = ref.watch(masteryProvider(profile.id));

  for (final source in [progress, attempts, mastery]) {
    if (source.hasError) {
      return AsyncError(source.error!, source.stackTrace!);
    }
  }
  if (catalog == null ||
      progress.value == null ||
      attempts.value == null ||
      mastery.value == null) {
    return const AsyncLoading();
  }

  return AsyncData(
    HomeState.derive(
      profile: profile,
      catalog: catalog,
      progress: progress.value!,
      attempts: attempts.value!,
      mastery: mastery.value!,
      now: ref.watch(clockProvider)(),
    ),
  );
});
