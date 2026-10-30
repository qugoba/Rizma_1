// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dao.dart';

// ignore_for_file: type=lint
mixin _$ActivityDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $LessonProgressTable get lessonProgress => attachedDatabase.lessonProgress;
  $LessonPartProgressTable get lessonPartProgress =>
      attachedDatabase.lessonPartProgress;
  $AttemptsTable get attempts => attachedDatabase.attempts;
  $ConceptMasteryTable get conceptMastery => attachedDatabase.conceptMastery;
  ActivityDaoManager get managers => ActivityDaoManager(this);
}

class ActivityDaoManager {
  final _$ActivityDaoMixin _db;
  ActivityDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(
        _db.attachedDatabase,
        _db.lessonProgress,
      );
  $$LessonPartProgressTableTableManager get lessonPartProgress =>
      $$LessonPartProgressTableTableManager(
        _db.attachedDatabase,
        _db.lessonPartProgress,
      );
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db.attachedDatabase, _db.attempts);
  $$ConceptMasteryTableTableManager get conceptMastery =>
      $$ConceptMasteryTableTableManager(
        _db.attachedDatabase,
        _db.conceptMastery,
      );
}
