import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/database_provider.dart';
import '../profiles/active_profile_provider.dart';
import 'wardrobe_repository.dart';

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository(
    ref.watch(appDatabaseProvider),
    now: ref.watch(clockProvider),
  );
});

final ownedItemsProvider = StreamProvider.autoDispose
    .family<List<OwnedItem>, String>(
      (ref, profileId) =>
          ref.watch(appDatabaseProvider).wardrobeDao.watchOwned(profileId),
    );

final equippedItemsProvider = StreamProvider.autoDispose
    .family<Set<String>, String>(
      (ref, profileId) =>
          ref.watch(wardrobeRepositoryProvider).watchEquipped(profileId),
    );

final activeEquippedProvider = Provider.autoDispose<Set<String>>((ref) {
  final id = ref.watch(activeProfileIdProvider).value;
  if (id == null) return const {};
  return ref.watch(equippedItemsProvider(id)).value ?? const {};
});
