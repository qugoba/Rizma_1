import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar.dart';
import 'package:rizma/core/strings/ar_kids.dart';
import 'package:rizma/core/strings/ar_learning.dart';
import 'package:rizma/features/account/downloads_providers.dart';
import 'package:rizma/features/catalog/catalog_models.dart';
import 'package:rizma/features/content/speech_service.dart';
import 'package:rizma/features/home/exam_prep.dart';
import 'package:rizma/features/kids/counting_game.dart';
import 'package:rizma/features/learning/learning_providers.dart';
import 'package:rizma/features/learning/learning_repository.dart';
import 'package:rizma/features/learning/round_engine.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

import '../helpers/app_harness.dart';
import '../helpers/load_fonts.dart';

void main() {
  setUpAll(loadCairoFont);

  final catalog = Catalog.fromJson(
    jsonDecode(File('assets/content/catalog_grade5.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  group('لعبة العدّ', () {
    test('الأسئلة صالحة: الجواب بين الخيارات والعدد 1–9 ولا تكرار متتالٍ', () {
      for (var seed = 0; seed < 50; seed++) {
        final qs = CountingGame.generate(Random(seed));
        expect(qs.length, CountingGame.length);
        var previous = 0;
        for (final q in qs) {
          final count = CountingGame.countOf(q);
          expect(count, inInclusiveRange(1, 9));
          expect(count, isNot(previous));
          previous = count;
          final choices = (q as dynamic).choices as List<String>;
          expect(choices.toSet().length, 3);
          expect(q.check(choices.indexOf('$count')), isTrue);
          expect(choices.map(int.parse).every((n) => n >= 1 && n <= 9), isTrue);
          expect(
            [...choices.map(int.parse)]..sort(),
            choices.map(int.parse).toList(),
          );
        }
      }
    });

    test('صيغ العدد العربية: مفرد ومثنى وجمع', () {
      final apple = fruits.first;
      expect(apple.phrase(1), 'تفاحة واحدة');
      expect(apple.phrase(2), 'تفاحتان');
      expect(apple.phrase(5), '5 تفاحات');
    });

    test('السقف: لا تتجاوز نجوم اللعبة 60 إجمالًا', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final id = (await ProfileRepository(
        db,
      ).create(name: 'ليان', grade: 2, color: ProfileColor.coral)).id;
      final repo = LearningRepository(db);
      List<QuestionResult> perfect() => [
        for (var i = 0; i < 5; i++)
          QuestionResult(
            questionId: 'q$i',
            concept: CountingGame.concept,
            kind: CountingGame.generate(Random(1)).first.kind,
            correct: true,
            wrongs: 0,
            hints: 0,
          ),
      ];
      var total = 0;
      for (var i = 0; i < 8; i++) {
        total += (await repo.recordGame(
          profileId: id,
          activityId: CountingGame.activityId,
          results: perfect(),
          starsCap: CountingGame.starsCap,
        )).earned;
      }
      expect(total, CountingGame.starsCap);
      expect(await db.activityDao.totalStars(id), CountingGame.starsCap);
    });
  });

  group('ExamPrep.derive', () {
    InstalledLesson installed(String id, {int quiz = 6, bool summary = true}) =>
        InstalledLesson(
          lesson: catalog.lessonById(id)!,
          parts: [if (summary) LessonPart.summary, LessonPart.quiz],
          bytes: 1000,
          quizCount: quiz,
        );

    late AppDatabase db;
    late String id;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      id = (await ProfileRepository(
        db,
      ).create(name: 'سارة', grade: 11, color: ProfileColor.blue)).id;
    });

    tearDown(() => db.close());

    Future<ExamPrep> derive(List<InstalledLesson> lessons) async =>
        ExamPrep.derive(
          catalog: catalog,
          installed: lessons,
          attempts: await db.select(db.attempts).get(),
          mastery: await db.activityDao.getMastery(id),
        );

    test(
      'بلا نشاط: لا جاهزية ولا نقاط ضعف، والخطة تبدأ بأول درس متوفر',
      () async {
        final p = await derive([installed('math.u1.l1')]);
        expect(p.readiness, isNull);
        expect(p.weak, isEmpty);
        expect(p.plan.first.kind, PlanKind.review);
        expect(p.mockLesson!.lesson.id, 'math.u1.l1');
        expect(p.summaryLessons, 1);
      },
    );

    test('بلا أي محتوى: خطوة «ابدأ بأول درس» فقط ولا امتحان', () async {
      final p = await derive([]);
      expect(p.plan.single.kind, PlanKind.start);
      expect(p.mockLesson, isNull);
    });

    test('الجاهزية = متوسط آخر 3 اختبارات فقط', () async {
      Future<void> quiz(int score, int total, int day) =>
          db.activityDao.insertAttempt(
            profileId: id,
            activityId: 'x',
            kind: AttemptKind.quiz,
            score: score,
            total: total,
            starsEarned: 0,
            now: DateTime(2026, 10, day),
          );
      await quiz(0, 10, 1);
      await quiz(5, 10, 2);
      await quiz(8, 10, 3);
      await quiz(10, 10, 4);
      final p = await derive([installed('math.u1.l1')]);
      expect(p.basedOn, 3);
      expect(p.readiness, 77);
    });

    test('نقاط الضعف: ثلاثة أضعف مفاهيم، والخطة تتبع درس الأضعف', () async {
      Future<void> m(String c, double v) => db.activityDao.upsertMastery(
        profileId: id,
        conceptId: c,
        mastery: v,
        now: DateTime(2026, 10, 1),
      );
      await m('math.u1.l1.c1', 0.9);
      await m('math.u1.l1.c2', 0.5);
      await m('math.u1.l2.c1', 0.2);
      await m('math.u2.l1.c1', 0.7);
      final p = await derive([
        installed('math.u1.l1'),
        installed('math.u1.l2'),
      ]);
      expect(p.weak.map((w) => w.concept.id), [
        'math.u1.l2.c1',
        'math.u1.l1.c2',
        'math.u2.l1.c1',
      ]);
      expect(p.mockLesson!.lesson.id, 'math.u1.l2');
      expect(p.plan[1].route, contains('concept=math.u1.l2.c1'));
    });
  });

  testWidgets('رئيسية الصفوف 1–4: تحية صوتية ولعبة اليوم ومواد كبيرة', (
    tester,
  ) {
    final speech = FakeSpeech();
    return scenario(
      tester,
      seed: (r) async {
        await r.create(name: 'ليان', grade: 2, color: ProfileColor.coral);
      },
      overrides: [speechServiceProvider.overrideWithValue(speech)],
      (db) async {
        expect(find.text(ArKids.greeting('ليان')), findsOneWidget);
        expect(find.text(ArKids.todayGame), findsOneWidget);
        for (final s in ['الرياضيات', 'العربية', 'العلوم', 'الإنجليزية']) {
          expect(find.text(s), findsOneWidget);
        }
        await tester.tap(find.text(ArKids.listen));
        await tester.pumpAndSettle();
        expect(speech.spoken, [ArKids.greeting('ليان')]);
        expect(speech.languages, ['ar']);

        await tester.tap(find.text('الرياضيات'));
        await tester.pumpAndSettle();
        expect(find.text(ArLearn.unitsTitle), findsOneWidget);
      },
    );
  });

  testWidgets(
    'لعبة العدّ كاملة: صح ثم خطأ فتلميح ثم كشف، وتُحفظ المحاولة بالنجوم',
    (tester) => scenario(
      tester,
      seed: (r) async {
        await r.create(name: 'ليان', grade: 2, color: ProfileColor.coral);
      },
      overrides: [roundRandomProvider.overrideWithValue(Random(3))],
      (db) async {
        await tester.tap(find.text(ArKids.todayGame));
        await tester.pumpAndSettle();
        expect(find.text(ArKids.listenQuestion), findsOneWidget);

        final expected = CountingGame.generate(Random(3));
        for (final (i, q) in expected.indexed) {
          final choices = (q as dynamic).choices as List<String>;
          final answer = (q).visual!.count;
          if (i == 1) {
            final wrong = choices.firstWhere((c) => c != '$answer');
            await tester.tap(find.bySemanticsLabel(wrong));
            await tester.pumpAndSettle();
            expect(find.text(ArKids.gameHint), findsOneWidget);
            final other = choices.firstWhere(
              (c) => c != '$answer' && c != wrong,
            );
            await tester.tap(find.bySemanticsLabel(other));
            await tester.pumpAndSettle();
            expect(find.text(ArLearn.revealedTitle), findsOneWidget);
          } else {
            await tester.tap(find.bySemanticsLabel('$answer'));
            await tester.pumpAndSettle();
            expect(find.text(ArLearn.correctTitle(3)), findsOneWidget);
          }
          await tester.tap(
            find.text(i == 4 ? ArLearn.finishRound : ArLearn.nextQuestion),
          );
          await tester.pumpAndSettle();
        }

        expect(find.text(ArKids.gameEndTitle), findsOneWidget);
        expect(find.text(ArKids.gameEndBody(4, 5)), findsOneWidget);
        final attempts = (await tester.runAsync(
          () => db.select(db.attempts).get(),
        ))!;
        expect(attempts.single.activityId, CountingGame.activityId);
        expect(attempts.single.score, 4);
        expect(attempts.single.starsEarned, 12);
        expect(find.text(ArKids.gameEndStars(12)), findsOneWidget);

        await tester.tap(find.text(ArKids.gameBackHome));
        await tester.pumpAndSettle();
        expect(find.text(ArKids.greeting('ليان')), findsOneWidget);
      },
    ),
  );

  testWidgets(
    'رئيسية الصفوف 9–12: الاستعداد للامتحان من بيانات الطالب',
    (tester) => scenario(
      tester,
      seed: (r) async {
        await r.create(name: 'سارة', grade: 11, color: ProfileColor.blue);
      },
      (db) async {
        expect(find.text(ArKids.examTitle), findsOneWidget);
        expect(find.text(ArKids.readinessNone), findsOneWidget);
        expect(find.text(ArKids.weakEmpty), findsOneWidget);
        expect(find.text(ArKids.tileMock), findsOneWidget);

        final profile = (await tester.runAsync(
          () => db.profilesDao.getAll(),
        ))!.single;
        await onDb(
          tester,
          () => db.activityDao.insertAttempt(
            profileId: profile.id,
            activityId: 'math.u1.l1.quiz',
            kind: AttemptKind.quiz,
            score: 4,
            total: 5,
            starsEarned: 0,
            now: DateTime.now(),
          ),
        );
        await onDb(
          tester,
          () => db.activityDao.upsertMastery(
            profileId: profile.id,
            conceptId: 'math.u1.l1.c2',
            mastery: 0.4,
            now: DateTime.now(),
          ),
        );
        expect(find.text('80%'), findsWidgets);
        expect(find.text(ArKids.readinessBased(1)), findsOneWidget);
        expect(find.text(ArKids.weakEmpty), findsNothing);

        await tester.tap(find.text(ArKids.tileMock));
        await tester.pumpAndSettle();
        expect(find.text(ArLearn.confirmAnswer), findsOneWidget);
      },
    ),
  );

  testWidgets(
    'الصفوف 5–8 تبقى على الرئيسية العادية',
    (tester) => scenario(
      tester,
      seed: (r) async {
        await r.create(name: 'أنس', grade: 6, color: ProfileColor.teal);
      },
      (db) async {
        expect(
          find.text(ArStrings.homeFirstDayGreeting('أنس')),
          findsOneWidget,
        );
        expect(find.text(ArKids.examTitle), findsNothing);
        expect(find.text(ArKids.todayGame), findsNothing);
      },
    ),
  );
}
