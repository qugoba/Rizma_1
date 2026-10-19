import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import 'profile_providers.dart';

class ActiveProfileIdNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() {
    return ref.read(profileRepositoryProvider).readActiveId();
  }

  Future<void> select(String id) async {
    await ref.read(profileRepositoryProvider).setActive(id);
    state = AsyncData(id);
  }

  Future<void> reload() async {
    state = AsyncData(await ref.read(profileRepositoryProvider).readActiveId());
  }
}

final activeProfileIdProvider =
    AsyncNotifierProvider<ActiveProfileIdNotifier, String?>(
      ActiveProfileIdNotifier.new,
    );

final activeProfileProvider = StreamProvider<Profile?>((ref) async* {
  final id = await ref.watch(activeProfileIdProvider.future);
  if (id == null) {
    yield null;
    return;
  }
  yield* ref.watch(profileRepositoryProvider).watchById(id);
});
