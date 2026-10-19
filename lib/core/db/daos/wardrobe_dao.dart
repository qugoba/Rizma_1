import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/owned_items.dart';

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [OwnedItems])
class WardrobeDao extends DatabaseAccessor<AppDatabase>
    with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  Stream<List<OwnedItem>> watchOwned(String profileId) {
    return (select(
      ownedItems,
    )..where((r) => r.profileId.equals(profileId))).watch();
  }

  Future<List<OwnedItem>> getOwned(String profileId) {
    return (select(
      ownedItems,
    )..where((r) => r.profileId.equals(profileId))).get();
  }

  Future<bool> insertPurchase({
    required String profileId,
    required String itemId,
    required int cost,
    required DateTime now,
  }) async {
    final rows = await into(ownedItems).insert(
      OwnedItemsCompanion.insert(
        profileId: profileId,
        itemId: itemId,
        cost: cost,
        acquiredAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    return rows > 0;
  }
}
