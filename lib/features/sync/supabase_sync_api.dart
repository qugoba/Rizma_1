import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import '../../core/db/daos/settings_dao.dart';
import 'sync_api.dart';

class ServerConfig {
  const ServerConfig({required this.url, required this.publishableKey});

  final String url;
  final String publishableKey;

  static ServerConfig? fromEnvironment() {
    if (const String.fromEnvironment('RIZMA_SYNC') == 'off') return null;
    return const ServerConfig(
      url: String.fromEnvironment(
        'RIZMA_SUPABASE_URL',
        defaultValue: 'https://znrxseznkjmcugmyzmya.supabase.co',
      ),
      publishableKey: String.fromEnvironment(
        'RIZMA_SUPABASE_KEY',
        defaultValue: 'sb_publishable_lULv0NY-Urx00TyuQoYBEQ_9S5MHHvo',
      ),
    );
  }
}

abstract interface class SessionStore {
  Future<String?> read();
  Future<void> write(String? session);
}

class SettingsSessionStore implements SessionStore {
  SettingsSessionStore(this._settings);

  static const key = 'sync.session';

  final SettingsDao _settings;

  @override
  Future<String?> read() => _settings.read(key);

  @override
  Future<void> write(String? session) =>
      session == null ? _settings.remove(key) : _settings.write(key, session);
}

class SupabaseSyncApi implements SyncApi {
  SupabaseSyncApi(
    ServerConfig config, {
    required SessionStore store,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 30),
    this.uploadTimeout = const Duration(seconds: 90),
  }) : _store = store,
       _client = SupabaseClient(
         config.url,
         config.publishableKey,
         authOptions: const AuthClientOptions(
           authFlowType: AuthFlowType.implicit,
         ),
         httpClient: httpClient,
       ) {
    _authEvents = _client.auth.onAuthStateChange.listen(
      (state) => _persist(state.session),
      onError: (Object _) {},
    );
  }

  final SupabaseClient _client;
  final SessionStore _store;
  late final StreamSubscription<AuthState> _authEvents;

  final Duration timeout;

  final Duration uploadTimeout;

  String? _savedRefreshToken;
  Future<void>? _signingIn;

  @override
  Future<void> ensureSignedIn() =>
      _signingIn ??= _signIn().whenComplete(() => _signingIn = null);

  Future<void> _signIn() => _guard(() async {
    final auth = _client.auth;
    if (auth.currentSession == null) {
      final saved = await _store.read();
      if (saved != null) {
        _savedRefreshToken = _refreshTokenOf(saved);
        try {
          await auth.recoverSession(saved).timeout(timeout);
        } on AuthException catch (e) {
          if (_isTransient(e)) rethrow;
          await _store.write(null);
        }
      }
    }
    if (auth.currentSession == null) {
      await auth.signInAnonymously().timeout(timeout);
    } else {
      await auth.getSession().timeout(timeout);
    }
    await _persist(auth.currentSession);
  });

  @override
  Future<Map<String, dynamic>> uploadBatch(Map<String, dynamic> batch) =>
      _rpc('upload_batch', {'p_batch': batch}, uploadTimeout);

  @override
  Future<Map<String, dynamic>> pullChanges(
    String profileId,
    int cursor, {
    int limit = 500,
  }) => _rpc('pull_changes', {
    'p_profile_id': profileId,
    'p_cursor': cursor,
    'p_limit': limit,
  });

  @override
  Future<Map<String, dynamic>> restoreProfile(
    String code, {
    bool cancelDeletion = false,
  }) => _rpc('restore_profile', {
    'p_code': code,
    'p_cancel_deletion': cancelDeletion,
  });

  @override
  Future<Map<String, dynamic>> requestDeletion(String profileId, String code) =>
      _rpc('request_deletion', {'p_profile_id': profileId, 'p_code': code});

  @override
  Future<void> unlinkDevice(String profileId) => _guard(
    () => _client
        .rpc<dynamic>('unlink_device', params: {'p_profile_id': profileId})
        .timeout(timeout),
  );

  Future<Map<String, dynamic>> _rpc(
    String name,
    Map<String, dynamic> params, [
    Duration? limit,
  ]) => _guard(() async {
    final res = await _client
        .rpc<dynamic>(name, params: params)
        .timeout(limit ?? timeout);
    await _persist(_client.auth.currentSession);
    if (res is Map<String, dynamic>) return res;
    throw SyncApiException(SyncError.server, 'unexpected $name reply: $res');
  });

  Future<void> _persist(Session? session) async {
    if (session == null) return;
    final token = session.refreshToken;
    if (token == null || token == _savedRefreshToken) return;
    _savedRefreshToken = token;
    await _store.write(jsonEncode(session.toJson()));
  }

  static String? _refreshTokenOf(String saved) {
    try {
      return (jsonDecode(saved) as Map<String, dynamic>)['refresh_token']
          as String?;
    } catch (_) {
      return null;
    }
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on SyncApiException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _fromPostgrest(e);
    } on AuthException catch (e) {
      throw SyncApiException(
        _isTransient(e) ? SyncError.network : SyncError.server,
        'auth: ${e.message}',
      );
    } on TimeoutException {
      throw const SyncApiException(SyncError.network, 'timeout');
    } on http.ClientException catch (e) {
      throw SyncApiException(SyncError.network, e.message);
    } on FormatException catch (e) {
      throw SyncApiException(SyncError.server, e.message);
    } on Exception catch (e) {
      throw SyncApiException(SyncError.network, '$e');
    }
  }

  static SyncApiException _fromPostgrest(PostgrestException e) {
    final code = e.code ?? '';
    if (code.startsWith('RZ')) {
      return SyncApiException.fromSqlState(code, e.message);
    }
    if (code == 'PGRST301' || code == 'PGRST302' || code == '42501') {
      return SyncApiException(SyncError.notAuthenticated, e.message);
    }
    if (code == '429' || RegExp(r'^5\d\d$').hasMatch(code)) {
      return SyncApiException(SyncError.network, 'http $code');
    }
    return SyncApiException(SyncError.server, '$code ${e.message}');
  }

  static bool _isTransient(AuthException e) {
    if (e is AuthRetryableFetchException) return true;
    final status = int.tryParse(e.statusCode ?? '');
    return status == 429 || (status != null && status >= 500);
  }

  Future<void> dispose() async {
    await _authEvents.cancel();
    await _client.dispose();
  }
}
