import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/utils/student_code.dart';
import 'sync_api.dart';

enum SyncOutcome {
  done,

  offline,

  needsRestore,

  removed,

  failed,
}

enum RestoreStatus {
  restored,
  wrongCode,
  codeLocked,
  deviceLocked,
  pendingDeletion,
  offline,
}

class RestoreResult {
  const RestoreResult(this.status, {this.profileId, this.retryAt});

  final RestoreStatus status;
  final String? profileId;

  final DateTime? retryAt;
}

class SyncService {
  SyncService(
    this._db,
    this._api, {
    required Future<void> Function(String profileId) recompute,
    required Future<void> Function(String profileId) removeLocal,
    DateTime Function()? now,
  }) : _recompute = recompute,
       _removeLocal = removeLocal,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final SyncApi _api;
  final Future<void> Function(String profileId) _recompute;
  final Future<void> Function(String profileId) _removeLocal;
  final DateTime Function() _now;

  static String cursorKey(String profileId) => 'sync.cursor.$profileId';

  static String baseKey(String profileId) => 'sync.base.$profileId';

  Future<SyncOutcome> syncProfile(String profileId) =>
      _syncProfile(profileId, retried: false);

  Future<SyncOutcome> _syncProfile(
    String profileId, {
    required bool retried,
  }) async {
    try {
      await _api.ensureSignedIn();
      await _uploadAll(profileId);
      if (await _pullAll(profileId)) await _recompute(profileId);
      return SyncOutcome.done;
    } on SyncApiException catch (e) {
      switch (e.error) {
        case SyncError.network:
          return SyncOutcome.offline;
        case SyncError.notLinked:
          return SyncOutcome.needsRestore;
        case SyncError.profileDeleted:
          await _removeLocal(profileId);
          await _forget(profileId);
          return SyncOutcome.removed;
        case SyncError.profileUnknown when !retried:
          await _markAllUnsynced(profileId);
          return _syncProfile(profileId, retried: true);
        default:
          return SyncOutcome.failed;
      }
    }
  }

  Future<Map<String, SyncOutcome>> syncAll() async {
    final result = <String, SyncOutcome>{};
    for (final p in await _db.profilesDao.getAll()) {
      result[p.id] = await syncProfile(p.id);
      if (result[p.id] == SyncOutcome.offline) break;
    }
    return result;
  }

  Future<void> _uploadAll(String profileId) async {
    for (var round = 0; round < 3; round++) {
      final profile = await _db.profilesDao.getById(profileId);
      if (profile == null) return;
      final rows = await _pendingRows(profileId);
      final sendProfile = profile.syncedAt == null;
      if (!sendProfile && rows.isEmpty) return;

      final batches = _split(rows);
      if (batches.isEmpty) batches.add([]);
      var retry = false;
      for (final (i, batch) in batches.indexed) {
        final current = (await _db.profilesDao.getById(profileId))!;
        final withProfile = i == 0 && current.syncedAt == null;
        final payload = _batchPayload(current, batch, withProfile: withProfile);
        final Map<String, dynamic> res;
        try {
          res = await _api.uploadBatch(payload);
        } on SyncApiException catch (e) {
          if (e.error == SyncError.profileUnknown) {
            await _markAllUnsynced(profileId);
            retry = true;
            break;
          }
          if (e.error == SyncError.studentCodeTaken) {
            await _replaceStudentCode(profileId);
            retry = true;
            break;
          }
          rethrow;
        }
        final conflict = await _applyUploadResult(
          profileId,
          res,
          sentProfile: withProfile ? current : null,
          sentBookmarks: {
            for (final r in batch)
              if (r is _BookmarkRow) r.row.lessonId: r.row.localVersion,
          },
        );
        if (conflict) {
          retry = true;
          break;
        }
      }
      if (!retry) return;
    }
  }

  Future<List<_Row>> _pendingRows(String profileId) async {
    final attempts =
        await (_db.select(_db.attempts)
              ..where(
                (a) => a.profileId.equals(profileId) & a.syncedAt.isNull(),
              )
              ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
            .get();
    final owned = await (_db.select(
      _db.ownedItems,
    )..where((o) => o.profileId.equals(profileId) & o.syncedAt.isNull())).get();
    final parts = await (_db.select(
      _db.lessonPartProgress,
    )..where((p) => p.profileId.equals(profileId) & p.syncedAt.isNull())).get();
    final bookmarks = await (_db.select(
      _db.bookmarks,
    )..where((b) => b.profileId.equals(profileId) & b.syncedAt.isNull())).get();
    return [
      for (final a in attempts) _AttemptRow(a),
      for (final o in owned) _OwnedRow(o),
      for (final p in parts) _PartRow(p),
      for (final b in bookmarks) _BookmarkRow(b),
    ];
  }

  static List<List<_Row>> _split(List<_Row> rows) {
    final batches = <List<_Row>>[];
    var current = <_Row>[];
    var bytes = 0;
    for (final r in rows) {
      final size = utf8.encode(jsonEncode(r.toJson())).length;
      if (current.isNotEmpty &&
          (current.length >= maxBatchRows || bytes + size > maxBatchBytes)) {
        batches.add(current);
        current = [];
        bytes = 0;
      }
      current.add(r);
      bytes += size;
    }
    if (current.isNotEmpty) batches.add(current);
    return batches;
  }

  static Map<String, dynamic> _profileJson(Profile p) => {
    'base_revision': p.revision,
    'student_code': p.studentCode,
    'grade': p.grade,
    'color': p.color.name,
    'class_code': p.classCode,
    'equipped': p.equipped,
    'created_at': p.createdAt.toUtc().toIso8601String(),
  };

  Map<String, dynamic> _batchPayload(
    Profile profile,
    List<_Row> batch, {
    required bool withProfile,
  }) => {
    'profile_id': profile.id,
    if (withProfile) 'profile': _profileJson(profile),
    'attempts': [
      for (final r in batch)
        if (r is _AttemptRow) r.toJson(),
    ],
    'owned_items': [
      for (final r in batch)
        if (r is _OwnedRow) r.toJson(),
    ],
    'lesson_parts': [
      for (final r in batch)
        if (r is _PartRow) r.toJson(),
    ],
    'bookmarks': [
      for (final r in batch)
        if (r is _BookmarkRow) r.toJson(),
    ],
  };

  Future<bool> _applyUploadResult(
    String profileId,
    Map<String, dynamic> res, {
    required Profile? sentProfile,
    required Map<String, int> sentBookmarks,
  }) {
    return _db.transaction(() async {
      final now = _now();
      final accepted = (res['accepted'] as Map?)?.cast<String, dynamic>() ?? {};
      var conflict = false;

      final profileResult = (res['profile'] as Map?)?.cast<String, dynamic>();
      if (profileResult != null && sentProfile != null) {
        final status = profileResult['status'] as String;
        final revision = profileResult['revision'] as int;
        if (status == 'conflict') {
          await _mergeConflict(
            profileId,
            (profileResult['profile'] as Map).cast<String, dynamic>(),
          );
          conflict = true;
        } else {
          final current = (await _db.profilesDao.getById(profileId))!;
          final unchanged = current.localVersion == sentProfile.localVersion;
          await (_db.update(
            _db.profiles,
          )..where((p) => p.id.equals(profileId))).write(
            ProfilesCompanion(
              revision: Value(revision),
              syncedAt: unchanged ? Value(now) : const Value.absent(),
            ),
          );
          await _writeBase(profileId, {
            ..._profileJson(sentProfile),
            'revision': revision,
          });
        }
      }

      final attemptIds = [
        for (final id in accepted['attempts'] as List? ?? const []) '$id',
      ];
      if (attemptIds.isNotEmpty) {
        await (_db.update(_db.attempts)..where(
              (a) => a.profileId.equals(profileId) & a.id.isIn(attemptIds),
            ))
            .write(AttemptsCompanion(syncedAt: Value(now)));
      }
      final itemIds = [
        for (final id in accepted['owned_items'] as List? ?? const []) '$id',
      ];
      if (itemIds.isNotEmpty) {
        await (_db.update(_db.ownedItems)..where(
              (o) => o.profileId.equals(profileId) & o.itemId.isIn(itemIds),
            ))
            .write(OwnedItemsCompanion(syncedAt: Value(now)));
      }
      for (final raw in accepted['lesson_parts'] as List? ?? const []) {
        final m = (raw as Map).cast<String, dynamic>();
        final part = LessonPart.values.byName(m['part'] as String);
        await (_db.update(_db.lessonPartProgress)..where(
              (p) =>
                  p.profileId.equals(profileId) &
                  p.lessonId.equals(m['lesson_id'] as String) &
                  p.part.equalsValue(part),
            ))
            .write(LessonPartProgressCompanion(syncedAt: Value(now)));
      }
      for (final raw in accepted['bookmarks'] as List? ?? const []) {
        final lessonId = '$raw';
        final sentVersion = sentBookmarks[lessonId];
        if (sentVersion == null) continue;
        await (_db.update(_db.bookmarks)..where(
              (b) =>
                  b.profileId.equals(profileId) &
                  b.lessonId.equals(lessonId) &
                  b.localVersion.equals(sentVersion),
            ))
            .write(BookmarksCompanion(syncedAt: Value(now)));
      }
      return conflict;
    });
  }

  Future<void> _mergeConflict(
    String profileId,
    Map<String, dynamic> server,
  ) async {
    final local = (await _db.profilesDao.getById(profileId))!;
    final base = await _readBase(profileId);
    T pick<T>(String key, T localValue, T serverValue) {
      if (base == null) return localValue;
      return '$localValue' != '${base[key]}' ? localValue : serverValue;
    }

    final grade = pick('grade', local.grade, server['grade'] as int);
    final color = pick('color', local.color.name, server['color'] as String);
    final classCode = pick(
      'class_code',
      local.classCode,
      server['class_code'] as String?,
    );
    final equipped = pick(
      'equipped',
      local.equipped,
      (server['equipped'] as String?) ?? '',
    );
    await (_db.update(
      _db.profiles,
    )..where((p) => p.id.equals(profileId))).write(
      ProfilesCompanion(
        grade: Value(grade),
        color: Value(ProfileColor.values.byName(color)),
        classCode: Value(classCode),
        equipped: Value(equipped),
        revision: Value(server['revision'] as int),
        localVersion: Value(local.localVersion + 1),
        syncedAt: const Value(null),
      ),
    );
    await _writeBase(profileId, server);
  }

  Future<void> _markAllUnsynced(String profileId) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.profiles,
      )..where((p) => p.id.equals(profileId))).write(
        const ProfilesCompanion(revision: Value(0), syncedAt: Value(null)),
      );
      await (_db.update(_db.attempts)
            ..where((a) => a.profileId.equals(profileId)))
          .write(const AttemptsCompanion(syncedAt: Value(null)));
      await (_db.update(_db.ownedItems)
            ..where((o) => o.profileId.equals(profileId)))
          .write(const OwnedItemsCompanion(syncedAt: Value(null)));
      await (_db.update(_db.lessonPartProgress)
            ..where((p) => p.profileId.equals(profileId)))
          .write(const LessonPartProgressCompanion(syncedAt: Value(null)));
      await (_db.update(_db.bookmarks)
            ..where((b) => b.profileId.equals(profileId)))
          .write(const BookmarksCompanion(syncedAt: Value(null)));
      await _db.settingsDao.remove(cursorKey(profileId));
      await _db.settingsDao.remove(baseKey(profileId));
    });
  }

  Future<void> _replaceStudentCode(String profileId) async {
    final code = await StudentCode.generateUnique(
      (c) async => await _db.profilesDao.getByStudentCode(c) != null,
    );
    await (_db.update(_db.profiles)..where((p) => p.id.equals(profileId)))
        .write(ProfilesCompanion(studentCode: Value(code)));
  }

  Future<bool> _pullAll(String profileId) async {
    var cursor =
        int.tryParse(await _db.settingsDao.read(cursorKey(profileId)) ?? '') ??
        0;
    var progressChanged = false;
    while (true) {
      final page = await _api.pullChanges(profileId, cursor);
      progressChanged |= await _db.transaction(() async {
        final changed = await _applyPage(profileId, page);
        cursor = (page['next_cursor'] as num).toInt();
        await _db.settingsDao.write(cursorKey(profileId), '$cursor');
        return changed;
      });
      if (page['has_more'] != true) return progressChanged;
    }
  }

  Future<bool> _applyPage(String profileId, Map<String, dynamic> page) async {
    final now = _now();
    var progressChanged = false;

    final server = (page['profile'] as Map?)?.cast<String, dynamic>();
    if (server != null) {
      final local = await _db.profilesDao.getById(profileId);
      final revision = server['revision'] as int;
      if (local != null &&
          revision > local.revision &&
          local.syncedAt != null) {
        await (_db.update(
          _db.profiles,
        )..where((p) => p.id.equals(profileId))).write(
          ProfilesCompanion(
            grade: Value(server['grade'] as int),
            color: Value(ProfileColor.values.byName(server['color'] as String)),
            classCode: Value(server['class_code'] as String?),
            equipped: Value((server['equipped'] as String?) ?? ''),
            revision: Value(revision),
            syncedAt: Value(now),
          ),
        );
        await _writeBase(profileId, server);
      }
    }

    for (final raw in page['attempts'] as List? ?? const []) {
      final a = (raw as Map).cast<String, dynamic>();
      final id = a['id'] as String;
      final received = _date(a['server_received_at']);
      final exists = await (_db.select(
        _db.attempts,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (exists == null) {
        await _db
            .into(_db.attempts)
            .insert(
              AttemptsCompanion.insert(
                id: id,
                profileId: profileId,
                activityId: a['activity_id'] as String,
                kind: AttemptKind.values.byName(a['kind'] as String),
                score: a['score'] as int,
                total: a['total'] as int,
                starsEarned: Value(a['stars_earned'] as int),
                hintsUsed: Value(a['hints_used'] as int),
                detailsJson: Value(
                  a['details'] == null ? null : jsonEncode(a['details']),
                ),
                createdAt: _date(a['created_at'])!,
                syncedAt: Value(now),
                serverReceivedAt: Value(received),
              ),
            );
        progressChanged = true;
      } else if (exists.serverReceivedAt == null) {
        await (_db.update(_db.attempts)..where((r) => r.id.equals(id))).write(
          AttemptsCompanion(serverReceivedAt: Value(received)),
        );
      }
    }

    for (final raw in page['owned_items'] as List? ?? const []) {
      final o = (raw as Map).cast<String, dynamic>();
      await _db
          .into(_db.ownedItems)
          .insert(
            OwnedItemsCompanion.insert(
              profileId: profileId,
              itemId: o['item_id'] as String,
              cost: o['cost'] as int,
              acquiredAt: _date(o['acquired_at'])!,
              syncedAt: Value(now),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    for (final raw in page['lesson_parts'] as List? ?? const []) {
      final l = (raw as Map).cast<String, dynamic>();
      final inserted = await _db
          .into(_db.lessonPartProgress)
          .insert(
            LessonPartProgressCompanion.insert(
              profileId: profileId,
              lessonId: l['lesson_id'] as String,
              part: LessonPart.values.byName(l['part'] as String),
              completedAt: _date(l['completed_at'])!,
              syncedAt: Value(now),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) progressChanged = true;
    }

    for (final raw in page['bookmarks'] as List? ?? const []) {
      final b = (raw as Map).cast<String, dynamic>();
      final lessonId = b['lesson_id'] as String;
      final local =
          await (_db.select(_db.bookmarks)..where(
                (r) =>
                    r.profileId.equals(profileId) & r.lessonId.equals(lessonId),
              ))
              .getSingleOrNull();
      if (local != null && local.syncedAt == null) continue;
      await _db
          .into(_db.bookmarks)
          .insertOnConflictUpdate(
            BookmarksCompanion.insert(
              profileId: profileId,
              lessonId: lessonId,
              removedAt: Value(_date(b['removed_at'])),
              updatedAt: _date(b['updated_at'])!,
              localVersion: Value(local?.localVersion ?? 0),
              syncedAt: Value(now),
            ),
          );
    }
    return progressChanged;
  }

  Future<RestoreResult> restore(
    String code, {
    bool cancelDeletion = false,
  }) async {
    final Map<String, dynamic> res;
    try {
      await _api.ensureSignedIn();
      res = await _api.restoreProfile(
        StudentCode.normalize(code),
        cancelDeletion: cancelDeletion,
      );
    } on SyncApiException catch (e) {
      if (e.error == SyncError.network) {
        return const RestoreResult(RestoreStatus.offline);
      }
      rethrow;
    }
    final status = switch (res['status']) {
      'restored' => RestoreStatus.restored,
      'code_locked' => RestoreStatus.codeLocked,
      'device_locked' => RestoreStatus.deviceLocked,
      'pending_deletion' => RestoreStatus.pendingDeletion,
      _ => RestoreStatus.wrongCode,
    };
    return RestoreResult(
      status,
      profileId: res['profile_id'] as String?,
      retryAt: _date(res['retry_at']),
    );
  }

  Future<String> completeRestore({
    required String profileId,
    required String name,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty || cleanName.length > 40) {
      throw ArgumentError.value(name, 'name');
    }

    final pages = <Map<String, dynamic>>[];
    var cursor = 0;
    Map<String, dynamic>? server;
    while (true) {
      final page = await _api.pullChanges(profileId, cursor);
      pages.add(page);
      server ??= (page['profile'] as Map?)?.cast<String, dynamic>();
      cursor = (page['next_cursor'] as num).toInt();
      if (page['has_more'] != true) break;
    }
    if (server == null) {
      throw const SyncApiException(SyncError.profileUnknown);
    }
    final s = server;

    await _db.transaction(() async {
      final now = _now();
      if (await _db.profilesDao.getById(profileId) == null) {
        await _db.profilesDao.insertProfile(
          ProfilesCompanion.insert(
            id: profileId,
            name: cleanName,
            grade: s['grade'] as int,
            color: ProfileColor.values.byName(s['color'] as String),
            studentCode: s['student_code'] as String,
            classCode: Value(s['class_code'] as String?),
            equipped: Value((s['equipped'] as String?) ?? ''),
            createdAt: _date(s['created_at'])!,
            lastActiveAt: now,
            revision: Value(s['revision'] as int),
            syncedAt: Value(now),
          ),
        );
      }
      for (final page in pages) {
        await _applyPage(profileId, {...page, 'profile': null});
      }
      await _db.settingsDao.write(cursorKey(profileId), '$cursor');
      await _writeBase(profileId, s);
    });
    await _recompute(profileId);
    return profileId;
  }

  Future<bool> requestDeletion(String profileId, String code) async {
    final profile = await _db.profilesDao.getById(profileId);
    if (profile == null || profile.studentCode != StudentCode.normalize(code)) {
      return false;
    }
    await _api.ensureSignedIn();
    try {
      final res = await _api.requestDeletion(
        profileId,
        StudentCode.normalize(code),
      );
      return res['status'] == 'deletion_requested';
    } on SyncApiException catch (e) {
      if (e.error == SyncError.profileUnknown) return true;
      rethrow;
    }
  }

  Future<void> unlink(String profileId) async {
    try {
      await _api.ensureSignedIn();
      await _api.unlinkDevice(profileId);
    } on SyncApiException catch (e) {
      if (e.error != SyncError.network) rethrow;
    }
    await _forget(profileId);
  }

  Future<int> unsyncedResults(String profileId) async {
    final row = await _db
        .customSelect(
          'SELECT '
          '(SELECT COUNT(*) FROM attempts '
          ' WHERE profile_id = ?1 AND synced_at IS NULL) + '
          '(SELECT COUNT(*) FROM lesson_part_progress '
          ' WHERE profile_id = ?1 AND synced_at IS NULL) AS c',
          variables: [Variable.withString(profileId)],
        )
        .getSingle();
    return row.read<int>('c');
  }

  Future<void> _forget(String profileId) async {
    await _db.settingsDao.remove(cursorKey(profileId));
    await _db.settingsDao.remove(baseKey(profileId));
  }

  Future<Map<String, dynamic>?> _readBase(String profileId) async {
    final raw = await _db.settingsDao.read(baseKey(profileId));
    return raw == null
        ? null
        : (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  Future<void> _writeBase(String profileId, Map<String, dynamic> p) =>
      _db.settingsDao.write(
        baseKey(profileId),
        jsonEncode({
          'grade': p['grade'],
          'color': p['color'],
          'class_code': p['class_code'],
          'equipped': p['equipped'] ?? '',
          'revision': p['revision'] ?? p['base_revision'],
        }),
      );

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.parse(v as String);
}

sealed class _Row {
  Map<String, dynamic> toJson();
}

final class _AttemptRow extends _Row {
  _AttemptRow(this.row);
  final Attempt row;

  @override
  Map<String, dynamic> toJson() => {
    'id': row.id,
    'activity_id': row.activityId,
    'kind': row.kind.name,
    'score': row.score,
    'total': row.total,
    'stars_earned': row.starsEarned,
    'hints_used': row.hintsUsed,
    'details': row.detailsJson == null ? null : jsonDecode(row.detailsJson!),
    'created_at': row.createdAt.toUtc().toIso8601String(),
  };
}

final class _OwnedRow extends _Row {
  _OwnedRow(this.row);
  final OwnedItem row;

  @override
  Map<String, dynamic> toJson() => {
    'item_id': row.itemId,
    'cost': row.cost,
    'acquired_at': row.acquiredAt.toUtc().toIso8601String(),
  };
}

final class _PartRow extends _Row {
  _PartRow(this.row);
  final LessonPartEntry row;

  @override
  Map<String, dynamic> toJson() => {
    'lesson_id': row.lessonId,
    'part': row.part.name,
    'completed_at': row.completedAt.toUtc().toIso8601String(),
  };
}

final class _BookmarkRow extends _Row {
  _BookmarkRow(this.row);
  final Bookmark row;

  @override
  Map<String, dynamic> toJson() => {
    'lesson_id': row.lessonId,
    'removed_at': row.removedAt?.toUtc().toIso8601String(),
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
  };
}
