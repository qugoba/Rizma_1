import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';
import 'package:rizma/core/strings/ar_kids.dart';
import 'package:rizma/core/strings/ar_learning.dart';
import 'package:rizma/core/strings/ar_progress.dart';
import 'package:rizma/features/account/account_providers.dart';
import 'package:rizma/features/account/preferences_repository.dart';
import 'package:rizma/features/account/widgets/setting_widgets.dart';
import 'package:rizma/core/widgets/rizma_switch.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

import 'helpers/app_harness.dart';
import 'helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  Future<void> seedAnas(ProfileRepository repo) async {
    await repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);
  }

  Future<void> openAccount(WidgetTester tester) async {
    await tester.tap(find.text(ArStrings.navProfile));
    await tester.pumpAndSettle();
  }

  Future<Profile> only(WidgetTester tester, AppDatabase db) async {
    final all = await onDb(tester, db.profilesDao.getAll);
    return all.single;
  }

  group('حسابي', () {
    testWidgets(
      'يعرض الاسم والصف والنجوم الحقيقية ورمز الطالب والرمز السري غير مفعّل',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        final p = await only(tester, db);
        await onDb(
          tester,
          () => db.activityDao.insertAttempt(
            profileId: p.id,
            activityId: 'x',
            kind: AttemptKind.practice,
            score: 3,
            total: 4,
            starsEarned: 3,
            now: DateTime(2026, 1, 1),
          ),
        );
        await openAccount(tester);

        expect(find.text('أنس'), findsOneWidget);
        expect(find.text(ArStrings.accountSummary(5, 3)), findsOneWidget);
        expect(find.text(p.studentCode), findsOneWidget);
        expect(find.text(ArStrings.accountPinOff), findsOneWidget);
        expect(find.text(ArStrings.accountProfileGroup), findsOneWidget);
      }),
    );

    testWidgets(
      'تبويب المواد يفتح المواد، وتبويب الرئيسية يعود إلى الرئيسية',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        await tester.tap(find.text(ArStrings.navSubjects));
        await tester.pumpAndSettle();
        expect(find.text(ArLearn.subjectsTitle), findsWidgets);

        await tester.tap(find.text(ArStrings.navHome));
        await tester.pumpAndSettle();
        expect(
          find.text(ArStrings.homeFirstDayGreeting('أنس')),
          findsOneWidget,
        );
      }),
    );

    testWidgets(
      '«تبديل الطالب» يفتح شاشة اختيار الملف',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        await tester.tap(find.text(ArStrings.accountSwitch));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.pickerTitle), findsOneWidget);
      }),
    );

    testWidgets(
      'تفعيل الرمز السري ثم تغييره ثم إلغاؤه',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);

        await tester.tap(find.text(ArStrings.accountPin));
        await tester.pumpAndSettle();
        await enterPin(tester, '1234');
        await enterPin(tester, '1234');
        expect(find.text(ArStrings.accountPinOn), findsOneWidget);
        final before = (await only(tester, db)).pinHash;
        expect(before, isNotNull);

        await tester.tap(find.text(ArStrings.accountPin));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ArStrings.pinChange));
        await tester.pumpAndSettle();
        await enterPin(tester, '5678');
        await enterPin(tester, '5678');
        final after = (await only(tester, db)).pinHash;
        expect(after, isNotNull);
        expect(after, isNot(before));

        await tester.tap(find.text(ArStrings.accountPin));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ArStrings.pinDisable));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.accountPinOff), findsOneWidget);
        expect((await only(tester, db)).pinHash, isNull);
      }),
    );

    testWidgets(
      'إغلاق ورقة الرمز السري دون إكماله لا يغيّر شيئًا',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        await tester.tap(find.text(ArStrings.accountPin));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(20, 60));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.accountPinOff), findsOneWidget);
        expect((await only(tester, db)).pinHash, isNull);
      }),
    );
  });

  group('رمز الطالب', () {
    Future<void> openCode(WidgetTester tester) async {
      await openAccount(tester);
      await tester.tap(find.text(ArStrings.accountStudentCode));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'يعرض الرمز وأسباب وجوده وحالة «لم يُحفظ» وبلا مجموعة صف',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        final p = await only(tester, db);
        await openCode(tester);

        expect(find.text(p.studentCode), findsOneWidget);
        expect(find.text(ArStrings.codeWhyTitle), findsOneWidget);
        expect(find.text(ArStrings.codeNeverSynced), findsOneWidget);
        expect(find.text(ArStrings.codeNothingPending), findsOneWidget);
        expect(find.text(ArStrings.codeClassGroup), findsNothing);
      }),
    );

    testWidgets(
      'عدد النتائج المنتظرة يأتي من طابور المزامنة ويتحدّث',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openCode(tester);
        for (var i = 0; i < 3; i++) {
          await onDb(
            tester,
            () => db.activityDao.enqueueSync(
              entity: 'attempt',
              payloadJson: '{}',
              now: DateTime(2026, 1, 1),
            ),
          );
        }
        expect(find.text(ArStrings.codePending(3)), findsOneWidget);
      }),
    );

    testWidgets(
      'مجموعة الصف تظهر عند وجود رمز صف',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await repo.create(
            name: 'أنس',
            grade: 5,
            color: ProfileColor.teal,
            classCode: 'gz-5a',
          );
        },
        (db) async {
          await openCode(tester);
          expect(find.text(ArStrings.codeClassGroup), findsOneWidget);
          expect(find.text(ArStrings.codeClassLine('GZ-5A')), findsOneWidget);
        },
      ),
    );

    testWidgets(
      'النسخ يضع الرمز في الحافظة ويعرض تأكيدًا',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        final p = await only(tester, db);
        String? clipboard;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboard = (call.arguments as Map)['text'] as String?;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );

        await openCode(tester);
        await tester.tap(find.text(ArStrings.codeCopy));
        await tester.pump();
        await tester.pump();

        expect(clipboard, p.studentCode);
        expect(find.text(ArStrings.codeCopied), findsOneWidget);
      }),
    );

    testWidgets('المشاركة ترسل رسالة فيها الرمز', (tester) {
      final shared = <String>[];
      return scenario(
        tester,
        overrides: [
          shareTextProvider.overrideWithValue((text) async {
            shared.add(text);
          }),
        ],
        seed: seedAnas,
        (db) async {
          final p = await only(tester, db);
          await openCode(tester);
          await tester.tap(find.text(ArStrings.codeShare));
          await tester.pump();

          expect(shared, [ArStrings.codeShareMessage(p.studentCode)]);
        },
      );
    });

    testWidgets(
      'زر الرجوع يعيد إلى حسابي',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openCode(tester);
        await tester.tap(find.bySemanticsLabel(ArStrings.back));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.accountProfileGroup), findsOneWidget);
        expect(find.text(ArStrings.codeWhyTitle), findsNothing);
      }),
    );
  });
  group('حسابي — الدراسة والتخزين وعام', () {
    Future<void> show(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text));
      await tester.pumpAndSettle();
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await show(tester, text);
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    Future<ProfilePrefs> prefsOf(WidgetTester tester, AppDatabase db) async {
      final p = await only(tester, db);
      return (await tester.runAsync(
        () => PreferencesRepository(db).read(p.id),
      ))!;
    }

    double textScale(WidgetTester tester) => MediaQuery.of(
      tester.element(find.byType(Scaffold).first),
    ).textScaler.scale(1);

    testWidgets(
      'تغيير الصف: يحدّث القاعدة والرأس والقيمة وينبّه أن المحتوى للصف الخامس',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        expect(find.text(ArStrings.gradeOrdinal(5)), findsOneWidget);

        await tapText(tester, ArStrings.accountGrade);
        expect(find.text(ArStrings.gradeSheetTitle), findsOneWidget);
        expect(find.text(ArStrings.gradeContentSoon(5)), findsOneWidget);

        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();

        expect((await only(tester, db)).grade, 7);
        expect(find.text(ArStrings.accountSummary(7, 0)), findsOneWidget);
        expect(find.text(ArStrings.gradeOrdinal(7)), findsOneWidget);
        expect(find.text(ArStrings.gradeChanged(7)), findsOneWidget);
      }),
    );

    testWidgets(
      'إغلاق ورقة الصف بلا اختيار لا يغيّر شيئًا',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        await tapText(tester, ArStrings.accountGrade);
        await tester.tapAt(const Offset(20, 40));
        await tester.pumpAndSettle();
        expect((await only(tester, db)).grade, 5);
      }),
    );

    testWidgets(
      'حجم الخط: يُحفظ ويُطبَّق على التطبيق كله',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        expect(find.text(ArStrings.fontSizeMedium), findsOneWidget);
        expect(textScale(tester), 1.0);

        await tapText(tester, ArStrings.accountFontSize);
        await tester.tap(find.text(ArStrings.fontSizeLarge).last);
        await tester.pumpAndSettle();

        expect((await prefsOf(tester, db)).fontSize, FontSizeChoice.large);
        expect(find.text(ArStrings.fontSizeLarge), findsOneWidget);
        expect(textScale(tester), closeTo(1.15, 0.001));
      }),
    );

    testWidgets(
      'حجم الخط خاص بكل طالب: طالب آخر يرى الحجم المتوسط',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);
          await repo.create(name: 'ليان', grade: 2, color: ProfileColor.coral);
        },
        (db) async {
          final all = await onDb(tester, db.profilesDao.getAll);
          final anas = all.firstWhere((p) => p.name == 'أنس');
          await onDb(
            tester,
            () => PreferencesRepository(
              db,
            ).setFontSize(anas.id, FontSizeChoice.large),
          );
          await tester.tap(find.text('ليان'));
          await tester.pumpAndSettle();
          expect(textScale(tester), 1.0);
        },
      ),
    );

    testWidgets(
      'مفاتيح الأصوات وWi-Fi والفيديو: تبدأ بالافتراضي وتُحفظ',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        bool on(String label) => tester
            .widget<RizmaSwitch>(
              find.byWidgetPredicate(
                (w) => w is RizmaSwitch && w.semanticsLabel == label,
              ),
            )
            .value;

        await show(tester, ArStrings.accountAutoVideo);
        expect(on(ArStrings.accountGameSounds), isTrue);
        expect(on(ArStrings.accountWifiOnly), isTrue);
        expect(on(ArStrings.accountAutoVideo), isFalse);

        for (final label in [
          ArStrings.accountGameSounds,
          ArStrings.accountWifiOnly,
          ArStrings.accountAutoVideo,
        ]) {
          await tester.tap(
            find.byWidgetPredicate(
              (w) => w is RizmaSwitch && w.semanticsLabel == label,
            ),
          );
          await tester.pumpAndSettle();
        }

        expect(on(ArStrings.accountGameSounds), isFalse);
        expect(on(ArStrings.accountWifiOnly), isFalse);
        expect(on(ArStrings.accountAutoVideo), isTrue);
        final saved = await prefsOf(tester, db);
        expect(saved.gameSounds, isFalse);
        expect(saved.wifiOnly, isFalse);
        expect(saved.autoVideo, isTrue);
      }),
    );

    testWidgets(
      'التخزين: ملاحظة «عند توفرها»، وإدارة التنزيلات تعرض المحتوى الموجود على الجهاز بصدق',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        await show(tester, ArStrings.accountStorageNote);
        expect(find.text(ArStrings.accountStorageNote), findsOneWidget);

        await tapText(tester, ArStrings.accountManageDownloads);
        expect(find.text(ArProgress.downloadsTitle), findsOneWidget);
        expect(find.text(ArProgress.offlineBannerTitle), findsOneWidget);
        expect(find.text(ArProgress.syncBody(0)), findsOneWidget);
        expect(find.textContaining('محمّلة من'), findsOneWidget);
        expect(find.text(ArProgress.installedEmpty), findsNothing);

        await tester.tap(find.bySemanticsLabel(ArStrings.back));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.accountProfileGroup), findsOneWidget);
      }),
    );

    testWidgets(
      'الوضع الليلي معطّل مع «قريبًا» ولا يستجيب للضغط',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);
        await show(tester, ArStrings.accountNightMode);
        expect(find.byType(SoonSettingRow), findsOneWidget);
        expect(find.text(ArStrings.accountSoon), findsOneWidget);

        final night = find.byWidgetPredicate(
          (w) =>
              w is RizmaSwitch &&
              w.semanticsLabel == ArStrings.accountNightMode,
        );
        await tester.tap(night, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(tester.widget<RizmaSwitch>(night).value, isFalse);
      }),
    );

    testWidgets(
      'الخصوصية وعن رزمة تفتحان ورقتي معلومات',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openAccount(tester);

        await tapText(tester, ArStrings.accountPrivacy);
        expect(find.text(ArStrings.privacyTitle), findsOneWidget);
        expect(find.text(ArStrings.privacy1), findsOneWidget);
        await tester.tap(find.text(ArStrings.close));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.privacy1), findsNothing);

        await tapText(tester, ArStrings.accountAbout);
        expect(find.text(ArStrings.aboutTitle), findsOneWidget);
        expect(find.text(ArStrings.about3), findsOneWidget);
      }),
    );
  });
  group('حذف الملف الشخصي', () {
    Future<void> openDelete(WidgetTester tester) async {
      await openAccount(tester);
      await tester.ensureVisible(find.text(ArStrings.accountDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ArStrings.accountDelete));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'ملف وحيد بلا رمز: التأكيد يحذفه ويعيد إلى الترحيب',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openDelete(tester);
        expect(find.text(ArStrings.deleteTitle('أنس')), findsOneWidget);
        expect(find.text(ArStrings.deleteWarning), findsOneWidget);

        await tester.tap(find.text(ArStrings.deleteConfirm));
        await tester.pumpAndSettle();

        expect(find.text(ArStrings.welcomeStart), findsOneWidget);
        expect(await onDb(tester, db.profilesDao.getAll), isEmpty);
      }),
    );

    testWidgets(
      'التراجع يُبقي الملف',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        await openDelete(tester);
        await tester.tap(find.text(ArStrings.deleteCancel));
        await tester.pumpAndSettle();

        expect(find.text(ArStrings.accountProfileGroup), findsOneWidget);
        expect(await onDb(tester, db.profilesDao.getAll), hasLength(1));
      }),
    );

    testWidgets(
      'حذف الملف النشط من ملفين: يظهر الملف الباقي في شاشة الاختيار',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await repo.create(name: 'ليان', grade: 2, color: ProfileColor.coral);
          await repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);
        },
        (db) async {
          await tester.tap(find.text('أنس'));
          await tester.pumpAndSettle();
          await openDelete(tester);
          await tester.tap(find.text(ArStrings.deleteConfirm));
          await tester.pumpAndSettle();

          final left = await onDb(tester, db.profilesDao.getAll);
          expect(left.map((p) => p.name), ['ليان']);
          expect(find.text(ArKids.greeting('ليان')), findsOneWidget);
        },
      ),
    );

    testWidgets(
      'ملف بلا رمز لكن بنشاط وتفضيلات: يُمسح كل ما يخصّه',
      (tester) => scenario(tester, seed: seedAnas, (db) async {
        final p = await only(tester, db);
        await onDb(
          tester,
          () => db.activityDao.insertAttempt(
            profileId: p.id,
            activityId: 'x',
            kind: AttemptKind.practice,
            score: 1,
            total: 2,
            starsEarned: 2,
            now: DateTime(2026, 1, 1),
          ),
        );
        await onDb(
          tester,
          () =>
              PreferencesRepository(db).setFontSize(p.id, FontSizeChoice.large),
        );

        await openDelete(tester);
        await tester.tap(find.text(ArStrings.deleteConfirm));
        await tester.pumpAndSettle();

        final attempts = await onDb(tester, () => db.select(db.attempts).get());
        expect(attempts, isEmpty);
        final prefs = await onDb(
          tester,
          () => PreferencesRepository(db).read(p.id),
        );
        expect(prefs.fontSize, FontSizeChoice.medium);
      }),
    );

    testWidgets(
      'ملف برمز سري: يُطلب الرمز أولًا، الخطأ يمنع، والصحيح يفتح التأكيد',
      (tester) => scenario(
        tester,
        seed: (repo) async => repo.create(
          name: 'أنس',
          grade: 5,
          color: ProfileColor.teal,
          pin: '1234',
        ),
        (db) async {
          await tester.tap(find.text('أنس'));
          await tester.pumpAndSettle();
          await enterPin(tester, '1234');
          await openDelete(tester);

          expect(find.text(ArStrings.deletePinTitle), findsOneWidget);
          expect(find.text(ArStrings.deleteConfirm), findsNothing);

          await enterPin(tester, '0000');
          expect(find.text(ArStrings.pinWrong), findsOneWidget);
          expect(find.text(ArStrings.deleteConfirm), findsNothing);

          await enterPin(tester, '1234');
          expect(find.text(ArStrings.deleteConfirm), findsOneWidget);
          expect(await onDb(tester, db.profilesDao.getAll), hasLength(1));

          await tester.tap(find.text(ArStrings.deleteConfirm));
          await tester.pumpAndSettle();
          expect(await onDb(tester, db.profilesDao.getAll), isEmpty);
        },
      ),
    );
  });
}
