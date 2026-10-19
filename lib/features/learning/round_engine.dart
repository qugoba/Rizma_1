import 'dart:math';

import '../content/question.dart';

enum RoundMode {
  practice,

  quiz,
}

enum RoundPhase {
  answering,

  correct,

  revealed,
}

class QuestionLayout {
  const QuestionLayout({this.order = const [], this.cards = const []});

  final List<int> order;

  final List<String> cards;
}

class QuestionResult {
  const QuestionResult({
    required this.questionId,
    required this.concept,
    required this.kind,
    required this.correct,
    required this.wrongs,
    required this.hints,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
    questionId: json['id'] as String,
    concept: json['concept'] as String,
    kind: QuestionKind.values.byName(json['kind'] as String),
    correct: json['correct'] as bool,
    wrongs: json['wrongs'] as int,
    hints: json['hints'] as int,
  );

  final String questionId;
  final String concept;
  final QuestionKind kind;
  final bool correct;

  final int wrongs;

  final int hints;

  bool get firstTry => correct && wrongs == 0;

  double get value => !correct ? 0 : (wrongs == 0 ? 1 : 0.5);

  int get stars => !correct ? 0 : starsFor(wrongs);

  static int starsFor(int wrongs) => switch (wrongs) {
    0 => 3,
    1 => 2,
    _ => 1,
  };

  Map<String, dynamic> toJson() => {
    'id': questionId,
    'concept': concept,
    'kind': kind.name,
    'correct': correct,
    'wrongs': wrongs,
    'hints': hints,
  };
}

class RoundState {
  const RoundState({
    required this.mode,
    required this.questions,
    required this.layouts,
    this.results = const [],
    this.index = 0,
    this.wrongs = 0,
    this.phase = RoundPhase.answering,
    this.lastAnswer,
  });

  final RoundMode mode;
  final List<Question> questions;
  final List<QuestionLayout> layouts;

  final List<QuestionResult> results;
  final int index;

  final int wrongs;
  final RoundPhase phase;

  final Object? lastAnswer;

  bool get finished => index >= questions.length;
  Question? get current => finished ? null : questions[index];
  QuestionLayout? get layout => finished ? null : layouts[index];

  int get hintsShown {
    final q = current;
    if (q == null || mode == RoundMode.quiz) return 0;
    return min(wrongs, q.hints.length);
  }

  bool get solutionShown =>
      phase == RoundPhase.revealed && (current?.solution.isNotEmpty ?? false);

  bool get canRevealSolution =>
      mode == RoundMode.practice &&
      phase == RoundPhase.answering &&
      (current?.solution.isNotEmpty ?? false) &&
      wrongs > 0;

  RoundState copyWith({
    List<QuestionResult>? results,
    int? index,
    int? wrongs,
    RoundPhase? phase,
    Object? lastAnswer,
    bool clearAnswer = false,
  }) {
    return RoundState(
      mode: mode,
      questions: questions,
      layouts: layouts,
      results: results ?? this.results,
      index: index ?? this.index,
      wrongs: wrongs ?? this.wrongs,
      phase: phase ?? this.phase,
      lastAnswer: clearAnswer ? null : (lastAnswer ?? this.lastAnswer),
    );
  }
}

abstract final class RoundEngine {
  static const practiceLength = 8;

  static const kidsPracticeLength = 5;

  static const lastKidsGrade = 4;

  static const quizLength = 10;

  static const _starThresholds = [0.3, 0.6, 0.9];

  static List<Question> pick(
    List<Question> pool,
    RoundMode mode, {
    required Random random,
    String? concept,
    bool kids = false,
  }) {
    if (mode == RoundMode.quiz) return pool.take(quizLength).toList();
    var source = pool;
    if (concept != null) {
      final only = pool.where((q) => q.concept == concept).toList();
      if (only.isNotEmpty) source = only;
    }
    if (kids) {
      final noOrder = source.where((q) => q is! OrderQuestion).toList();
      if (noOrder.isNotEmpty) source = noOrder;
    }
    final copy = [...source]..shuffle(random);
    return copy.take(kids ? kidsPracticeLength : practiceLength).toList();
  }

  static RoundState start({
    required RoundMode mode,
    required List<Question> questions,
    required Random random,
  }) {
    return RoundState(
      mode: mode,
      questions: questions,
      layouts: [for (final q in questions) _layoutFor(q, random)],
    );
  }

  static bool keepsOrder(List<String> choices) => choices.any(
    (c) =>
        c.contains('كل ما سبق') ||
        c.contains('جميع') ||
        c.contains('كلاهما') ||
        c.contains('لا شيء مما'),
  );

  static QuestionLayout _layoutFor(Question q, Random random) {
    List<int> shuffled(int n, {bool avoidIdentity = false}) {
      final base = List.generate(n, (i) => i);
      if (n < 2) return base;
      final list = [...base];
      var tries = 0;
      do {
        list.shuffle(random);
        tries++;
      } while (avoidIdentity && _isIdentity(list) && tries < 10);
      return list;
    }

    return switch (q) {
      ChoiceQuestion(:final choices) => QuestionLayout(
        order: keepsOrder(choices)
            ? List.generate(choices.length, (i) => i)
            : shuffled(choices.length),
      ),
      ListenChooseQuestion(:final choices) => QuestionLayout(
        order: shuffled(choices.length),
      ),
      MatchPairsQuestion(:final pairs) => QuestionLayout(
        order: shuffled(pairs.length, avoidIdentity: true),
      ),
      OrderQuestion(:final items) => QuestionLayout(
        order: shuffled(items.length, avoidIdentity: true),
      ),
      DragDropQuestion(:final cards) => QuestionLayout(
        cards: [...cards]..shuffle(random),
      ),
      TrueFalseQuestion() => const QuestionLayout(),
    };
  }

  static bool _isIdentity(List<int> l) {
    for (var i = 0; i < l.length; i++) {
      if (l[i] != i) return false;
    }
    return true;
  }

  static RoundState submit(RoundState s, Object? answer) {
    final q = s.current;
    if (q == null || s.phase != RoundPhase.answering) return s;
    final ok = q.check(answer);

    if (s.mode == RoundMode.quiz) {
      return s.copyWith(
        results: [
          ...s.results,
          _result(q, correct: ok, wrongs: ok ? 0 : 1, hints: 0),
        ],
        index: s.index + 1,
        wrongs: 0,
        clearAnswer: true,
      );
    }

    if (ok) {
      return s.copyWith(phase: RoundPhase.correct, lastAnswer: answer);
    }
    final wrongs = s.wrongs + 1;
    return s.copyWith(
      wrongs: wrongs,
      lastAnswer: answer,
      phase: wrongs > q.hints.length
          ? RoundPhase.revealed
          : RoundPhase.answering,
    );
  }

  static RoundState revealSolution(RoundState s) {
    if (!s.canRevealSolution) return s;
    return s.copyWith(phase: RoundPhase.revealed);
  }

  static RoundState advance(RoundState s) {
    final q = s.current;
    if (q == null || s.phase == RoundPhase.answering) return s;
    final correct = s.phase == RoundPhase.correct;
    final hints = min(s.wrongs, q.hints.length) + (s.solutionShown ? 1 : 0);
    return s.copyWith(
      results: [
        ...s.results,
        _result(q, correct: correct, wrongs: s.wrongs, hints: hints),
      ],
      index: s.index + 1,
      wrongs: 0,
      phase: RoundPhase.answering,
      clearAnswer: true,
    );
  }

  static QuestionResult _result(
    Question q, {
    required bool correct,
    required int wrongs,
    required int hints,
  }) => QuestionResult(
    questionId: q.id,
    concept: q.concept,
    kind: q.kind,
    correct: correct,
    wrongs: wrongs,
    hints: hints,
  );

  static double nextMastery(double? old, double value) =>
      old == null ? value : (old * 0.6 + value * 0.4).clamp(0.0, 1.0);

  static int ratingStars(List<QuestionResult> results) {
    if (results.isEmpty) return 0;
    final ratio =
        results.fold<double>(0, (a, r) => a + r.value) / results.length;
    var stars = 0;
    for (final t in _starThresholds) {
      if (ratio >= t) stars++;
    }
    return stars;
  }

  static int percent(List<QuestionResult> results) {
    if (results.isEmpty) return 0;
    return (results.where((r) => r.correct).length * 100 / results.length)
        .round();
  }

  static int starsEarned(List<QuestionResult> results) =>
      results.fold(0, (a, r) => a + r.stars);
}
