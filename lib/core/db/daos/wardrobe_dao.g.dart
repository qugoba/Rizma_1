part of 'wardrobe_dao.dart';

// ignore_for_file: type=lint
mixin _$WardrobeDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $OwnedItemsTable get ownedItems => attachedDatabase.ownedItems;
  WardrobeDaoManager get managers => WardrobeDaoManager(this);
}

class WardrobeDaoManager {
  final _$WardrobeDaoMixin _db;
  WardrobeDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$OwnedItemsTableTableManager get ownedItems =>
      $$OwnedItemsTableTableManager(_db.attachedDatabase, _db.ownedItems);
}
