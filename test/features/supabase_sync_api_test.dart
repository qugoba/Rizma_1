import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rizma/features/sync/supabase_sync_api.dart';
import 'package:rizma/features/sync/sync_api.dart';

const _config = ServerConfig(
  url: 'https://test.supabase.co',
  publishableKey: 'sb_publishable_test',
);

class _MemoryStore implements SessionStore {
  String? value;
  int writes = 0;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String? session) async {
    value = session;
    writes++;
  }
}

String _jwt(String userId, {required Duration expiresIn}) {
  String part(Map<String, Object> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final exp =
      DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'sub': userId, 'exp': exp, 'role': 'authenticated'})}.sig';
}

Map<String, Object?> _session(
  String userId,
  String refreshToken, {
  Duration expiresIn = const Duration(hours: 1),
}) => {
  'access_token': _jwt(userId, expiresIn: expiresIn),
  'token_type': 'bearer',
  'expires_in': expiresIn.inSeconds,
  'refresh_token': refreshToken,
  'user': {
    'id': userId,
    'aud': 'authenticated',
    'role': 'authenticated',
    'is_anonymous': true,
    'created_at': '2026-10-24T00:00:00Z',
    'app_metadata': <String, Object>{},
    'user_metadata': <String, Object>{},
  },
};

class _Server {
  int signups = 0;
  int refreshes = 0;
  final rpcCalls = <String, Map<String, dynamic>>{};
  final authHeaders = <String>[];

  http.Response Function(String name) rpc = (_) =>
      http.Response(jsonEncode({'ok': true}), 200);

  String validRefresh = 'rt-1';
  bool offline = false;

  late final client = MockClient((req) async {
    final res = await _handle(req);
    return http.Response.bytes(
      res.bodyBytes,
      res.statusCode,
      headers: res.headers,
      request: req,
    );
  });

  Future<http.Response> _handle(http.Request req) async {
    if (offline) throw http.ClientException('no internet', req.url);
    final path = req.url.path;
    if (path == '/auth/v1/signup') {
      signups++;
      return _json(_session('user-$signups', 'rt-new-$signups'));
    }
    if (path == '/auth/v1/token') {
      refreshes++;
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      if (body['refresh_token'] != validRefresh) {
        return _json({
          'code': 400,
          'error_code': 'refresh_token_not_found',
          'msg': 'Invalid Refresh Token: Refresh Token Not Found',
        }, 400);
      }
      return _json(_session('user-old', 'rt-2'));
    }
    if (path.startsWith('/rest/v1/rpc/')) {
      final name = path.substring('/rest/v1/rpc/'.length);
      rpcCalls[name] = jsonDecode(req.body) as Map<String, dynamic>;
      authHeaders.add(req.headers['Authorization'] ?? '');
      return rpc(name);
    }
    return http.Response('not found', 404);
  }

  static http.Response _json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  late _Server server;
  late _MemoryStore store;
  final apis = <SupabaseSyncApi>[];

  SupabaseSyncApi newApi() {
    final api = SupabaseSyncApi(
      _config,
      store: store,
      httpClient: server.client,
    );
    apis.add(api);
    return api;
  }

  setUp(() {
    server = _Server();
    store = _MemoryStore();
  });

  tearDown(() async {
    for (final api in apis) {
      await api.dispose();
    }
    apis.clear();
  });

  Future<SyncError?> errorOf(Future<void> Function() call) async {
    try {
      await call();
      return null;
    } on SyncApiException catch (e) {
      return e.error;
    }
  }

  group('الهوية المجهولة', () {
    test('أول دخول ينشئ هوية ويحفظ جلستها', () async {
      await newApi().ensureSignedIn();
      expect(server.signups, 1);
      expect(jsonDecode(store.value!)['refresh_token'], 'rt-new-1');
    });

    test('فتح التطبيق ثانية يستعمل الهوية المحفوظة ولا ينشئ غيرها', () async {
      await newApi().ensureSignedIn();
      await newApi().ensureSignedIn();
      expect(server.signups, 1);
    });

    test('جلسة منتهية تُجدَّد، ورمز التجديد الجديد يُحفظ', () async {
      store.value = jsonEncode(
        _session('user-old', 'rt-1', expiresIn: const Duration(hours: -1)),
      );
      await newApi().ensureSignedIn();
      expect(server.refreshes, 1);
      expect(server.signups, 0);
      expect(jsonDecode(store.value!)['refresh_token'], 'rt-2');
    });

    test('رمز تجديد ملغى: هوية جديدة بدل التوقف', () async {
      store.value = jsonEncode(
        _session('user-old', 'revoked', expiresIn: const Duration(hours: -1)),
      );
      await newApi().ensureSignedIn();
      expect(server.signups, 1);
      expect(jsonDecode(store.value!)['refresh_token'], 'rt-new-1');
    });

    test('انقطاع أثناء التجديد: لا هوية جديدة، والجلسة المحفوظة تبقى', () async {
      final saved = jsonEncode(
        _session('user-old', 'rt-1', expiresIn: const Duration(hours: -1)),
      );
      store.value = saved;
      server.offline = true;
      expect(await errorOf(newApi().ensureSignedIn), SyncError.network);
      expect(server.signups, 0);
      expect(store.value, saved);
    });

    test('دون إنترنت في أول مرة: انقطاع لا خطأ', () async {
      server.offline = true;
      expect(await errorOf(newApi().ensureSignedIn), SyncError.network);
      expect(store.value, isNull);
    });

    test('دخولان في الوقت نفسه = هوية واحدة', () async {
      final api = newApi();
      await Future.wait([api.ensureSignedIn(), api.ensureSignedIn()]);
      expect(server.signups, 1);
    });
  });

  group('دوال الخادم', () {
    test('تُستدعى بأسماء المعاملات في العقد وبرمز الهوية', () async {
      final api = newApi();
      await api.ensureSignedIn();
      await api.pullChanges('p1', 42, limit: 100);
      await api.restoreProfile('RZ-7K4M-9P2Q', cancelDeletion: true);
      await api.requestDeletion('p1', 'RZ-7K4M-9P2Q');
      await api.uploadBatch({'profile_id': 'p1'});

      expect(server.rpcCalls['pull_changes'], {
        'p_profile_id': 'p1',
        'p_cursor': 42,
        'p_limit': 100,
      });
      expect(server.rpcCalls['restore_profile'], {
        'p_code': 'RZ-7K4M-9P2Q',
        'p_cancel_deletion': true,
      });
      expect(server.rpcCalls['request_deletion'], {
        'p_profile_id': 'p1',
        'p_code': 'RZ-7K4M-9P2Q',
      });
      expect(server.rpcCalls['upload_batch'], {
        'p_batch': {'profile_id': 'p1'},
      });
      expect(server.authHeaders, hasLength(4));
      expect(server.authHeaders, everyElement(startsWith('Bearer eyJ')));
    });

    test('فك الربط يقبل ردًا فارغًا', () async {
      server.rpc = (_) => http.Response('', 204);
      final api = newApi();
      await api.ensureSignedIn();
      await api.unlinkDevice('p1');
      expect(server.rpcCalls.containsKey('unlink_device'), isTrue);
    });

    test('أخطاء الخادم RZ تصل كما في جدول الأخطاء', () async {
      final api = newApi();
      await api.ensureSignedIn();
      for (final (code, error) in [
        ('RZ403', SyncError.notLinked),
        ('RZ404', SyncError.profileUnknown),
        ('RZ409', SyncError.studentCodeTaken),
        ('RZ410', SyncError.profileDeleted),
        ('RZ413', SyncError.batchTooLarge),
      ]) {
        server.rpc = (_) => _Server._json({
          'code': code,
          'details': null,
          'hint': null,
          'message': 'x',
        }, 400);
        expect(await errorOf(() => api.pullChanges('p1', 0)), error, reason: code);
      }
    });

    test('بلا صلاحية = إعادة الدخول، لا خطأ دائم', () async {
      final api = newApi();
      await api.ensureSignedIn();
      server.rpc = (_) => _Server._json({
        'code': '42501',
        'message': 'permission denied for function pull_changes',
      }, 401);
      expect(
        await errorOf(() => api.pullChanges('p1', 0)),
        SyncError.notAuthenticated,
      );
    });

    test('الخادم متوقف أو الإنترنت مقطوع = انقطاع يُعاد لاحقًا', () async {
      final api = newApi();
      await api.ensureSignedIn();
      server.rpc = (_) => http.Response('<html>bad gateway</html>', 503);
      expect(await errorOf(() => api.pullChanges('p1', 0)), SyncError.network);

      server.offline = true;
      expect(
        await errorOf(() => api.uploadBatch({'profile_id': 'p1'})),
        SyncError.network,
      );
    });

    test('طلب يتجاوز حد الانتظار = انقطاع', () async {
      final slow = MockClient((req) async {
        if (req.url.path == '/auth/v1/signup') {
          return _Server._json(_session('u', 'rt'));
        }
        await Future<void>.delayed(const Duration(seconds: 5));
        return http.Response('{}', 200);
      });
      final api = SupabaseSyncApi(
        _config,
        store: store,
        httpClient: slow,
        timeout: const Duration(milliseconds: 50),
      );
      apis.add(api);
      await api.ensureSignedIn();
      expect(await errorOf(() => api.pullChanges('p1', 0)), SyncError.network);
    });
  });
}
