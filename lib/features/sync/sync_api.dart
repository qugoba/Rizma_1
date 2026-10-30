import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database_provider.dart';
import 'supabase_sync_api.dart';

abstract interface class SyncApi {
  Future<void> ensureSignedIn();

  Future<Map<String, dynamic>> uploadBatch(Map<String, dynamic> batch);

  Future<Map<String, dynamic>> pullChanges(
    String profileId,
    int cursor, {
    int limit = 500,
  });

  Future<Map<String, dynamic>> restoreProfile(
    String code, {
    bool cancelDeletion = false,
  });

  Future<Map<String, dynamic>> requestDeletion(String profileId, String code);

  Future<void> unlinkDevice(String profileId);
}

const maxBatchRows = 200;
const maxBatchBytes = 256 * 1024;

enum SyncError {
  network,

  notAuthenticated,

  notLinked,

  profileUnknown,

  studentCodeTaken,

  profileDeleted,

  batchTooLarge,

  server,
}

class SyncApiException implements Exception {
  const SyncApiException(this.error, [this.detail]);

  final SyncError error;
  final String? detail;

  factory SyncApiException.fromSqlState(String? code, [String? detail]) =>
      SyncApiException(switch (code) {
        'RZ401' => SyncError.notAuthenticated,
        'RZ403' => SyncError.notLinked,
        'RZ404' => SyncError.profileUnknown,
        'RZ409' => SyncError.studentCodeTaken,
        'RZ410' => SyncError.profileDeleted,
        'RZ413' => SyncError.batchTooLarge,
        _ => SyncError.server,
      }, detail);

  @override
  String toString() =>
      'SyncApiException($error${detail == null ? '' : ': $detail'})';
}

final serverConfigProvider = Provider<ServerConfig?>(
  (ref) => ServerConfig.fromEnvironment(),
);

final syncApiProvider = Provider<SyncApi?>((ref) {
  final config = ref.watch(serverConfigProvider);
  if (config == null) return null;
  final api = SupabaseSyncApi(
    config,
    store: SettingsSessionStore(ref.watch(appDatabaseProvider).settingsDao),
  );
  ref.onDispose(api.dispose);
  return api;
});
