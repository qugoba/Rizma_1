import 'package:drift/drift.dart';

import 'profiles.dart';

@DataClassName('OwnedItem')
class OwnedItems extends Table {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemId => text()();
  IntColumn get cost => integer()();
  DateTimeColumn get acquiredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {profileId, itemId};
}
