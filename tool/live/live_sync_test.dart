import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/profiles/profile_repository.dart';
import 'package:rizma/features/sync/supabase_sync_api.dart';
import 'package:rizma/features/sync/sync_service.dart';

class _Phone {
  _Phone() {
    api = SupabaseSyncApi(
      ServerConfig.fromEnvironment()!,
      store: SettingsSessionStore(db.settingsDao),
    );
    sync = SyncService(
      db,
      api,
      recompute: (_) async {},
      removeLocal: (id) => ProfileRepository(db).delete(id),
    );
  }

  final db = AppDatabase(NativeDatabase.memory());
  late final SupabaseSyncApi api;
  late final SyncService sync;

  Future<void> close() async {
    await api.dispose();
    await db.close();
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('هاتفان على الخادم الحقيقي', () async {
    final a = _Phone();
    final b = _Phone();
    addTearDown(a.close);
    addTearDown(b.close);

    final p = await ProfileRepository(
      a.db,
    ).create(name: 'تجربة', grade: 5, color: ProfileColor.teal);
    await a.db.activityDao.insertAttempt(
      profileId: p.id,
      activityId: 'math.u1.l1.practice',
      kind: AttemptKind.practice,
      score: 4,
      total: 5,
      starsEarned: 12,
      now: DateTime.now(),
    );
    await a.db.profilesDao.setBookmark(
      profileId: p.id,
      lessonId: 'math.u1.l2',
      saved: true,
      now: DateTime.now(),
    );
    expect(await a.sync.syncProfile(p.id), SyncOutcome.done);
    final unsynced = await a.db.activityDao.watchUnsyncedAttempts(p.id).first;
    expect(unsynced, 0, reason: 'النتيجة عُلّمت مرفوعة');
    // ignore: avoid_print
    print('student code: ${p.studentCode}  profile: ${p.id}');

    expect(
      (await b.sync.restore('RZ-2222-2222')).status,
      RestoreStatus.wrongCode,
    );
    final r = await b.sync.restore(p.studentCode.toLowerCase());
    expect(r.status, RestoreStatus.restored);
    expect(r.profileId, p.id);
    await b.sync.completeRestore(profileId: p.id, name: 'تجربة');
    final restored = await b.db.profilesDao.getById(p.id);
    expect(restored!.grade, 5);
    expect(await b.db.activityDao.getAttemptsInOrder(p.id), hasLength(1));
    expect(await b.db.profilesDao.watchBookmarks(p.id).first, {'math.u1.l2'});

    await a.db.profilesDao.setGrade(p.id, 6);
    expect(await a.sync.syncProfile(p.id), SyncOutcome.done);
    expect(await b.sync.syncProfile(p.id), SyncOutcome.done);
    expect((await b.db.profilesDao.getById(p.id))!.grade, 6);

    await b.db.activityDao.insertAttempt(
      profileId: p.id,
      activityId: 'math.u1.l1.quiz',
      kind: AttemptKind.quiz,
      score: 5,
      total: 5,
      starsEarned: 0,
      now: DateTime.now(),
    );
    expect(await b.sync.syncProfile(p.id), SyncOutcome.done);
    expect(await a.sync.syncProfile(p.id), SyncOutcome.done);
    expect(await a.db.activityDao.getAttemptsInOrder(p.id), hasLength(2));

    expect(await b.sync.requestDeletion(p.id, p.studentCode), isTrue);
    expect(await a.sync.syncProfile(p.id), SyncOutcome.removed);
    expect(await a.db.profilesDao.getById(p.id), isNull);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
