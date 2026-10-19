import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/activity_dao.dart';
import 'daos/profiles_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/wardrobe_dao.dart';
import 'enums.dart';
import 'tables/app_settings.dart';
import 'tables/attempts.dart';
import 'tables/concept_mastery.dart';
import 'tables/lesson_part_progress.dart';
import 'tables/lesson_progress.dart';
import 'tables/owned_items.dart';
import 'tables/profiles.dart';
import 'tables/sync_queue.dart';

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
    SyncQueue,
    AppSettings,
  ],
  daos: [ProfilesDao, ActivityDao, SettingsDao, WardrobeDao],
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(lessonPartProgress);
        await m.createTable(ownedItems);
        await m.addColumn(attempts, attempts.hintsUsed);
        await m.addColumn(attempts, attempts.detailsJson);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
