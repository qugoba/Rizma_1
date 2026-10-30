import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/activity_dao.dart';
import 'daos/content_dao.dart';
import 'daos/profiles_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/wardrobe_dao.dart';
import 'enums.dart';
import 'tables/app_settings.dart';
import 'tables/attempts.dart';
import 'tables/bookmarks.dart';
import 'tables/concept_mastery.dart';
import 'tables/content.dart';
import 'tables/lesson_part_progress.dart';
import 'tables/lesson_progress.dart';
import 'tables/owned_items.dart';
import 'tables/profiles.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    LessonProgress,
    LessonPartProgress,
    OwnedItems,
    Attempts,
    ConceptMastery,
    Bookmarks,
    AppSettings,
    ContentManifests,
    ContentLessons,
    ContentBlobs,
    ContentDownloads,
  ],
  daos: [ProfilesDao, ActivityDao, SettingsDao, WardrobeDao, ContentDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.onDevice()
    : super(
        driftDatabase(
          name: 'rizma',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        for (final table in allTables.toList().reversed) {
          await customStatement(
            'DROP TABLE IF EXISTS "${table.actualTableName}"',
          );
        }
        await customStatement('DROP TABLE IF EXISTS "sync_queue"');
        await m.createAll();
        return;
      }
      if (from < 4) {
        await m.createTable(contentManifests);
        await m.createTable(contentLessons);
        await m.createTable(contentBlobs);
        await m.createTable(contentDownloads);
        await _moveDownloadPrefsToDevice();
      }
      if (from == 4) {
        await m.addColumn(contentLessons, contentLessons.attachments);
        await m.addColumn(contentLessons, contentLessons.pendingAttachments);
      }
      if (from >= 4 && from < 6) {
        await m.addColumn(contentManifests, contentManifests.signature);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _moveDownloadPrefsToDevice() async {
    final active = await settingsDao.read(SettingsDao.activeProfileKey);
    if (active != null) {
      final prefix = SettingsDao.profilePrefsPrefix(active);
      for (final (from, to) in [
        ('${prefix}wifiOnly', SettingsDao.wifiOnlyKey),
        ('${prefix}autoVideo', SettingsDao.autoVideoKey),
      ]) {
        final value = await settingsDao.read(from);
        if (value != null) await settingsDao.write(to, value);
      }
    }
    await customStatement(
      "DELETE FROM app_settings WHERE key LIKE 'pref.%' "
      "AND (key LIKE '%.wifiOnly' OR key LIKE '%.autoVideo')",
    );
  }
}
