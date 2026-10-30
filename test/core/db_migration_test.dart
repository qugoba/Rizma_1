import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/db/daos/settings_dao.dart';

import '../generated_migrations/schema.dart';
import '../generated_migrations/schema_v3.dart' as v3;
import '../generated_migrations/schema_v4.dart' as v4;
import '../generated_migrations/schema_v5.dart' as v5;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('تثبيت جديد على الإصدار 6 يطابق المخطط المحفوظ', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.validateDatabaseSchema();
  });

  test('من 3 إلى 6: لا يضيع شيء، والجداول الجديدة صحيحة', () async {
    final schema = await verifier.schemaAt(3);

    final old = v3.DatabaseAtV3(schema.newConnection());
    const t = 1792800000;
    for (final (id, code) in [
      ('anas', 'RZ-2345-6789'),
      ('layan', 'RZ-ABCD-EFGH'),
    ]) {
      await old
          .into(old.profiles)
          .insert(
            v3.ProfilesCompanion.insert(
              id: id,
              name: id,
              grade: 5,
              color: 'teal',
              studentCode: code,
              createdAt: t,
              lastActiveAt: t,
              revision: const Value(3),
              syncedAt: const Value(t),
            ),
          );
    }
    await old
        .into(old.attempts)
        .insert(
          v3.AttemptsCompanion.insert(
            id: '11111111-1111-4111-8111-111111111111',
            profileId: 'anas',
            activityId: 'math.u1.l1.practice',
            kind: 'practice',
            score: 4,
            total: 5,
            createdAt: t,
            syncedAt: const Value(t),
          ),
        );
    await old
        .into(old.bookmarks)
        .insert(
          v3.BookmarksCompanion.insert(
            profileId: 'anas',
            lessonId: 'math.u1.l2',
            updatedAt: t,
          ),
        );
    for (final (key, value) in [
      (SettingsDao.activeProfileKey, 'anas'),
      ('pref.anas.wifiOnly', 'false'),
      ('pref.anas.autoVideo', 'true'),
      ('pref.anas.fontSize', 'large'),
      ('pref.layan.wifiOnly', 'true'),
      ('sync.cursor.anas', '42'),
    ]) {
      await old
          .into(old.appSettings)
          .insert(v3.AppSettingsCompanion.insert(key: key, value: value));
    }
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);

    final profiles = await db.profilesDao.getAll();
    expect(profiles.map((p) => p.id), unorderedEquals(['anas', 'layan']));
    final anas = profiles.firstWhere((p) => p.id == 'anas');
    expect(anas.revision, 3);
    expect(anas.syncedAt, isNotNull);
    final attempts = await db.activityDao.getAttemptsInOrder('anas');
    expect(attempts.single.score, 4);
    expect(attempts.single.syncedAt, isNotNull, reason: 'لا يُعاد رفعها');
    expect(await db.profilesDao.watchBookmarks('anas').first, {'math.u1.l2'});

    final s = db.settingsDao;
    expect(await s.read(SettingsDao.wifiOnlyKey), 'false');
    expect(await s.read(SettingsDao.autoVideoKey), 'true');
    expect(await s.read('pref.anas.wifiOnly'), isNull);
    expect(await s.read('pref.anas.autoVideo'), isNull);
    expect(await s.read('pref.layan.wifiOnly'), isNull);
    expect(await s.read('pref.anas.fontSize'), 'large');
    expect(await s.read('sync.cursor.anas'), '42');
    expect(await s.read(SettingsDao.activeProfileKey), 'anas');

    expect(await db.contentDao.manifest(5), isNull);
    expect(await db.contentDao.nextDownload(), isNull);
  });

  test('من 3 إلى 6 بلا طالب نشط: الإعدادان على افتراضيهما', () async {
    final schema = await verifier.schemaAt(3);
    final old = v3.DatabaseAtV3(schema.newConnection());
    await old
        .into(old.appSettings)
        .insert(
          v3.AppSettingsCompanion.insert(
            key: 'pref.x.wifiOnly',
            value: 'false',
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);
    expect(await db.settingsDao.read(SettingsDao.wifiOnlyKey), isNull);
    expect(await db.settingsDao.read('pref.x.wifiOnly'), isNull);
  });

  test('من 4 إلى 6: الدروس المنزَّلة كما هي، والمرفقات فارغة', () async {
    final schema = await verifier.schemaAt(4);
    final old = v4.DatabaseAtV4(schema.newConnection());
    await old
        .into(old.contentLessons)
        .insert(
          v4.ContentLessonsCompanion.insert(
            lessonId: 'english.u1.l1',
            version: const Value(1),
            files: const Value('{"lesson.json":"aa"}'),
            videoSha256: const Value('bb'),
            videoSize: const Value(10),
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);

    final l = (await db.contentDao.lesson('english.u1.l1'))!;
    expect(l.version, 1);
    expect(l.files, '{"lesson.json":"aa"}');
    expect(l.videoSha256, 'bb');
    expect(l.attachments, isNull);
    expect(l.pendingAttachments, isNull);
  });

  test('من 5 إلى 6: الفهرس كما هو، وتوقيعه فارغ حتى الفحص التالي', () async {
    final schema = await verifier.schemaAt(5);
    final old = v5.DatabaseAtV5(schema.newConnection());
    await old
        .into(old.contentManifests)
        .insert(
          v5.ContentManifestsCompanion.insert(
            grade: const Value(5),
            sequence: 2,
            body: '{}',
            fetchedAt: 1792800000,
          ),
        );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);

    final m = (await db.contentDao.manifest(5))!;
    expect(m.sequence, 2);
    expect(m.signature, isNull);
  });
}
