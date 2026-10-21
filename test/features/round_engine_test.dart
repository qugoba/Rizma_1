import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/db/app_database.dart';
import 'package:rizma/features/content/lesson_content.dart';
import 'package:rizma/features/content/question.dart';
import 'package:rizma/features/learning/learning_repository.dart';
import 'package:rizma/features/learning/round_engine.dart';
import 'package:rizma/features/profiles/profile_repository.dart';

Question q(Map<String, dynamic> json) =>
    Question.fromJson({'id': 'q', 'concept': 'c1', 'prompt': 'p', ...json});

Question choice({
  List<String> choices = const ['أ', 'ب', 'ج', 'د'],
  int answer = 1,
  List<String> hints = const [],
  List<String> solution = const [],
  String concept = 'c1',
  String id = 'q',
}) => q({
  'id': id,
  'concept': concept,
  'type': 'choice',
  'choices': choices,
  'answer': answer,
  'hints': hints,
  'solution': solution,
});

void main() {
  test('النجوم: 3 من أول محاولة، 2 بعد التلميح الأول، 1 بعد الثاني', () {
    expect(QuestionResult.starsFor(0), 3);
    expect(QuestionResult.starsFor(1), 2);
    expect(QuestionResult.starsFor(2), 1);
    expect(QuestionResult.starsFor(5), 1);
    const wrong = QuestionResult(
      questionId: 'q',
      concept: 'c',
      kind: QuestionKind.choice,
      correct: false,
      wrongs: 3,
      hints: 3,
    );
    expect(wrong.stars, 0);
  });

  group('خلط العرض', () {
    test('الخيارات تُخلط بتبديل والجواب الأصلي يبقى صالحًا', () {
      final question = choice(answer: 2) as ChoiceQuestion;
      final s = RoundEngine.start(
        mode: RoundMode.practice,
        questions: [question],
        random: Random(1),
      );
      final order = s.layouts.single.order;
      expect([...order]..sort(), [0, 1, 2, 3]);
      expect(question.check(2), isTrue);
    });

    test('«كل ما سبق» يمنع الخلط', () {
      final question = choice(choices: ['أ', 'ب', 'كل ما سبق']);
      final s = RoundEngine.start(
        mode: RoundMode.practice,
        questions: [question],
        random: Random(1),
      );
      expect(s.layouts.single.order, [0, 1, 2]);
    });

    test('الترتيب والتوصيل لا يبدآن بالحل الصحيح', () {
      final order = q({
        'type': 'order',
        'items': [
          {'label': '1'},
          {'label': '2'},
          {'label': '3'},
        ],
      });
      for (var seed = 0; seed < 30; seed++) {
        final s = RoundEngine.start(
          mode: RoundMode.practice,
          questions: [order],
          random: Random(seed),
        );
        expect(s.layouts.single.order, isNot([0, 1, 2]));
      }
    });
  });

  group('اختيار الأسئلة', () {
    final pool = [for (var i = 0; i < 12; i++) choice(id: 'q$i')];

    test('التدريب: 8 أسئلة كحدّ أقصى، مخلوطة', () {
      final picked = RoundEngine.pick(
        pool,
        RoundMode.practice,
        random: Random(3),
      );
      expect(picked.length, RoundEngine.practiceLength);
      expect(picked.map((e) => e.id).toSet().length, 8);
    });

    test('الصفوف 1–4: خمسة أسئلة تدريب بلا «رتّب»', () {
      final order = q({
        'id': 'o1',
        'type': 'order',
        'items': [
          {'label': '1'},
          {'label': '2'},
        ],
      });
      final picked = RoundEngine.pick(
        [order, ...pool],
        RoundMode.practice,
        random: Random(3),
        kids: true,
      );
      expect(picked.length, RoundEngine.kidsPracticeLength);
      expect(picked.whereType<OrderQuestion>(), isEmpty);
      final onlyOrder = RoundEngine.pick(
        [order],
        RoundMode.practice,
        random: Random(3),
        kids: true,
      );
      expect(onlyOrder.single.id, 'o1');
    });

    test('الاختبار: ترتيب المؤلّف وحدّ 10', () {
      final picked = RoundEngine.pick(pool, RoundMode.quiz, random: Random(3));
      expect(picked.map((e) => e.id), [for (var i = 0; i < 10; i++) 'q$i']);
    });

    test('حصر المفهوم، وإن لم توجد أسئلة له يرجع لكل الأسئلة', () {
      final mixed = [
        choice(id: 'a', concept: 'x'),
        choice(id: 'b', concept: 'y'),
        choice(id: 'c', concept: 'x'),
      ];
      final only = RoundEngine.pick(
        mixed,
        RoundMode.practice,
        random: Random(1),
        concept: 'x',
      );
      expect(only.map((e) => e.id).toSet(), {'a', 'c'});
      final fallback = RoundEngine.pick(
        mixed,
        RoundMode.practice,
        random: Random(1),
        concept: 'zzz',
      );
      expect(fallback.length, 3);
    });
  });

  group('التدريب: تلميحات متدرّجة', () {
    RoundState start(Question question) => RoundEngine.start(
      mode: RoundMode.practice,
      questions: [question],
      random: Random(1),
    );

    test('صح من أول مرة: 3 نجوم وإتقان 1', () {
      var s = start(choice(hints: ['ت1']));
      s = RoundEngine.submit(s, 1);
      expect(s.phase, RoundPhase.correct);
      s = RoundEngine.advance(s);
      expect(s.finished, isTrue);
      final r = s.results.single;
      expect(r.firstTry, isTrue);
      expect(r.stars, 3);
      expect(r.value, 1);
      expect(r.hints, 0);
    });

    test('خطأ ثم صح: تلميح ظاهر ونجمتان وإتقان نصف', () {
      var s = start(choice(hints: ['ت1', 'ت2']));
      s = RoundEngine.submit(s, 0);
      expect(s.phase, RoundPhase.answering);
      expect(s.hintsShown, 1);
      s = RoundEngine.submit(s, 1);
      s = RoundEngine.advance(s);
      final r = s.results.single;
      expect(r.correct, isTrue);
      expect(r.wrongs, 1);
      expect(r.hints, 1);
      expect(r.stars, 2);
      expect(r.value, 0.5);
    });

    test('تلميحان ثم خطأ ثالث يكشف الحل ويُحتسب خطأ', () {
      var s = start(choice(hints: ['ت1', 'ت2'], solution: ['خطوة']));
      s = RoundEngine.submit(s, 0);
      s = RoundEngine.submit(s, 2);
      expect(s.phase, RoundPhase.answering);
      expect(s.hintsShown, 2);
      s = RoundEngine.submit(s, 3);
      expect(s.phase, RoundPhase.revealed);
      expect(s.solutionShown, isTrue);
      s = RoundEngine.advance(s);
      final r = s.results.single;
      expect(r.correct, isFalse);
      expect(r.stars, 0);
      expect(r.hints, 3);
    });

    test('بلا تلميحات: أول خطأ يكشف الجواب فورًا', () {
      var s = start(choice());
      s = RoundEngine.submit(s, 0);
      expect(s.phase, RoundPhase.revealed);
      expect(s.solutionShown, isFalse);
    });

    test('«الحل خطوة بخطوة» مبكرًا بعد خطأ فقط', () {
      var s = start(choice(hints: ['ت1', 'ت2'], solution: ['خطوة']));
      expect(s.canRevealSolution, isFalse);
      expect(RoundEngine.revealSolution(s).phase, RoundPhase.answering);
      s = RoundEngine.submit(s, 0);
      expect(s.canRevealSolution, isTrue);
      s = RoundEngine.revealSolution(s);
      expect(s.phase, RoundPhase.revealed);
      expect(RoundEngine.advance(s).results.single.correct, isFalse);
    });

    test('لا تُقبل إجابة بعد الإجابة الصحيحة', () {
      var s = start(choice());
      s = RoundEngine.submit(s, 1);
      final again = RoundEngine.submit(s, 0);
      expect(again.phase, RoundPhase.correct);
      expect(again.wrongs, 0);
    });
  });

  group('الاختبار', () {
    test('محاولة واحدة وينتقل فورًا بلا تلميحات', () {
      var s = RoundEngine.start(
        mode: RoundMode.quiz,
        questions: [
          choice(id: 'a', hints: ['ت1']),
          choice(id: 'b'),
        ],
        random: Random(1),
      );
      s = RoundEngine.submit(s, 0);
      expect(s.index, 1);
      expect(s.results.single.correct, isFalse);
      expect(s.hintsShown, 0);
      s = RoundEngine.submit(s, 1);
      expect(s.finished, isTrue);
      expect(RoundEngine.percent(s.results), 50);
    });
  });

  group('الأنواع الأخرى تُصحَّح بالأرقام الأصلية', () {
    test('توصيل وترتيب وسحب وصح/خطأ واستمع', () {
      final match = q({
        'type': 'matchPairs',
        'pairs': [
          {
            'left': {'text': 'a'},
            'right': {'text': 'b'},
          },
          {
            'left': {'text': 'c'},
            'right': {'text': 'd'},
          },
        ],
      });
      expect(match.check({0: 0, 1: 1}), isTrue);
      expect(match.check({0: 1, 1: 0}), isFalse);
      expect(match.check({0: 0}), isFalse);

      final order = q({
        'type': 'order',
        'items': [
          {'label': 'a'},
          {'label': 'b'},
          {'label': 'c'},
        ],
      });
      expect(order.check([0, 1, 2]), isTrue);
      expect(order.check([1, 0, 2]), isFalse);

      final drag = q({
        'type': 'dragDrop',
        'template': '{?}/8',
        'cards': ['4', '6'],
        'answer': '6',
      });
      expect(drag.check('6'), isTrue);
      expect(drag.check('4'), isFalse);

      final tf = q({'type': 'trueFalse', 'statement': 's', 'answer': true});
      expect(tf.check(true), isTrue);
      expect(tf.check(false), isFalse);

      final listen = q({
        'type': 'listenChoose',
        'word': 'Apple',
        'choices': ['apple', 'lemon'],
        'answer': 0,
      });
      expect(listen.check(0), isTrue);
    });
  });

  group('تقييم الجولة', () {
    QuestionResult res(bool ok, {int wrongs = 0}) => QuestionResult(
      questionId: 'q',
      concept: 'c',
      kind: QuestionKind.choice,
      correct: ok,
      wrongs: wrongs,
      hints: 0,
    );

    test('عتبات النجوم 30% و60% و90%', () {
      List<QuestionResult> mix(int right, int total) => [
        for (var i = 0; i < total; i++) res(i < right),
      ];
      expect(RoundEngine.ratingStars(mix(0, 10)), 0);
      expect(RoundEngine.ratingStars(mix(3, 10)), 1);
      expect(RoundEngine.ratingStars(mix(6, 10)), 2);
      expect(RoundEngine.ratingStars(mix(9, 10)), 3);
      expect(RoundEngine.ratingStars(const []), 0);
    });

    test('الإتقان: أول قيمة كما هي ثم متوسط متحرّك', () {
      expect(RoundEngine.nextMastery(null, 0.5), 0.5);
      expect(RoundEngine.nextMastery(1, 0), closeTo(0.6, 1e-9));
      expect(RoundEngine.nextMastery(0, 1), closeTo(0.4, 1e-9));
    });

    test('مجموع النجوم', () {
      expect(
        RoundEngine.starsEarned([res(true), res(true, wrongs: 1), res(false)]),
        5,
      );
    });
  });

  group('تسجيل الجولة في قاعدة البيانات', () {
    late AppDatabase db;
    late LearningRepository repo;
    late String profileId;
    var clock = DateTime(2026, 10, 8, 10);
    late LessonContent content;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      clock = DateTime(2026, 10, 8, 10);
      repo = LearningRepository(db, now: () => clock);
      profileId = (await ProfileRepository(
        db,
      ).create(name: 'أنس', grade: 5, color: ProfileColor.teal)).id;
      content = LessonContent.fromJson(
        jsonDecode(
              File('assets/content/lessons/math.u3.l3.json').readAsStringSync(),
            )
            as Map<String, dynamic>,
      );
    });

    tearDown(() => db.close());

    List<QuestionResult> results(List<bool> oks, {String concept = 'c1'}) => [
      for (final (i, ok) in oks.indexed)
        QuestionResult(
          questionId: 'q$i',
          concept: concept,
          kind: QuestionKind.choice,
          correct: ok,
          wrongs: ok ? 0 : 1,
          hints: ok ? 0 : 1,
        ),
    ];

    test('يحفظ المحاولة والتفاصيل والإتقان وينجز جزء التدريب', () async {
      final record = await repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.practice,
        results: results([true, true, false]),
        content: content,
      );
      expect(record.earned, 6);

      final loaded = (await repo.loadAttempt(profileId, record.attemptId))!;
      expect(loaded.attempt.score, 2);
      expect(loaded.attempt.total, 3);
      expect(loaded.attempt.hintsUsed, 1);
      expect(loaded.attempt.activityId, 'math.u3.l3.practice');
      expect(loaded.details.results.length, 3);
      expect(loaded.details.masteryBefore['c1'], isNull);
      expect(loaded.details.masteryAfter['c1'], isNotNull);

      final parts = await db.activityDao.getLessonParts(profileId);
      expect(parts.map((p) => p.part), contains(LessonPart.practice));
      final mastery = await db.activityDao.getMastery(profileId);
      expect(mastery.single.conceptId, 'c1');
    });

    test('جولة مكرّرة لا تضيف نجومًا مكرّرة، والأحسن يضيف الفرق فقط', () async {
      Future<int> run(List<bool> oks) async => (await repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.practice,
        results: results(oks),
        content: content,
      )).earned;

      expect(await run([true, false]), 3);
      expect(await run([true, false]), 0);
      expect(await run([true, true]), 3);
      expect(
        await db.activityDao.starsForActivity(profileId, 'math.u3.l3.practice'),
        6,
      );
    });

    test('الاختبار تحت 60% لا يُنجز الجزء، وفوقه يُنجزه', () async {
      Future<void> run(List<bool> oks) => repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.quiz,
        results: results(oks),
        content: content,
      );
      Future<Set<LessonPart>> done() async => {
        for (final p in await db.activityDao.getLessonParts(profileId)) p.part,
      };

      await run([true, false, false, false, false]);
      expect(await done(), isNot(contains(LessonPart.quiz)));
      await run([true, true, true, false, false]);
      expect(await done(), contains(LessonPart.quiz));
    });

    test('محاولة طالب آخر لا تُفتح', () async {
      final record = await repo.recordRound(
        profileId: profileId,
        lessonId: 'math.u3.l3',
        mode: RoundMode.practice,
        results: results([true]),
        content: content,
      );
      expect(await repo.loadAttempt('غريب', record.attemptId), isNull);
    });
  });
}
