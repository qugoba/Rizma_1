import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/database_provider.dart';
import '../profiles/active_profile_provider.dart';
import 'preferences_repository.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(
    ref.watch(appDatabaseProvider),
    now: ref.watch(clockProvider),
  );
});

final activePrefsProvider = StreamProvider<ProfilePrefs>((ref) async* {
  final id = await ref.watch(activeProfileIdProvider.future);
  if (id == null) {
    yield const ProfilePrefs();
    return;
  }
  yield* ref.watch(preferencesRepositoryProvider).watch(id);
});

final downloadPrefsProvider = StreamProvider<DownloadPrefs>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchDownloads();
});

final bookmarksProvider = StreamProvider<Set<String>>((ref) async* {
  final id = await ref.watch(activeProfileIdProvider.future);
  if (id == null) {
    yield const <String>{};
    return;
  }
  yield* ref.watch(preferencesRepositoryProvider).watchBookmarks(id);
});

final pendingSyncCountProvider = StreamProvider.autoDispose<int>((ref) async* {
  final id = await ref.watch(activeProfileIdProvider.future);
  if (id == null) {
    yield 0;
    return;
  }
  yield* ref.watch(appDatabaseProvider).activityDao.watchUnsyncedAttempts(id);
});

typedef ShareText = Future<void> Function(String text);

final shareTextProvider = Provider<ShareText>((ref) {
  return (text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  };
});
