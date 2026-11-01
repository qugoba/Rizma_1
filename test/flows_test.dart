import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';
import 'package:rizma/core/strings/ar_kids.dart';
import 'package:rizma/core/utils/student_code.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

import 'helpers/app_harness.dart';
import 'helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  Future<Profile> addProfile(
    ProfileRepository repo,
    String name, {
    int grade = 5,
    ProfileColor color = ProfileColor.teal,
    String? pin,
  }) {
    return repo.create(name: name, grade: grade, color: color, pin: pin);
  }

  group('الإقلاع', () {
    testWidgets(
      'ملف واحد بلا رمز سري ← الرئيسية مباشرة',
      (tester) => scenario(
        tester,
        seed: (repo) async => addProfile(repo, 'أنس'),
        (db) async {
          expect(
            find.text(ArStrings.homeFirstDayGreeting('أنس')),
            findsOneWidget,
          );
          expect(find.text(ArStrings.pickerTitle), findsNothing);
        },
      ),
    );

    testWidgets(
      'ملفان ← شاشة «من يتعلّم الآن؟» وتظهر بطاقة طالب جديد',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await addProfile(repo, 'أنس');
          await addProfile(repo, 'ليان', grade: 2, color: ProfileColor.coral);
        },
        (db) async {
          expect(find.text(ArStrings.pickerTitle), findsOneWidget);
          expect(find.text('أنس'), findsOneWidget);
          expect(find.text('ليان'), findsOneWidget);
          expect(find.text(ArStrings.pickerNewTitle), findsOneWidget);
          expect(find.text(ArStrings.stars(0)), findsNWidgets(2));
        },
      ),
    );

    testWidgets(
      'اختيار ملف بلا رمز سري يفتح رئيسيته',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await addProfile(repo, 'أنس');
          await addProfile(repo, 'ليان', grade: 2);
        },
        (db) async {
          await tester.tap(find.text('ليان'));
          await tester.pumpAndSettle();
          expect(find.text(ArKids.greeting('ليان')), findsOneWidget);
          expect(find.text(ArStrings.gradeName(2)), findsOneWidget);
        },
      ),
    );

    testWidgets(
      '«طالب جديد» يفتح الخطوة 1 من إنشاء الملف',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await addProfile(repo, 'أنس');
          await addProfile(repo, 'ليان');
        },
        (db) async {
          await tester.tap(find.text(ArStrings.pickerNewTitle));
          await tester.pumpAndSettle();
          expect(find.text(ArStrings.gradeTitle), findsOneWidget);
        },
      ),
    );

    testWidgets(
      '«لديك رمز طالب؟» تفتح الاستعادة، وتقول بصدق إن الخادم غير متاح بعد',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await addProfile(repo, 'أنس');
          await addProfile(repo, 'ليان');
        },
        (db) async {
          await tester.tap(find.text(ArStrings.pickerRestoreTitle));
          await tester.pumpAndSettle();
          expect(find.text(ArStrings.restoreTitle), findsOneWidget);
          expect(find.text(ArStrings.restoreUnavailable), findsOneWidget);
        },
      ),
    );
  });

  group('الرمز السري (شاشة 27)', () {
    Future<void> seedTwoWithPin(ProfileRepository repo) async {
      await addProfile(repo, 'أنس', pin: '1234');
      await addProfile(repo, 'ليان', grade: 2);
    }

    Future<void> openAnasPin(WidgetTester tester) async {
      await tester.tap(find.text('أنس'));
      await tester.pumpAndSettle();
      expect(find.text(ArStrings.pinEnterTitle), findsOneWidget);
    }

    testWidgets(
      'ملف محمي: 25 ← 27 ← الرئيسية بالرمز الصحيح',
      (tester) => scenario(tester, seed: seedTwoWithPin, (db) async {
        await openAnasPin(tester);
        expect(
          find.text(ArStrings.pinProfileChip('أنس', ArStrings.gradeName(5))),
          findsOneWidget,
        );

        await enterPin(tester, '1234');
        expect(
          find.text(ArStrings.homeFirstDayGreeting('أنس')),
          findsOneWidget,
        );
      }),
    );

    testWidgets(
      'رمز خاطئ يعرض رسالة ولا يدخل',
      (tester) => scenario(tester, seed: seedTwoWithPin, (db) async {
        await openAnasPin(tester);
        await enterPin(tester, '0000');
        expect(find.text(ArStrings.pinWrong), findsOneWidget);
        expect(find.text(ArStrings.pinEnterTitle), findsOneWidget);

        await enterPin(tester, '1234');
        expect(
          find.text(ArStrings.homeFirstDayGreeting('أنس')),
          findsOneWidget,
        );
      }),
    );

    testWidgets(
      'بعد 5 محاولات خاطئة يُقفل الإدخال ولو أُدخل الرمز الصحيح',
      (tester) => scenario(tester, seed: seedTwoWithPin, (db) async {
        await openAnasPin(tester);
        for (var i = 0; i < 5; i++) {
          await enterPin(tester, '0000');
        }
        expect(find.text(ArStrings.pinLocked(30)), findsOneWidget);

        await enterPin(tester, '1234');
        expect(find.text(ArStrings.pinEnterTitle), findsOneWidget);
        expect(find.text(ArStrings.homeFirstDayGreeting('أنس')), findsNothing);
      }),
    );

    testWidgets(
      'نسيت الرمز: رمز طالب خاطئ يُرفض',
      (tester) => scenario(tester, seed: seedTwoWithPin, (db) async {
        await openAnasPin(tester);
        await tester.tap(find.text(ArStrings.pinForgot));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.forgotTitle), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'RZ-ZZZZ');
        await tester.pump();
        await tester.tap(find.text(ArStrings.forgotVerify));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.forgotCodeWrong), findsOneWidget);
      }),
    );

    testWidgets(
      'نسيت الرمز: رمز الطالب الصحيح ثم إلغاء الرمز السري يفتح الرئيسية',
      (tester) => scenario(tester, seed: seedTwoWithPin, (db) async {
        final anas = (await onDb(
          tester,
          () => db.profilesDao.getAll(),
        )).firstWhere((p) => p.name == 'أنس');
        await openAnasPin(tester);
        await tester.tap(find.text(ArStrings.pinForgot));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), anas.studentCode);
        await tester.pump();
        await tester.tap(find.text(ArStrings.forgotVerify));
        await tester.pumpAndSettle();
        expect(find.text(ArStrings.forgotChoose), findsOneWidget);

        await tester.tap(find.text(ArStrings.forgotRemove));
        await tester.pumpAndSettle();

        expect(
          find.text(ArStrings.homeFirstDayGreeting('أنس')),
          findsOneWidget,
        );
        final after = await onDb(tester, () => db.profilesDao.getById(anas.id));
        expect(after!.pinHash, isNull);
      }),
    );

    testWidgets(
      'نسيت الرمز: تعيين رمز جديد',
      (tester) => scenario(tester, seed: seedTwoWithPin, (db) async {
        final anas = (await onDb(
          tester,
          () => db.profilesDao.getAll(),
        )).firstWhere((p) => p.name == 'أنس');
        await openAnasPin(tester);
        await tester.tap(find.text(ArStrings.pinForgot));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), anas.studentCode);
        await tester.pump();
        await tester.tap(find.text(ArStrings.forgotVerify));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ArStrings.forgotSetNew));
        await tester.pumpAndSettle();

        await enterPin(tester, '9999');
        await enterPin(tester, '9999');

        expect(
          find.text(ArStrings.homeFirstDayGreeting('أنس')),
          findsOneWidget,
        );
        final after = await onDb(tester, () => db.profilesDao.getById(anas.id));
        expect(after!.pinHash, isNotNull);
        final repo = ProfileRepository(db);
        final ok = await onDb(tester, () => repo.verifyPin(anas.id, '9999'));
        expect(ok.isOk, isTrue);
      }),
    );
  });

  group('الرئيسية من البيانات', () {
    testWidgets(
      'أول يوم: بلا نجوم ولا سلسلة ولا نسبة ولا مراجعة، ومحتواها من الكتالوج',
      (tester) => scenario(
        tester,
        seed: (repo) async => addProfile(repo, 'أنس'),
        (db) async {
          expect(
            find.text(ArStrings.homeFirstDayGreeting('أنس')),
            findsOneWidget,
          );
          expect(find.text(ArStrings.homeFirstDaySubtitle), findsOneWidget);
          expect(
            find.text(ArStrings.homeStartFirstLesson('الأعداد')),
            findsOneWidget,
          );
          expect(find.text(ArStrings.homeLessonMeta(15)), findsOneWidget);
          expect(
            find.text(ArStrings.homeSubjectUnit('الرياضيات', 'الأعداد')),
            findsOneWidget,
          );
          expect(find.text(ArStrings.homeFirstStepsCount(0)), findsOneWidget);
          expect(find.text(ArStrings.homeReviewPlaceholder), findsOneWidget);
          expect(find.text(ArStrings.homeNeedsReview), findsNothing);
          expect(find.text('الرياضيات'), findsOneWidget);
          expect(find.text('العربية'), findsOneWidget);
          expect(find.text(ArStrings.homeNotStarted), findsNWidgets(6));
          expect(find.textContaining('75%'), findsNothing);
          expect(find.textContaining('24'), findsNothing);
        },
      ),
    );

    testWidgets(
      'بعد أول نشاط تنتقل الرئيسية من 28 إلى 03 ثم تظهر المراجعة بعد اختبار',
      (tester) => scenario(
        tester,
        seed: (repo) async => addProfile(repo, 'أنس'),
        (db) async {
          final id = (await onDb(
            tester,
            () => db.profilesDao.getAll(),
          )).single.id;

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
          expect(find.text(ArStrings.homeGreeting('أنس')), findsOneWidget);
          expect(
            find.text(ArStrings.homeFirstDayGreeting('أنس')),
            findsNothing,
          );
          expect(
            find.text(ArStrings.homeLessonTitle(1, 'الأعداد')),
            findsOneWidget,
          );
          expect(find.text('50%'), findsWidgets);
          expect(find.text(ArStrings.homeContinue), findsOneWidget);
          expect(find.text(ArStrings.homeReviewPlaceholder), findsNothing);
          expect(find.text(ArStrings.homeNeedsReview), findsNothing);

          await onDb(
            tester,
            () => db.activityDao.insertAttempt(
              profileId: id,
              activityId: 'math.u1.l1.practice',
              kind: AttemptKind.practice,
              score: 4,
              total: 5,
              starsEarned: 3,
              now: DateTime.now(),
            ),
          );
          expect(find.text(ArStrings.stars(3)), findsOneWidget);
          expect(find.text(ArStrings.streakDays(1)), findsOneWidget);

          await onDb(
            tester,
            () => db.activityDao.insertAttempt(
              profileId: id,
              activityId: 'math.u1.l1.quiz',
              kind: AttemptKind.quiz,
              score: 2,
              total: 5,
              starsEarned: 1,
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
          expect(find.text(ArStrings.stars(4)), findsOneWidget);
          expect(find.text(ArStrings.homeNeedsReview), findsOneWidget);
          expect(find.text('قراءة الأعداد الكبيرة وكتابتها'), findsOneWidget);
          expect(find.text(ArStrings.homeMastery(40)), findsOneWidget);
        },
      ),
    );

    testWidgets(
      'بيانات كل ملف منفصلة: نشاط ملف لا يظهر في ملف آخر',
      (tester) => scenario(
        tester,
        seed: (repo) async {
          await addProfile(repo, 'أنس');
          await addProfile(repo, 'ليان', grade: 2);
        },
        (db) async {
          final profiles = await onDb(tester, () => db.profilesDao.getAll());
          final anas = profiles.firstWhere((p) => p.name == 'أنس');
          await onDb(
            tester,
            () => db.activityDao.insertAttempt(
              profileId: anas.id,
              activityId: 'x',
              kind: AttemptKind.practice,
              score: 5,
              total: 5,
              starsEarned: 7,
              now: DateTime.now(),
            ),
          );

          expect(find.text(ArStrings.stars(7)), findsOneWidget);
          expect(find.text(ArStrings.stars(0)), findsOneWidget);

          await tester.tap(find.text('ليان'));
          await tester.pumpAndSettle();
          expect(find.text(ArKids.greeting('ليان')), findsOneWidget);
          expect(find.text(ArStrings.stars(7)), findsNothing);
        },
      ),
    );
  });

  test('رمز الطالب المولَّد صالح (فحص سريع للتكامل)', () {
    expect(StudentCode.isValid(StudentCode.generate()), isTrue);
  });
}
