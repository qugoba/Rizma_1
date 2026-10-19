import '../../core/db/app_database.dart';
import 'wardrobe_items.dart';

enum PurchaseResult {
  purchased,
  notEnoughStars,
  locked,
  alreadyOwned,
  unknownItem,
}

enum ItemState { equipped, owned, buyable, locked }

class WardrobeRepository {
  WardrobeRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static String _equippedKey(String profileId) => 'pref.$profileId.equipped';

  static Set<String> ownedIds(Iterable<OwnedItem> purchased) => {
    for (final i in wardrobeItems)
      if (i.isFree) i.id,
    for (final p in purchased) p.itemId,
  };

  static int balance({
    required int stars,
    required Iterable<OwnedItem> owned,
  }) => stars - owned.fold<int>(0, (s, o) => s + o.cost);

  static ItemState stateOf(
    WardrobeItem item, {
    required Set<String> owned,
    required Set<String> equipped,
    required bool lessonCompleted,
    required String currentColorItemId,
  }) {
    final isOwned =
        owned.contains(item.id) ||
        (item.unlock == Unlock.lessonCompleted &&
            lessonCompleted &&
            item.price == 0);
    if (isOwned) {
      final on = item.kind == WardrobeKind.color
          ? item.id == currentColorItemId
          : equipped.contains(item.id);
      return on ? ItemState.equipped : ItemState.owned;
    }
    if (item.unlock == Unlock.lessonCompleted && !lessonCompleted) {
      return ItemState.locked;
    }
    return ItemState.buyable;
  }

  Stream<Set<String>> watchEquipped(String profileId) {
    final key = _equippedKey(profileId);
    return _db.settingsDao.watchByPrefix(key).map((rows) {
      final raw = rows[key];
      return raw == null || raw.isEmpty ? <String>{} : raw.split(',').toSet();
    });
  }

  Future<Set<String>> _equipped(String profileId) async {
    final raw = await _db.settingsDao.read(_equippedKey(profileId));
    return raw == null || raw.isEmpty ? <String>{} : raw.split(',').toSet();
  }

  Future<bool> _lessonCompleted(String profileId) async {
    final rows = await (_db.select(
      _db.lessonProgress,
    )..where((r) => r.profileId.equals(profileId))).get();
    return rows.any((r) => r.status == LessonStatus.completed);
  }

  Future<PurchaseResult> buy(String profileId, String itemId) {
    final item = wardrobeItemById(itemId);
    if (item == null) return Future.value(PurchaseResult.unknownItem);
    return _db.transaction(() async {
      final owned = await _db.wardrobeDao.getOwned(profileId);
      if (ownedIds(owned).contains(itemId)) return PurchaseResult.alreadyOwned;
      if (item.unlock == Unlock.lessonCompleted &&
          !await _lessonCompleted(profileId)) {
        return PurchaseResult.locked;
      }
      final stars = await _db.activityDao.totalStars(profileId);
      if (balance(stars: stars, owned: owned) < item.price) {
        return PurchaseResult.notEnoughStars;
      }
      final ok = await _db.wardrobeDao.insertPurchase(
        profileId: profileId,
        itemId: itemId,
        cost: item.price,
        now: _now(),
      );
      return ok ? PurchaseResult.purchased : PurchaseResult.alreadyOwned;
    });
  }

  Future<bool> toggleAccessory(String profileId, String itemId) async {
    final item = wardrobeItemById(itemId);
    if (item == null || item.kind != WardrobeKind.accessory) return false;
    final owned = ownedIds(await _db.wardrobeDao.getOwned(profileId));
    final unlockedFree =
        item.unlock == Unlock.lessonCompleted &&
        item.price == 0 &&
        await _lessonCompleted(profileId);
    if (!owned.contains(itemId) && !unlockedFree) return false;
    final set = await _equipped(profileId);
    if (!set.add(itemId)) set.remove(itemId);
    await _db.settingsDao.write(_equippedKey(profileId), set.join(','));
    return true;
  }

  Future<bool> useColor(String profileId, String itemId) async {
    final item = wardrobeItemById(itemId);
    if (item == null || item.kind != WardrobeKind.color) return false;
    final owned = ownedIds(await _db.wardrobeDao.getOwned(profileId));
    if (!owned.contains(itemId)) return false;
    await _db.profilesDao.setColor(profileId, item.color!);
    return true;
  }
}
