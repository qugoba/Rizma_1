import '../../core/db/enums.dart';
import '../../core/strings/ar_progress.dart';

enum WardrobeKind { accessory, color }

enum Unlock { none, lessonCompleted }

class WardrobeItem {
  const WardrobeItem({
    required this.id,
    required this.kind,
    required this.name,
    required this.price,
    this.unlock = Unlock.none,
    this.color,
  });

  final String id;
  final WardrobeKind kind;
  final String name;

  final int price;
  final Unlock unlock;

  final ProfileColor? color;

  bool get isFree => price == 0 && unlock == Unlock.none;
}

const wardrobeItems = [
  WardrobeItem(
    id: 'cap',
    kind: WardrobeKind.accessory,
    name: ArProgress.itemCap,
    price: 0,
  ),
  WardrobeItem(
    id: 'scarf',
    kind: WardrobeKind.accessory,
    name: ArProgress.itemScarf,
    price: 20,
  ),
  WardrobeItem(
    id: 'glasses',
    kind: WardrobeKind.accessory,
    name: ArProgress.itemGlasses,
    price: 30,
  ),
  WardrobeItem(
    id: 'star',
    kind: WardrobeKind.accessory,
    name: ArProgress.itemStar,
    price: 0,
    unlock: Unlock.lessonCompleted,
  ),
  WardrobeItem(
    id: 'color.teal',
    kind: WardrobeKind.color,
    name: ArProgress.colorTeal,
    price: 0,
    color: ProfileColor.teal,
  ),
  WardrobeItem(
    id: 'color.coral',
    kind: WardrobeKind.color,
    name: ArProgress.colorCoral,
    price: 40,
    color: ProfileColor.coral,
  ),
  WardrobeItem(
    id: 'color.blue',
    kind: WardrobeKind.color,
    name: ArProgress.colorBlue,
    price: 40,
    color: ProfileColor.blue,
  ),
  WardrobeItem(
    id: 'color.purple',
    kind: WardrobeKind.color,
    name: ArProgress.colorPurple,
    price: 50,
    color: ProfileColor.purple,
  ),
  WardrobeItem(
    id: 'color.amber',
    kind: WardrobeKind.color,
    name: ArProgress.colorAmber,
    price: 50,
    color: ProfileColor.amber,
  ),
];

WardrobeItem? wardrobeItemById(String id) {
  for (final i in wardrobeItems) {
    if (i.id == id) return i;
  }
  return null;
}
