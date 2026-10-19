import 'package:drift/drift.dart';

import '../enums.dart';

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  // ignore: recursive_getters
  IntColumn get grade => integer().check(grade.isBetweenValues(1, 12))();
  TextColumn get color => textEnum<ProfileColor>()();

  TextColumn get pinHash => text().nullable()();
  TextColumn get pinSalt => text().nullable()();

  TextColumn get studentCode => text().unique()();
  TextColumn get classCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastActiveAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
