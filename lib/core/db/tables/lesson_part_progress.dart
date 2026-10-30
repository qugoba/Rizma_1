import 'package:drift/drift.dart';

import '../enums.dart';
import 'profiles.dart';

@DataClassName('LessonPartEntry')
class LessonPartProgress extends Table {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get lessonId => text()();
  TextColumn get part => textEnum<LessonPart>()();
  DateTimeColumn get completedAt => dateTime()();

  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {profileId, lessonId, part};
}
