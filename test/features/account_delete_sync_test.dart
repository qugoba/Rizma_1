import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';
import 'package:rizma/features/profiles/profile_repository.dart';
import 'package:rizma/features/sync/sync_api.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_sync_server.dart';

void main() {
  Future<void> seedAnas(ProfileRepository repo) async {
    final p = await repo.create(
      name: 'أنس',
      grade: 5,
      color: ProfileColor.teal,
    );
    await repo.setActive(p.id);
  }

  Future<Profile> only(WidgetTester tester, AppDatabase db) async =>
      (await onDb(tester, db.profilesDao.getAll)).single;

  Future<void> settleSync(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> openDelete(WidgetTester tester) async {
    await tester.tap(find.text(ArStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(ArStrings.accountDelete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ArStrings.accountDelete));
    await tester.pumpAndSettle();
  }

  Future<void> addAttempt(WidgetTester tester, AppDatabase db, String id) =>
      onDb(
        tester,
        () => db.activityDao.insertAttempt(
          profileId: id,
          activityId: 'math.u1.l1.practice',
          kind: AttemptKind.practice,
          score: 3,
          total: 3,
          starsEarned: 9,
          now: DateTime(2026, 10, 24),
        ),
      );

  testWidgets('مع الخادم: الخياران يظهران بعد طلب الحذف', (tester) {
    final server = FakeSyncServer();
    return scenario(
      tester,
      seed: seedAnas,
      overrides: [syncApiProvider.overrideWithValue(server.device('phone'))],
      (db) async {
        await openDelete(tester);
        expect(find.text(ArStrings.deleteChooseTitle('أنس')), findsOneWidget);
        expect(find.text(ArStrings.deleteRemoveOption), findsOneWidget);
        expect(find.text(ArStrings.deleteEverywhereOption), findsOneWidget);
        expect(find.text(ArStrings.deleteConfirm), findsNothing);
      },
    );
  });

  testWidgets(
    'إزالة من هذا الهاتف: ترفع النتائج أولًا، ثم تزيل الملف والنسخة تبقى على الخادم',
    (tester) {
      final server = FakeSyncServer();
      return scenario(
        tester,
        seed: seedAnas,
        overrides: [syncApiProvider.overrideWithValue(server.device('phone'))],
        (db) async {
          final p = await only(tester, db);
          await addAttempt(tester, db, p.id);
          await openDelete(tester);
          await tester.tap(find.text(ArStrings.deleteRemoveOption));
          await settleSync(tester);

          expect(
            find.text(ArStrings.deleteSafe(p.studentCode)),
            findsOneWidget,
          );
          await tester.tap(find.text(ArStrings.deleteRemoveConfirm));
          await settleSync(tester);
          await tester.pumpAndSettle();

          expect(await onDb(tester, db.profilesDao.getAll), isEmpty);
          expect(find.text(ArStrings.welcomeStart), findsOneWidget);
          expect(server.profiles.containsKey(p.id), isTrue);
          expect(
            server.attempts.length,
            1,
            reason: 'النتيجة رُفعت قبل الإزالة',
          );
          expect(server.links.contains((p.id, 'phone')), isFalse);
        },
      );
    },
  );

  testWidgets('دون اتصال ومع نتائج لم تُرفع: تحذير واضح، و«تراجع» يبقي الملف', (
    tester,
  ) {
    final api = FakeSyncServer().device('phone')..offline = true;
    return scenario(
      tester,
      seed: seedAnas,
      overrides: [syncApiProvider.overrideWithValue(api)],
      (db) async {
        final p = await only(tester, db);
        await addAttempt(tester, db, p.id);
        await openDelete(tester);
        await tester.tap(find.text(ArStrings.deleteRemoveOption));
        await settleSync(tester);

        expect(find.text(ArStrings.deleteUnsyncedWarning(1)), findsOneWidget);
        expect(find.text(ArStrings.deleteRemoveAnyway), findsOneWidget);
        await tester.tap(find.text(ArStrings.deleteCancel));
        await tester.pumpAndSettle();

        expect(await onDb(tester, db.profilesDao.getAll), hasLength(1));
      },
    );
  });

  testWidgets(
    'الحذف من كل مكان: رمز خاطئ يُرفض، والصحيح يطلب الحذف على الخادم ويزيل الملف',
    (tester) {
      final server = FakeSyncServer();
      return scenario(
        tester,
        seed: seedAnas,
        overrides: [syncApiProvider.overrideWithValue(server.device('phone'))],
        (db) async {
          final p = await only(tester, db);
          await addAttempt(tester, db, p.id);
          await settleSync(tester);
          expect(server.profiles.containsKey(p.id), isTrue);

          await openDelete(tester);
          await tester.tap(find.text(ArStrings.deleteEverywhereOption));
          await tester.pumpAndSettle();
          expect(find.text(ArStrings.deleteEverywhereBody), findsOneWidget);

          await tester.enterText(find.byType(TextField), 'RZ-2222-2222');
          await tester.pump();
          await tester.tap(find.text(ArStrings.deleteEverywhereConfirm));
          await settleSync(tester);
          expect(find.text(ArStrings.forgotCodeWrong), findsOneWidget);
          expect(server.profiles[p.id]!['deletion_requested_at'], isNull);

          await tester.enterText(
            find.byType(TextField),
            p.studentCode.toLowerCase(),
          );
          await tester.pump();
          await tester.tap(find.text(ArStrings.deleteEverywhereConfirm));
          await settleSync(tester);
          await tester.pumpAndSettle();

          expect(server.profiles[p.id]!['deletion_requested_at'], isNotNull);
          expect(await onDb(tester, db.profilesDao.getAll), isEmpty);
          expect(find.text(ArStrings.welcomeStart), findsOneWidget);
        },
      );
    },
  );
}
