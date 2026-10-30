import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';

import 'helpers/app_harness.dart';
import 'helpers/load_fonts.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  setUpAll(loadCairoFont);

  for (final scale in [1.0, 1.5]) {
    testWidgets(
      'الشاشات الرئيسية بلا استثناءات على 320×568 وخط ×$scale',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await repo.create(
            name: 'أنس',
            grade: 5,
            color: ProfileColor.teal,
            classCode: 'GZ-5A',
          );
          await repo.create(name: 'ليان', grade: 2, color: ProfileColor.coral);
        },
        (db) async {
          await tester.binding.setSurfaceSize(const Size(320, 568));
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpAndSettle();

          final previous = FlutterError.onError;
          FlutterError.onError = (details) {
            FlutterError.dumpErrorToConsole(details, forceReport: true);
            previous?.call(details);
          };
          addTearDown(() => FlutterError.onError = previous);

          void check(String where) {
            expect(tester.takeException(), isNull, reason: where);
          }

          check('picker');
          await tapVisible(tester, find.text('أنس'));
          await tester.pumpAndSettle();
          check("home");
          await tapVisible(tester, find.text(ArStrings.navProfile));
          await tester.pumpAndSettle();
          check('account');
          await tapVisible(tester, find.text(ArStrings.accountStudentCode));
          await tester.pumpAndSettle();
          check('student code');
          await tester.tap(find.bySemanticsLabel(ArStrings.back));
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text(ArStrings.accountPin));
          await tester.pumpAndSettle();
          check('pin setup sheet');
        },
      ),
    );
  }
  for (final scale in [1.0, 1.5]) {
    testWidgets(
      'الترحيب والإنشاء والرمز السري ونسيت الرمز بلا استثناءات على 320×568 وخط ×$scale',
      (tester) => scenario(tester, (db) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'welcome');

        await tapVisible(tester, find.text(ArStrings.welcomeStart));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'step1');
        await tester.enterText(find.byType(TextField), 'أنس');
        await tapVisible(tester, find.text('5'));
        await tester.pumpAndSettle();
        await tapVisible(tester, find.text(ArStrings.step1Next));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'step2');
      }),
    );

    testWidgets(
      'إدخال الرمز السري ونسيت الرمز على 320×568 وخط ×$scale',
      (tester) => scenario(
        tester,
        seed: (repo) async => repo.create(
          name: 'أنس',
          grade: 5,
          color: ProfileColor.teal,
          pin: '1234',
        ),
        (db) async {
          await tester.binding.setSurfaceSize(const Size(320, 568));
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'picker');
          await tapVisible(tester, find.text('أنس'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'pin entry');
          await tapVisible(tester, find.text(ArStrings.pinForgot));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'forgot sheet');
        },
      ),
    );
  }
  for (final scale in [1.0, 1.5]) {
    testWidgets(
      'الرئيسية بعد نشاط (نجوم وسلسلة ومراجعة) على 320×568 وخط ×$scale',
      (tester) => scenario(
        tester,
        seed: (repo) async =>
            repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal),
        (db) async {
          await tester.binding.setSurfaceSize(const Size(320, 568));
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpAndSettle();
          final id = (await onDb(tester, db.profilesDao.getAll)).single.id;
          await onDb(
            tester,
            () => db.activityDao.upsertLessonProgress(
              profileId: id,
              lessonId: 'math.u1.l1',
              status: LessonStatus.inProgress,
              progress: 0.5,
              now: DateTime.now(),
            ),
          );
          await onDb(
            tester,
            () => db.activityDao.insertAttempt(
              profileId: id,
              activityId: 'math.u1.l1.quiz',
              kind: AttemptKind.quiz,
              score: 2,
              total: 5,
              starsEarned: 120,
              now: DateTime.now(),
            ),
          );
          await onDb(
            tester,
            () => db.activityDao.upsertMastery(
              profileId: id,
              conceptId: 'math.u1.l1.c1',
              mastery: 0.4,
              now: DateTime.now(),
            ),
          );
          expect(tester.takeException(), isNull, reason: 'active home');
        },
      ),
    );
  }
  testWidgets(
    'على شاشة عريضة (كروم) المحتوى محصور في عمود بعرض هاتف',
    (tester) => scenario(
      tester,
      seed: (repo) async =>
          repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal),
      (db) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));
        await tester.pumpAndSettle();
        final width = tester.getSize(find.byType(Scaffold).first).width;
        expect(width, lessThanOrEqualTo(480));
        expect(tester.takeException(), isNull);
      },
    ),
  );
  for (final scale in [1.0, 1.5]) {
    testWidgets(
      'حسابي بمجموعاته وأوراقه على 320×568 وخط ×$scale',
      (tester) => scenario(
        tester,
        seed: (repo) async =>
            repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal),
        (db) async {
          await tester.binding.setSurfaceSize(const Size(320, 568));
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text(ArStrings.navProfile));
          await tester.pumpAndSettle();

          for (final label in [
            ArStrings.accountNightMode,
            ArStrings.accountStorageNote,
            ArStrings.accountAbout,
          ]) {
            await tester.ensureVisible(find.text(label));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: label);
          }

          for (final entry in [
            (ArStrings.accountGrade, ArStrings.gradeSheetTitle),
            (ArStrings.accountFontSize, ArStrings.fontSheetTitle),
            (ArStrings.accountPrivacy, ArStrings.privacyTitle),
            (ArStrings.accountAbout, ArStrings.aboutTitle),
          ]) {
            await tapVisible(tester, find.text(entry.$1));
            await tester.pumpAndSettle();
            expect(find.text(entry.$2), findsWidgets);
            expect(tester.takeException(), isNull, reason: entry.$2);
            await tester.tapAt(const Offset(20, 20));
            await tester.pumpAndSettle();
          }

          await tapVisible(tester, find.text(ArStrings.accountDelete));
          await tester.pumpAndSettle();
          expect(find.text(ArStrings.deleteConfirm), findsOneWidget);
          expect(tester.takeException(), isNull, reason: 'delete sheet');
          await tester.tapAt(const Offset(20, 20));
          await tester.pumpAndSettle();

          await tapVisible(tester, find.text(ArStrings.accountManageDownloads));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'downloads');
        },
      ),
    );
  }
}
