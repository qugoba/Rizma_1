import 'package:rizma/core/utils/student_code.dart';
import 'package:rizma/features/sync/sync_api.dart';

class FakeSyncServer {
  int _seq = 0;
  int _nextSeq() => ++_seq;

  final profiles = <String, Map<String, dynamic>>{};
  final links = <(String profileId, String userId)>{};
  final attempts = <String, Map<String, dynamic>>{};
  final owned = <(String, String), Map<String, dynamic>>{};
  final parts = <(String, String, String), Map<String, dynamic>>{};
  final bookmarks = <(String, String), Map<String, dynamic>>{};

  final _codeFailures = <String, int>{};
  final _codeLockedUntil = <String, DateTime>{};
  final _deviceFailures = <String, int>{};
  final _deviceLockedUntil = <String, DateTime>{};

  int uploads = 0;

  FakeSyncApi device(String userId) => FakeSyncApi(this, userId);

  static String _now() => DateTime.now().toUtc().toIso8601String();

  void _assertAccess(String profileId, String userId) {
    final p = profiles[profileId];
    if (p == null) throw const SyncApiException(SyncError.profileUnknown);
    if (p['deletion_requested_at'] != null) {
      throw const SyncApiException(SyncError.profileDeleted);
    }
    if (!links.contains((profileId, userId))) {
      throw const SyncApiException(SyncError.notLinked);
    }
  }

  Map<String, dynamic> _profileJson(Map<String, dynamic> p) => {
    for (final k in [
      'id',
      'student_code',
      'grade',
      'color',
      'class_code',
      'equipped',
      'created_at',
      'revision',
      'server_seq',
      'server_received_at',
    ])
      k: p[k],
  };

  Map<String, dynamic> upload(String userId, Map<String, dynamic> batch) {
    uploads++;
    final pid = batch['profile_id'] as String;
    final profile = (batch['profile'] as Map?)?.cast<String, dynamic>();
    List<Map<String, dynamic>> list(String k) => [
      for (final e in batch[k] as List? ?? const [])
        (e as Map).cast<String, dynamic>(),
    ];
    final att = list('attempts');
    final own = list('owned_items');
    final prt = list('lesson_parts');
    final bms = list('bookmarks');
    if (att.length + own.length + prt.length + bms.length > maxBatchRows) {
      throw const SyncApiException(SyncError.batchTooLarge);
    }

    Map<String, dynamic>? profileResult;
    final current = profiles[pid];
    if (current == null) {
      if (profile == null) {
        throw const SyncApiException(SyncError.profileUnknown);
      }
      if (profiles.values.any(
        (p) => p['student_code'] == profile['student_code'],
      )) {
        throw const SyncApiException(SyncError.studentCodeTaken);
      }
      profiles[pid] = {
        'id': pid,
        'student_code': profile['student_code'],
        'grade': profile['grade'],
        'color': profile['color'],
        'class_code': profile['class_code'],
        'equipped': profile['equipped'] ?? '',
        'created_at': profile['created_at'],
        'revision': 1,
        'server_seq': _nextSeq(),
        'server_received_at': _now(),
        'deletion_requested_at': null,
      };
      links.add((pid, userId));
      profileResult = {'status': 'created', 'revision': 1};
    } else {
      _assertAccess(pid, userId);
      if (profile != null) {
        if (profile['base_revision'] == current['revision']) {
          current
            ..['grade'] = profile['grade']
            ..['color'] = profile['color']
            ..['class_code'] = profile['class_code']
            ..['equipped'] = profile['equipped'] ?? ''
            ..['revision'] = (current['revision'] as int) + 1
            ..['server_seq'] = _nextSeq()
            ..['server_received_at'] = _now();
          profileResult = {
            'status': 'updated',
            'revision': current['revision'],
          };
        } else {
          profileResult = {
            'status': 'conflict',
            'revision': current['revision'],
            'profile': _profileJson(current),
          };
        }
      }
    }

    for (final a in att) {
      attempts.putIfAbsent(
        a['id'] as String,
        () => {
          ...a,
          'profile_id': pid,
          'server_seq': _nextSeq(),
          'server_received_at': _now(),
        },
      );
    }
    for (final o in own) {
      owned.putIfAbsent((
        pid,
        o['item_id'] as String,
      ), () => {...o, 'server_seq': _nextSeq(), 'server_received_at': _now()});
    }
    for (final l in prt) {
      parts.putIfAbsent((
        pid,
        l['lesson_id'] as String,
        l['part'] as String,
      ), () => {...l, 'server_seq': _nextSeq(), 'server_received_at': _now()});
    }
    for (final b in bms) {
      bookmarks[(pid, b['lesson_id'] as String)] = {
        ...b,
        'server_seq': _nextSeq(),
        'server_received_at': _now(),
      };
    }

    return {
      'profile': profileResult,
      'accepted': {
        'attempts': [
          for (final a in att)
            if (attempts[a['id']]?['profile_id'] == pid) a['id'],
        ],
        'owned_items': [for (final o in own) o['item_id']],
        'lesson_parts': [
          for (final l in prt) {'lesson_id': l['lesson_id'], 'part': l['part']},
        ],
        'bookmarks': {for (final b in bms) b['lesson_id']}.toList(),
      },
    };
  }

  Map<String, dynamic> pull(String userId, String pid, int cursor, int limit) {
    _assertAccess(pid, userId);
    final rows = <(int, String, Map<String, dynamic>)>[
      if ((profiles[pid]!['server_seq'] as int) > cursor)
        (profiles[pid]!['server_seq'] as int, 'profile', profiles[pid]!),
      for (final a in attempts.values)
        if (a['profile_id'] == pid && (a['server_seq'] as int) > cursor)
          (a['server_seq'] as int, 'attempts', a),
      for (final e in owned.entries)
        if (e.key.$1 == pid && (e.value['server_seq'] as int) > cursor)
          (e.value['server_seq'] as int, 'owned_items', e.value),
      for (final e in parts.entries)
        if (e.key.$1 == pid && (e.value['server_seq'] as int) > cursor)
          (e.value['server_seq'] as int, 'lesson_parts', e.value),
      for (final e in bookmarks.entries)
        if (e.key.$1 == pid && (e.value['server_seq'] as int) > cursor)
          (e.value['server_seq'] as int, 'bookmarks', e.value),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final page = rows.take(limit).toList();
    final out = <String, dynamic>{
      'profile': null,
      'attempts': <Map<String, dynamic>>[],
      'owned_items': <Map<String, dynamic>>[],
      'lesson_parts': <Map<String, dynamic>>[],
      'bookmarks': <Map<String, dynamic>>[],
      'next_cursor': page.isEmpty ? cursor : page.last.$1,
      'has_more': rows.length > page.length,
    };
    for (final (_, kind, row) in page) {
      if (kind == 'profile') {
        out['profile'] = _profileJson(row);
      } else {
        (out[kind] as List).add(
          Map<String, dynamic>.of(row)..remove('profile_id'),
        );
      }
    }
    return out;
  }

  Map<String, dynamic> restore(String userId, String code, bool cancel) {
    final now = DateTime.now();
    final normalized = StudentCode.normalize(code);
    final deviceLock = _deviceLockedUntil[userId];
    if (deviceLock != null && deviceLock.isAfter(now)) {
      return {
        'status': 'device_locked',
        'retry_at': deviceLock.toUtc().toIso8601String(),
      };
    }
    void deviceFailure() {
      final n = (_deviceFailures[userId] ?? 0) + 1;
      _deviceFailures[userId] = n;
      if (n >= 10) {
        _deviceLockedUntil[userId] = now.add(const Duration(hours: 1));
        _deviceFailures[userId] = 0;
      }
    }

    final codeLock = _codeLockedUntil[normalized];
    if (codeLock != null && codeLock.isAfter(now)) {
      deviceFailure();
      return {
        'status': 'code_locked',
        'retry_at': codeLock.toUtc().toIso8601String(),
      };
    }
    final p = profiles.values
        .where((p) => p['student_code'] == normalized)
        .firstOrNull;
    if (p == null) {
      final n = (_codeFailures[normalized] ?? 0) + 1;
      _codeFailures[normalized] = n;
      if (n >= 5) {
        _codeLockedUntil[normalized] = now.add(const Duration(minutes: 15));
        _codeFailures[normalized] = 0;
      }
      deviceFailure();
      return {'status': 'wrong_code'};
    }
    _codeFailures.remove(normalized);
    if (p['deletion_requested_at'] != null) {
      if (!cancel) {
        return {'status': 'pending_deletion', 'profile_id': p['id']};
      }
      p['deletion_requested_at'] = null;
    }
    links.add((p['id'] as String, userId));
    return {'status': 'restored', 'profile_id': p['id']};
  }

  Map<String, dynamic> requestDeletion(String userId, String pid, String code) {
    _assertAccess(pid, userId);
    if (profiles[pid]!['student_code'] != StudentCode.normalize(code)) {
      return {'status': 'wrong_code'};
    }
    profiles[pid]!['deletion_requested_at'] = _now();
    return {'status': 'deletion_requested'};
  }
}

class FakeSyncApi implements SyncApi {
  FakeSyncApi(this.server, this.userId);

  final FakeSyncServer server;
  final String userId;

  bool offline = false;

  int? failUploadsAfter;
  int _uploadsDone = 0;

  Future<void> Function()? whileUploading;

  void _network() {
    if (offline) throw const SyncApiException(SyncError.network);
  }

  @override
  Future<void> ensureSignedIn() async => _network();

  @override
  Future<Map<String, dynamic>> uploadBatch(Map<String, dynamic> batch) async {
    _network();
    if (failUploadsAfter != null && _uploadsDone >= failUploadsAfter!) {
      throw const SyncApiException(SyncError.network);
    }
    final res = server.upload(userId, batch);
    _uploadsDone++;
    await whileUploading?.call();
    return res;
  }

  @override
  Future<Map<String, dynamic>> pullChanges(
    String profileId,
    int cursor, {
    int limit = 500,
  }) async {
    _network();
    return server.pull(userId, profileId, cursor, limit);
  }

  @override
  Future<Map<String, dynamic>> restoreProfile(
    String code, {
    bool cancelDeletion = false,
  }) async {
    _network();
    return server.restore(userId, code, cancelDeletion);
  }

  @override
  Future<Map<String, dynamic>> requestDeletion(
    String profileId,
    String code,
  ) async {
    _network();
    return server.requestDeletion(userId, profileId, code);
  }

  @override
  Future<void> unlinkDevice(String profileId) async {
    _network();
    server.links.remove((profileId, userId));
  }
}
