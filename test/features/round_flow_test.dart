import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/app/rizma_app.dart';
import 'package:rizma/app/router.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/core/strings/ar_learning.dart';
import 'package:rizma/core/widgets/rizma_button.dart';
import 'package:rizma/features/content/content_providers.dart';
import 'package:rizma/features/content/content_repository.dart';
import 'package:rizma/features/content/question.dart';
import 'package:rizma/features/content/speech_service.dart';
import 'package:rizma/features/learning/round_engine.dart';
import 'package:rizma/features/learning/widgets/interactive_views.dart';
import 'package:rizma/features/learning/widgets/question_context.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

import '../helpers/app_harness.dart';
import '../helpers/load_fonts.dart';

const lesson = 'math.u1.l1';
const c1 = 'math.u1.l1.c1';

Map<String, dynamic> choiceQ({
  String id = 'p1',
  List<String> hints = const ['ت1', 'ت2'],
  List<String> solution = const ['خطوة الحل'],
}) => {
  'id': id,
  'type': 'choice',
  'concept': c1,
  'prompt': 'ما ناتج جمع اثنين واثنين؟',
  'choices': ['3', '4', '5', '6'],
  'answer': 1,
  'hints': hints,
  'solution': solution,
  'explanation': 'لأن اثنين زائد اثنين تساوي أربعة.',
};

Override contentWith({
  List<Map<String, dynamic>> practice = const [],
  List<Map<String, dynamic>> quiz = const [],
}) => contentRepositoryProvider.overrideWithValue(
  ContentRepository(
    loadString: (_) async =>
        jsonEncode({'lessonId': lesson, 'practice': practice, 'quiz': quiz}),
    listAssets: () async => ['assets/content/lessons/$lesson.json'],
  ),
);

void main() {
  setUpAll(loadCairoFont);

  Future<void> seedProfile(ProfileRepository repo) =>
      repo.create(name: 'أنس', grade: 5, color: ProfileColor.teal);

  Future<void> open(WidgetTester tester, String location) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RizmaApp)),
    );
    container.read(routerProvider).push(location);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final f = find.text(text);
    await tester.ensureVisible(f.last);
    await tester.tap(f.last);
    await tester.pumpAndSettle();
  }

  Future<void> setMastery(
    WidgetTester tester,
    AppDatabase db,
    String profileId,
    String concept,
    double value,
  ) => onDb(
    tester,
    () => db.activityDao.upsertMastery(
      profileId: profileId,
      conceptId: concept,
      mastery: value,
      now: DateTime(2026, 10, 8),
    ),
  );

  Future<Attempt> lastAttempt(WidgetTester tester, AppDatabase db) async {
    final profile = (await tester.runAsync(
      () => db.profilesDao.getAll(),
    ))!.single;
    final all = (await tester.runAsync(
      () => db.select(db.attempts).get(),
    ))!.where((a) => a.profileId == profile.id).toList();
    return all.last;
  }

  group('التدريب', () {
    testWidgets(
      'اختيار: خطأ يُظهر تلميحًا، ثم صح بعد التلميح الثاني = نجمة، ثم نهاية الجولة',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(practice: [choiceQ()]),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          expect(find.text('ما ناتج جمع اثنين واثنين؟'), findsOneWidget);
          expect(find.text(ArLearn.roundQuestionOf(1, 1)), findsOneWidget);

          await tapText(tester, '3');
          expect(find.text(ArLearn.hintStage(1, 3)), findsOneWidget);
          expect(find.text('ت1'), findsOneWidget);

          await tapText(tester, '5');
          expect(find.text(ArLearn.hintStage(2, 3)), findsOneWidget);
          expect(find.text('ت2'), findsOneWidget);

          await tapText(tester, '4');
          expect(find.text(ArLearn.correctTitle(1)), findsOneWidget);
          expect(
            find.text('لأن اثنين زائد اثنين تساوي أربعة.'),
            findsOneWidget,
          );

          await tapText(tester, ArLearn.finishRound);
          expect(find.text(ArLearn.roundEndTitle), findsOneWidget);
          final a = await lastAttempt(tester, db);
          expect(a.score, 1);
          expect(a.total, 1);
          expect(a.hintsUsed, 2);
          expect(a.starsEarned, 1);
        },
      ),
    );

    testWidgets(
      'ثلاث إجابات خاطئة تكشف الحل خطوة بخطوة وتُحتسب خطأ',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(practice: [choiceQ()]),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          await tapText(tester, '3');
          await tapText(tester, '5');
          await tapText(tester, '6');
          expect(find.text(ArLearn.revealedTitle), findsOneWidget);
          expect(find.text('خطوة الحل'), findsOneWidget);

          await tapText(tester, ArLearn.finishRound);
          final a = await lastAttempt(tester, db);
          expect(a.score, 0);
          expect(a.starsEarned, 0);
          expect(a.hintsUsed, 3);
        },
      ),
    );

    testWidgets(
      '«التلميح الأخير» يكشف الحل مبكرًا بعد خطأ',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(practice: [choiceQ()]),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          expect(find.text(ArLearn.lastHint), findsNothing);
          await tapText(tester, '3');
          await tapText(tester, ArLearn.lastHint);
          expect(find.text(ArLearn.revealedTitle), findsOneWidget);
          expect(find.text('خطوة الحل'), findsOneWidget);
        },
      ),
    );

    testWidgets(
      'صح أو خطأ: الردّ فوري ويمنح 3 نجوم',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(
            practice: [
              {
                'id': 'p1',
                'type': 'trueFalse',
                'concept': c1,
                'prompt': 'هل هذه العبارة صحيحة؟',
                'statement': 'الشمس نجم',
                'answer': true,
              },
            ],
          ),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          expect(find.text('الشمس نجم'), findsOneWidget);
          await tapText(tester, ArLearn.answerTrue);
          expect(find.text(ArLearn.correctTitle(3)), findsOneWidget);
        },
      ),
    );

    testWidgets(
      'اسحب وأفلت: التأكيد معطّل حتى توضع بطاقة، والخطأ يعطي تلميحًا',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(
            practice: [
              {
                'id': 'p1',
                'type': 'dragDrop',
                'concept': c1,
                'prompt': 'اسحب الرقم المناسب',
                'template': 'ثلاثة {?}27',
                'cards': ['5', '2'],
                'answer': '5',
                'hints': ['فكّر في المئات'],
              },
            ],
          ),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          RizmaButton confirm() =>
              tester.widget<RizmaButton>(find.byType(RizmaButton));
          expect(confirm().onPressed, isNull);
          expect(find.text(ArLearn.confirmDisabledNote), findsOneWidget);

          await tapText(tester, '2');
          expect(confirm().onPressed, isNotNull);
          await tapText(tester, ArLearn.confirmAnswer);
          expect(find.text('فكّر في المئات'), findsOneWidget);

          await tapText(tester, '5');
          await tapText(tester, ArLearn.tryAgain);
          expect(find.text(ArLearn.correctTitle(2)), findsOneWidget);
        },
      ),
    );

    testWidgets(
      'توصيل الأزواج: لا يكتمل إلا بوصل الكل، والتوصيل الصحيح ينجح',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(
            practice: [
              {
                'id': 'p1',
                'type': 'matchPairs',
                'concept': c1,
                'prompt': 'وصّل كل مادة بحالتها',
                'pairs': [
                  {
                    'left': {'text': 'الجليد'},
                    'right': {'text': 'صلب'},
                  },
                  {
                    'left': {'text': 'الماء'},
                    'right': {'text': 'سائل'},
                  },
                ],
              },
            ],
          ),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          RizmaButton confirm() =>
              tester.widget<RizmaButton>(find.byType(RizmaButton));
          await tapText(tester, 'الجليد');
          await tapText(tester, 'صلب');
          expect(confirm().onPressed, isNull);
          expect(find.text(ArLearn.matchProgress(1, 2)), findsOneWidget);

          await tapText(tester, 'الماء');
          await tapText(tester, 'سائل');
          expect(confirm().onPressed, isNotNull);
          await tapText(tester, ArLearn.confirmAnswer);
          expect(find.text(ArLearn.correctTitle(3)), findsOneWidget);
        },
      ),
    );

    testWidgets('الصفوف 1–4: يُقرأ السؤال بالصوت تلقائيًا مرة واحدة', (tester) {
      final speech = FakeSpeech();
      return scenario(
        tester,
        seed: (repo) =>
            repo.create(name: 'ليان', grade: 2, color: ProfileColor.coral),
        overrides: [
          speechServiceProvider.overrideWithValue(speech),
          contentWith(practice: [choiceQ()]),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          expect(speech.spoken, ['ما ناتج جمع اثنين واثنين؟']);
          expect(speech.languages, ['ar']);
          await tapText(tester, '3');
          expect(speech.spoken.length, 1);
        },
      );
    });

    testWidgets('الصف 5: لا قراءة تلقائية', (tester) {
      final speech = FakeSpeech();
      return scenario(
        tester,
        seed: seedProfile,
        overrides: [
          speechServiceProvider.overrideWithValue(speech),
          contentWith(practice: [choiceQ()]),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          expect(speech.spoken, isEmpty);
        },
      );
    });

    testWidgets('استمع واختر: ينطق الكلمة (عادي وبطيء) ثم يصحّح الاختيار', (
      tester,
    ) {
      final speech = FakeSpeech();
      return scenario(
        tester,
        seed: seedProfile,
        overrides: [
          speechServiceProvider.overrideWithValue(speech),
          contentWith(
            practice: [
              {
                'id': 'p1',
                'type': 'listenChoose',
                'concept': c1,
                'prompt': 'اضغط لتسمع الكلمة، ثم اختر صورتها',
                'word': 'Apple',
                'choices': ['apple', 'orange', 'banana', 'grapes'],
                'answer': 0,
              },
            ],
          ),
        ],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          await tester.tap(find.bySemanticsLabel(ArLearn.partWords));
          await tester.pumpAndSettle();
          await tester.tap(find.text(ArLearn.listenSlow));
          await tester.pumpAndSettle();
          expect(speech.spoken, ['Apple', 'Apple']);
          expect(speech.slowFlags, [false, true]);
          expect(speech.languages, ['en-US', 'en-US']);

          await tester.tap(find.bySemanticsLabel('apple'));
          await tester.pumpAndSettle();
          await tapText(tester, ArLearn.confirmAnswer);
          expect(find.text(ArLearn.correctTitle(3)), findsOneWidget);
        },
      );
    });

    testWidgets(
      'الجولة المكرّرة لا تعطي نجومًا جديدة وتُخبر الطالب',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(
            practice: [choiceQ(hints: const [], solution: const [])],
          ),
        ],
        (db) async {
          Future<void> playRight() async {
            await open(tester, '/learn/round/$lesson');
            await tapText(tester, '4');
            await tapText(tester, ArLearn.finishRound);
          }

          await playRight();
          expect(find.text('+3'), findsOneWidget);
          await playRight();
          expect(find.text('+0'), findsOneWidget);
          expect(find.text(ArLearn.roundEndNoNewStars), findsOneWidget);
        },
      ),
    );

    testWidgets(
      'زر الإغلاق يسأل قبل الخروج، والبقاء يكمل الجولة، والخروج لا يحفظ شيئًا',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [
          contentWith(practice: [choiceQ()]),
        ],
        (db) async {
          await open(tester, '/lesson/$lesson');
          await open(tester, '/learn/round/$lesson');
          await tester.tap(find.bySemanticsLabel(ArLearn.roundClose));
          await tester.pumpAndSettle();
          expect(find.text(ArLearn.quitTitle), findsOneWidget);

          await tester.tap(find.text(ArLearn.quitStay));
          await tester.pumpAndSettle();
          expect(find.text('ما ناتج جمع اثنين واثنين؟'), findsOneWidget);

          await tester.tap(find.bySemanticsLabel(ArLearn.roundClose));
          await tester.pumpAndSettle();
          await tester.tap(find.text(ArLearn.quitLeave));
          await tester.pumpAndSettle();
          expect(find.text('ما ناتج جمع اثنين واثنين؟'), findsNothing);
          expect(
            (await tester.runAsync(() => db.select(db.attempts).get()))!,
            isEmpty,
          );
        },
      ),
    );

    testWidgets(
      'درس بلا أسئلة يعرض رسالة بدل جولة فارغة',
      (tester) => scenario(
        tester,
        seed: seedProfile,
        overrides: [contentWith()],
        (db) async {
          await open(tester, '/learn/round/$lesson');
          expect(find.text(ArLearn.roundNoQuestions), findsOneWidget);
        },
      ),
    );
  });

  group('الاختبار', () {
    final content =
        jsonDecode(
              File('assets/content/lessons/$lesson.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final quiz = (content['quiz'] as List).cast<Map<String, dynamic>>();

    testWidgets(
      'يجيب الطالب بلا ردّ فوري ثم تظهر النتيجة وتُحفظ المحاولة',
      (tester) => scenario(tester, seed: seedProfile, (db) async {
        await open(tester, '/learn/quiz/$lesson');
        final lastConcept = quiz.last['concept'];
        final wrong = [
          for (final (i, q) in quiz.indexed)
            if (q['concept'] == lastConcept) i,
        ].reversed.take(2).toSet();
        for (final (i, q) in quiz.indexed) {
          final choices = (q['choices'] as List).cast<String>();
          final right = q['answer'] as int;
          final pick = wrong.contains(i)
              ? (right + 1) % choices.length
              : right;
          await tapText(tester, choices[pick]);
          expect(find.text(ArLearn.revealedTitle), findsNothing);
          expect(find.text(ArLearn.hintTitle), findsNothing);
          await tapText(tester, ArLearn.confirmAnswer);
        }

        final correct = quiz.length - 2;
        final percent = (correct * 100 / quiz.length).round();
        expect(find.text('$percent%'), findsOneWidget);
        expect(find.text(ArLearn.resultHeadingGood('أنس')), findsOneWidget);
        expect(find.text(ArLearn.resultStartReview), findsOneWidget);

        final a = await lastAttempt(tester, db);
        expect(a.score, correct);
        expect(a.total, quiz.length);
        final parts = (await tester.runAsync(
          () => db.activityDao.getLessonParts(a.profileId),
        ))!;
        expect(parts.map((p) => p.part.name), contains('quiz'));
      }),
    );

    testWidgets(
      'تأكيد الإجابة معطّل حتى يختار الطالب',
      (tester) => scenario(tester, seed: seedProfile, (db) async {
        await open(tester, '/learn/quiz/$lesson');
        final button = tester.widget<RizmaButton>(find.byType(RizmaButton));
        expect(button.onPressed, isNull);
      }),
    );
  });

  group('خطة المراجعة', () {
    testWidgets(
      'تعرض أضعف مفهوم وخطواتها، و«تابع» يفتح أول خطوة',
      (tester) => scenario(tester, seed: seedProfile, (db) async {
        final profile = (await tester.runAsync(
          () => db.profilesDao.getAll(),
        ))!.single;
        await setMastery(tester, db, profile.id, 'math.u1.l1.c1', 0.9);
        await setMastery(tester, db, profile.id, 'math.u1.l1.c2', 0.4);
        await open(tester, '/learn/review/$lesson');
        expect(find.text(ArLearn.reviewTitle), findsOneWidget);
        expect(find.text('40%'), findsOneWidget);
        expect(find.text(ArLearn.reviewStepExplain), findsOneWidget);
        expect(find.text(ArLearn.reviewStepQuiz), findsOneWidget);

        await tapText(
          tester,
          ArLearn.reviewContinue(ArLearn.reviewStepExplain),
        );
        expect(find.text(ArLearn.explainTitle), findsOneWidget);
      }),
    );

    testWidgets(
      'كل المفاهيم متقنة ← رسالة «أتقنت هذا الدرس»',
      (tester) => scenario(tester, seed: seedProfile, (db) async {
        final profile = (await tester.runAsync(
          () => db.profilesDao.getAll(),
        ))!.single;
        for (final id in ['math.u1.l1.c1', 'math.u1.l1.c2']) {
          await setMastery(tester, db, profile.id, id, 0.95);
        }
        await open(tester, '/learn/review/$lesson');
        expect(find.text(ArLearn.reviewDoneTitle), findsOneWidget);
      }),
    );
  });

  group('الترتيب', () {
    testWidgets('السحب بالضغط المطوّل يغيّر الترتيب ويبلّغ بالأرقام الأصلية', (
      tester,
    ) async {
      final q =
          Question.fromJson({
                'id': 'o1',
                'concept': c1,
                'type': 'order',
                'prompt': 'رتّب',
                'items': [
                  {'label': 'الآلاف'},
                  {'label': 'المئات'},
                  {'label': 'العشرات'},
                ],
              })
              as OrderQuestion;
      Object? reported;
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderView(
                context_: QuestionContext(
                  question: q,
                  layout: const QuestionLayout(order: [1, 0, 2]),
                  mode: RoundMode.practice,
                  phase: RoundPhase.answering,
                  lastAnswer: null,
                  number: 1,
                  total: 1,
                  onAnswer: (a) => reported = a,
                  onSpeak: (_, {slow = false}) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final from = tester.getCenter(find.text('الآلاف'));
      final gesture = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 600));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, -12));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(reported, [0, 1, 2]);
      expect(q.check(reported), isTrue);
    });
  });
}
