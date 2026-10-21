import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';
import 'package:rizma/core/widgets/rizma_button.dart';

import 'helpers/app_harness.dart';
import 'helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  Future<void> fillStep1(WidgetTester tester, String name, int grade) async {
    await tester.tap(find.text(ArStrings.welcomeStart));
    await tester.pumpAndSettle();
    expect(find.text(ArStrings.gradeTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), name);
    await tester.tap(find.text('$grade'));
    await tester.pumpAndSettle();

    final label = ArStrings.step1Next;
    expect(find.text(label), findsOneWidget);
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<List<Profile>> profilesOf(WidgetTester tester, AppDatabase db) {
    return onDb(tester, () => db.profilesDao.getAll());
  }

  testWidgets(
    'جهاز نظيف يبدأ بالترحيب',
    (tester) => scenario(tester, (db) async {
      expect(find.text(ArStrings.welcomeStart), findsOneWidget);
    }),
  );

  testWidgets(
    '01 → 02 → 26 → الرئيسية (أول يوم) وتُحفظ بيانات الملف',
    (tester) => scenario(tester, (db) async {
      await fillStep1(tester, 'أنس', 5);

      expect(find.text(ArStrings.setupTitle), findsOneWidget);
      expect(find.text(ArStrings.setupPreview('أنس', 5)), findsOneWidget);

      await tester.tap(find.text(ArStrings.setupStart));
      await tester.pumpAndSettle();

      expect(find.text(ArStrings.homeFirstDayGreeting('أنس')), findsOneWidget);
      expect(find.text(ArStrings.gradeName(5)), findsOneWidget);

      final profiles = await profilesOf(tester, db);
      expect(profiles, hasLength(1));
      final p = profiles.single;
      expect(p.name, 'أنس');
      expect(p.grade, 5);
      expect(p.color, ProfileColor.teal);
      expect(p.pinHash, isNull);
      expect(p.classCode, isNull);
      expect(p.studentCode, startsWith('RZ-'));
    }),
  );

  testWidgets(
    'اختيار لون الشخصية يُحفظ مع الملف',
    (tester) => scenario(tester, (db) async {
      await fillStep1(tester, 'ليان', 2);

      await tester.tap(
        find.bySemanticsLabel(ArStrings.colorName(ProfileColor.coral)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(ArStrings.setupStart));
      await tester.pumpAndSettle();

      expect((await profilesOf(tester, db)).single.color, ProfileColor.coral);
    }),
  );

  testWidgets(
    'رمز صف غير صحيح يمنع الإنشاء ويعرض رسالة',
    (tester) => scenario(tester, (db) async {
      await fillStep1(tester, 'أنس', 5);

      await tester.enterText(find.byType(TextField), 'GZ--');
      await tester.tap(find.text(ArStrings.setupStart));
      await tester.pumpAndSettle();

      expect(find.text(ArStrings.setupClassInvalid), findsOneWidget);
      expect(await profilesOf(tester, db), isEmpty);
    }),
  );

  testWidgets(
    'رمز صف صحيح يُخزَّن موحّدًا',
    (tester) => scenario(tester, (db) async {
      await fillStep1(tester, 'أنس', 5);

      await tester.enterText(find.byType(TextField), 'gz-5a');
      await tester.tap(find.text(ArStrings.setupStart));
      await tester.pumpAndSettle();

      expect((await profilesOf(tester, db)).single.classCode, 'GZ-5A');
    }),
  );

  testWidgets(
    'الرمز السري: إدخال وتأكيد ثم يُخزَّن مجزّأً',
    (tester) => scenario(tester, (db) async {
      await fillStep1(tester, 'أنس', 5);

      await tester.tap(find.bySemanticsLabel(ArStrings.setupPinSwitch));
      await tester.pumpAndSettle();
      expect(find.text(ArStrings.pinSetupTitle), findsOneWidget);

      await enterPin(tester, '1234');
      expect(find.text(ArStrings.pinConfirmTitle), findsOneWidget);
      await enterPin(tester, '1234');
      expect(find.text(ArStrings.pinConfirmTitle), findsNothing);

      await tester.tap(find.byType(RizmaButton));
      await tester.pumpAndSettle();

      final p = (await profilesOf(tester, db)).single;
      expect(p.pinHash, isNotNull);
      expect(p.pinHash, isNot(contains('1234')));
    }),
  );

  testWidgets(
    'رمز سري غير متطابق يعيد الإدخال',
    (tester) => scenario(tester, (db) async {
      await fillStep1(tester, 'أنس', 5);

      await tester.tap(find.bySemanticsLabel(ArStrings.setupPinSwitch));
      await tester.pumpAndSettle();

      await enterPin(tester, '1234');
      await enterPin(tester, '4321');
      expect(find.text(ArStrings.pinMismatch), findsOneWidget);
      expect(find.text(ArStrings.pinSetupTitle), findsOneWidget);
    }),
  );

  testWidgets(
    'زر المتابعة في الخطوة 1 معطّل حتى يكتمل الاسم والصف',
    (tester) => scenario(tester, (db) async {
      await tester.tap(find.text(ArStrings.welcomeStart));
      await tester.pumpAndSettle();

      RizmaButton button() => tester.widget(find.byType(RizmaButton));
      expect(button().onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'أنس');
      await tester.pump();
      expect(button().onPressed, isNull);

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(button().onPressed, isNotNull);
    }),
  );
}
