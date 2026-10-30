import 'package:drift/drift.dart';

import '../enums.dart';
import 'profiles.dart';

class Attempts extends Table {
  TextColumn get id => text()();
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get activityId => text()();
  TextColumn get kind => textEnum<AttemptKind>()();
  IntColumn get score => integer()();
  IntColumn get total => integer()();
  IntColumn get starsEarned => integer().withDefault(const Constant(0))();

  IntColumn get hintsUsed => integer().withDefault(const Constant(0))();

  TextColumn get detailsJson => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get syncedAt => dateTime().nullable()();

  DateTimeColumn get serverReceivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
