library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

enum QuestionKind {
  choice,
  trueFalse,
  dragDrop,
  matchPairs,
  order,
  listenChoose,
}

class QuestionVisual {
  const QuestionVisual.bars({required this.parts, required this.filled})
    : kind = 'bars',
      illustration = null,
      count = 0;

  const QuestionVisual.items({required this.illustration, required this.count})
    : kind = 'items',
      parts = 0,
      filled = 0;

  factory QuestionVisual.fromJson(Map<String, dynamic> json) {
    return switch (json['kind']) {
      'bars' => QuestionVisual.bars(
        parts: json['parts'] as int,
        filled: json['filled'] as int,
      ),
      'items' => QuestionVisual.items(
        illustration: json['illustration'] as String,
        count: json['count'] as int,
      ),
      final other => throw FormatException('نوع مرئي غير معروف: $other'),
    };
  }

  final String kind;
  final int parts;
  final int filled;
  final String? illustration;
  final int count;
}

sealed class Question {
  const Question({
    required this.id,
    required this.concept,
    required this.prompt,
    this.visual,
    this.hints = const [],
    this.solution = const [],
    this.explanation,
    this.fingerprint = '',
  });

  static String fingerprintOf(Map<String, dynamic> json) =>
      sha256.convert(utf8.encode(jsonEncode(json))).toString().substring(0, 16);

  factory Question.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final base = (
      id: json['id'] as String,
      concept: json['concept'] as String,
      prompt: (json['prompt'] as String?) ?? '',
      visual: json['visual'] == null
          ? null
          : QuestionVisual.fromJson(json['visual'] as Map<String, dynamic>),
      hints: [for (final h in (json['hints'] as List<dynamic>? ?? [])) '$h'],
      solution: [
        for (final s in (json['solution'] as List<dynamic>? ?? [])) '$s',
      ],
      explanation: json['explanation'] as String?,
      fingerprint: fingerprintOf(json),
    );
    return switch (type) {
      'choice' => ChoiceQuestion._(
        base,
        choices: [for (final c in json['choices'] as List<dynamic>) '$c'],
        answerIndex: json['answer'] as int,
      ),
      'trueFalse' => TrueFalseQuestion._(
        base,
        statement: json['statement'] as String,
        answer: json['answer'] as bool,
      ),
      'dragDrop' => DragDropQuestion._(
        base,
        template: json['template'] as String,
        cards: [for (final c in json['cards'] as List<dynamic>) '$c'],
        answer: json['answer'] as String,
      ),
      'matchPairs' => MatchPairsQuestion._(
        base,
        pairs: [
          for (final p in json['pairs'] as List<dynamic>)
            MatchPair.fromJson(p as Map<String, dynamic>),
        ],
      ),
      'order' => OrderQuestion._(
        base,
        items: [
          for (final i in json['items'] as List<dynamic>)
            OrderItem.fromJson(i as Map<String, dynamic>),
        ],
        startLabel: (json['startLabel'] as String?) ?? '',
        endLabel: (json['endLabel'] as String?) ?? '',
      ),
      'listenChoose' => ListenChooseQuestion._(
        base,
        word: json['word'] as String,
        choices: [for (final c in json['choices'] as List<dynamic>) '$c'],
        answerIndex: json['answer'] as int,
      ),
      _ => throw FormatException('نوع سؤال غير معروف: $type'),
    };
  }

  final String id;

  final String concept;
  final String prompt;
  final QuestionVisual? visual;

  final List<String> hints;

  final List<String> solution;

  final String? explanation;

  final String fingerprint;

  QuestionKind get kind;

  bool check(Object? answer);
}

typedef _Base = ({
  String id,
  String concept,
  String prompt,
  QuestionVisual? visual,
  List<String> hints,
  List<String> solution,
  String? explanation,
  String fingerprint,
});

final class ChoiceQuestion extends Question {
  ChoiceQuestion._(_Base b, {required this.choices, required this.answerIndex})
    : super(
        id: b.id,
        concept: b.concept,
        prompt: b.prompt,
        visual: b.visual,
        hints: b.hints,
        solution: b.solution,
        explanation: b.explanation,
        fingerprint: b.fingerprint,
      );

  final List<String> choices;
  final int answerIndex;

  @override
  QuestionKind get kind => QuestionKind.choice;

  @override
  bool check(Object? answer) => answer == answerIndex;
}

final class TrueFalseQuestion extends Question {
  TrueFalseQuestion._(_Base b, {required this.statement, required this.answer})
    : super(
        id: b.id,
        concept: b.concept,
        prompt: b.prompt,
        visual: b.visual,
        hints: b.hints,
        solution: b.solution,
        explanation: b.explanation,
        fingerprint: b.fingerprint,
      );

  final String statement;
  final bool answer;

  @override
  QuestionKind get kind => QuestionKind.trueFalse;

  @override
  bool check(Object? a) => a == answer;
}

final class DragDropQuestion extends Question {
  DragDropQuestion._(
    _Base b, {
    required this.template,
    required this.cards,
    required this.answer,
  }) : super(
         id: b.id,
         concept: b.concept,
         prompt: b.prompt,
         visual: b.visual,
         hints: b.hints,
         solution: b.solution,
         explanation: b.explanation,
         fingerprint: b.fingerprint,
       );

  final String template;
  final List<String> cards;
  final String answer;

  @override
  QuestionKind get kind => QuestionKind.dragDrop;

  @override
  bool check(Object? a) => a == answer;
}

class PairSide {
  const PairSide({this.text, this.visual});

  factory PairSide.fromJson(Map<String, dynamic> json) => PairSide(
    text: json['text'] as String?,
    visual: json['visual'] == null
        ? null
        : QuestionVisual.fromJson(json['visual'] as Map<String, dynamic>),
  );

  final String? text;
  final QuestionVisual? visual;
}

class MatchPair {
  const MatchPair({required this.left, required this.right});

  factory MatchPair.fromJson(Map<String, dynamic> json) => MatchPair(
    left: PairSide.fromJson(json['left'] as Map<String, dynamic>),
    right: PairSide.fromJson(json['right'] as Map<String, dynamic>),
  );

  final PairSide left;
  final PairSide right;
}

final class MatchPairsQuestion extends Question {
  MatchPairsQuestion._(_Base b, {required this.pairs})
    : super(
        id: b.id,
        concept: b.concept,
        prompt: b.prompt,
        visual: b.visual,
        hints: b.hints,
        solution: b.solution,
        explanation: b.explanation,
        fingerprint: b.fingerprint,
      );

  final List<MatchPair> pairs;

  @override
  QuestionKind get kind => QuestionKind.matchPairs;

  @override
  bool check(Object? a) {
    if (a is! Map<int, int> || a.length != pairs.length) return false;
    return a.entries.every((e) => e.key == e.value);
  }
}

class OrderItem {
  const OrderItem({required this.label, this.visual});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    label: json['label'] as String,
    visual: json['visual'] == null
        ? null
        : QuestionVisual.fromJson(json['visual'] as Map<String, dynamic>),
  );

  final String label;
  final QuestionVisual? visual;
}

final class OrderQuestion extends Question {
  OrderQuestion._(
    _Base b, {
    required this.items,
    required this.startLabel,
    required this.endLabel,
  }) : super(
         id: b.id,
         concept: b.concept,
         prompt: b.prompt,
         visual: b.visual,
         hints: b.hints,
         solution: b.solution,
         explanation: b.explanation,
         fingerprint: b.fingerprint,
       );

  final List<OrderItem> items;
  final String startLabel;
  final String endLabel;

  @override
  QuestionKind get kind => QuestionKind.order;

  @override
  bool check(Object? a) {
    if (a is! List<int> || a.length != items.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != i) return false;
    }
    return true;
  }
}

final class ListenChooseQuestion extends Question {
  ListenChooseQuestion._(
    _Base b, {
    required this.word,
    required this.choices,
    required this.answerIndex,
  }) : super(
         id: b.id,
         concept: b.concept,
         prompt: b.prompt,
         visual: b.visual,
         hints: b.hints,
         solution: b.solution,
         explanation: b.explanation,
         fingerprint: b.fingerprint,
       );

  final String word;
  final List<String> choices;
  final int answerIndex;

  @override
  QuestionKind get kind => QuestionKind.listenChoose;

  @override
  bool check(Object? a) => a == answerIndex;
}
