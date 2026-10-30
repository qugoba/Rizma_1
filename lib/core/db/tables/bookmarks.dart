import 'package:drift/drift.dart';

import 'profiles.dart';

class Bookmarks extends Table {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get lessonId => text()();

  DateTimeColumn get removedAt => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get localVersion => integer().withDefault(const Constant(0))();

  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {profileId, lessonId};
}
