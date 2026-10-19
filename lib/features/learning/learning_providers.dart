import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/database_provider.dart';
import '../home/home_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_index.dart';
import 'learning_repository.dart';

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(
    ref.watch(appDatabaseProvider),
    now: ref.watch(clockProvider),
  );
});

final lessonPartsProvider = StreamProvider.autoDispose
    .family<List<LessonPartEntry>, String>(
      (ref, profileId) => ref
          .watch(appDatabaseProvider)
          .activityDao
          .watchLessonParts(profileId),
    );

final learningIndexProvider = Provider.autoDispose<LearningIndex>((ref) {
  final id = ref.watch(activeProfileIdProvider).value;
  if (id == null) return const LearningIndex.empty();
  return LearningIndex(
    progress: ref.watch(lessonProgressProvider(id)).value ?? const [],
    parts: ref.watch(lessonPartsProvider(id)).value ?? const [],
  );
});

final roundRandomProvider = Provider<Random>((ref) => Random());

final starsTotalProvider = Provider.autoDispose<int>((ref) {
  final id = ref.watch(activeProfileIdProvider).value;
  if (id == null) return 0;
  final attempts = ref.watch(attemptsProvider(id)).value ?? const [];
  return attempts.fold(0, (sum, a) => sum + a.starsEarned);
});

typedef LoadedAttempt = ({Attempt attempt, AttemptDetails details});

final attemptDetailsProvider = FutureProvider.autoDispose
    .family<LoadedAttempt?, int>((ref, attemptId) async {
      final profileId = await ref.watch(activeProfileIdProvider.future);
      if (profileId == null) return null;
      return ref
          .watch(learningRepositoryProvider)
          .loadAttempt(profileId, attemptId);
    });
