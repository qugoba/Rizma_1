import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar_progress.dart';
import 'package:rizma/features/profiles/profile_repository.dart';
import 'package:rizma/features/wardrobe/wardrobe_items.dart';
import 'package:rizma/features/wardrobe/wardrobe_repository.dart';

import '../helpers/app_harness.dart';
import '../helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  group('WardrobeRepository', () {
    late AppDatabase db;
    late WardrobeRepository repo;
    late String id;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = WardrobeRepository(db, now: () => DateTime(2026, 10, 14));
      id = (await ProfileRepository(
        db,
      ).create(name: 'أنس', grade: 5, color: ProfileColor.teal)).id;
    });

    tearDown(() => db.close());

    Future<void> earn(int stars) => db.activityDao.insertAttempt(
      profileId: id,
      activityId: 'x',
      kind: AttemptKind.practice,
      score: 1,
      total: 1,
      starsEarned: stars,
      now: DateTime(2026, 10, 14),
    );

    Future<int> balance() async => WardrobeRepository.balance(
      stars: await db.activityDao.totalStars(id),
      owned: await db.wardrobeDao.getOwned(id),
    );

    test('بلا نجوم لا شراء، ومعه نجوم يخصم السعر مرة واحدة', () async {
      expect(await repo.buy(id, 'scarf'), PurchaseResult.notEnoughStars);
      await earn(50);
      expect(await repo.buy(id, 'scarf'), PurchaseResult.purchased);
      expect(await balance(), 30);
      expect(await repo.buy(id, 'scarf'), PurchaseResult.alreadyOwned);
      expect(await balance(), 30);
    });

    test('شراءان متزامنان لنفس العنصر يخصمان مرة واحدة', () async {
      await earn(100);
      final results = await Future.wait([
        repo.buy(id, 'glasses'),
        repo.buy(id, 'glasses'),
      ]);
      expect(results.where((r) => r == PurchaseResult.purchased).length, 1);
      expect(await balance(), 70);
    });

    test('عنصر مجهول والمجاني المملوك', () async {
      expect(await repo.buy(id, 'nope'), PurchaseResult.unknownItem);
      expect(await repo.buy(id, 'cap'), PurchaseResult.alreadyOwned);
    });

    test('نجمة الإتقان مقفلة حتى يكمل الطالب درسًا', () async {
      expect(await repo.buy(id, 'star'), PurchaseResult.locked);
      expect(await repo.toggleAccessory(id, 'star'), isFalse);
      await db.activityDao.upsertLessonProgress(
        profileId: id,
        lessonId: 'math.u1.l1',
        status: LessonStatus.completed,
        progress: 1,
        now: DateTime(2026, 10, 14),
      );
      expect(await repo.toggleAccessory(id, 'star'), isTrue);
    });

    test('لبس وخلع الإكسسوار، وغير المملوك لا يُلبس', () async {
      expect(await repo.toggleAccessory(id, 'scarf'), isFalse);
      expect(await repo.toggleAccessory(id, 'cap'), isTrue);
      expect(await repo.watchEquipped(id).first, {'cap'});
      expect(await repo.toggleAccessory(id, 'cap'), isTrue);
      expect(await repo.watchEquipped(id).first, isEmpty);
    });

    test('تغيير اللون يحتاج عنصرًا مملوكًا ويغيّر لون الملف', () async {
      expect(await repo.useColor(id, 'color.coral'), isFalse);
      await earn(40);
      await repo.buy(id, 'color.coral');
      expect(await repo.useColor(id, 'color.coral'), isTrue);
      expect((await db.profilesDao.getById(id))!.color, ProfileColor.coral);
      expect(await repo.useColor(id, 'color.teal'), isTrue);
      expect((await db.profilesDao.getById(id))!.color, ProfileColor.teal);
    });

    test('حذف الملف يمسح مشترياته', () async {
      await earn(50);
      await repo.buy(id, 'scarf');
      await db.profilesDao.deleteById(id);
      expect(await db.wardrobeDao.getOwned(id), isEmpty);
    });
  });

  group('حالة العنصر', () {
    ItemState state(
      String itemId, {
      Set<String> owned = const {'cap', 'color.teal'},
      Set<String> equipped = const {},
      bool lesson = false,
      String color = 'color.teal',
    }) => WardrobeRepository.stateOf(
      wardrobeItemById(itemId)!,
      owned: owned,
      equipped: equipped,
      lessonCompleted: lesson,
      currentColorItemId: color,
    );

    test('مرتدى / مملوك / للشراء / مقفل', () {
      expect(state('cap', equipped: {'cap'}), ItemState.equipped);
      expect(state('cap'), ItemState.owned);
      expect(state('scarf'), ItemState.buyable);
      expect(state('star'), ItemState.locked);
      expect(state('star', lesson: true), ItemState.owned);
    });

    test('اللون المستخدم هو لون الملف الحالي', () {
      expect(state('color.teal'), ItemState.equipped);
      expect(state('color.coral', owned: {'color.coral'}), ItemState.owned);
      expect(
        state('color.coral', owned: {'color.coral'}, color: 'color.coral'),
        ItemState.equipped,
      );
    });
  });

  testWidgets(
    'شاشة الخزانة: نجوم لا تكفي ثم شراء ثم ارتداء',
    (tester) => scenario(
      tester,
      seed: (r) async {
        await r.create(name: 'أنس', grade: 5, color: ProfileColor.teal);
      },
      (db) async {
        final profile = (await tester.runAsync(
          () => db.profilesDao.getAll(),
        ))!.single;
        final container = ProviderScope.containerOf(
          tester.element(find.byType(RizmaApp)),
        );
        container.read(routerProvider).push('/account/wardrobe');
        await tester.pumpAndSettle();
        expect(find.text(ArProgress.wardrobeTitle), findsOneWidget);

        await tester.tap(find.text(ArProgress.itemScarf));
        await tester.pumpAndSettle();
        expect(find.text(ArProgress.notEnoughStars), findsOneWidget);

        await onDb(
          tester,
          () => db.activityDao.insertAttempt(
            profileId: profile.id,
            activityId: 'x',
            kind: AttemptKind.practice,
            score: 1,
            total: 1,
            starsEarned: 25,
            now: DateTime.now(),
          ),
        );
        await tester.tap(find.text(ArProgress.itemScarf));
        await tester.pumpAndSettle();
        expect(find.text(ArProgress.confirmBuyTitle), findsOneWidget);
        await tester.tap(find.text(ArProgress.buy));
        await tester.pumpAndSettle();
        expect(
          find.text(ArProgress.purchased(ArProgress.itemScarf)),
          findsOneWidget,
        );

        await tester.tap(find.text(ArProgress.itemScarf));
        await tester.pumpAndSettle();
        expect(find.text(ArProgress.itemEquipped), findsWidgets);

        await tester.tap(find.text(ArProgress.itemStar));
        await tester.pumpAndSettle();
        expect(find.text(ArProgress.lockedLesson), findsWidgets);
      },
    ),
  );
}
