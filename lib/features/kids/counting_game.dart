import 'dart:math';

import '../../core/strings/ar_kids.dart';
import '../content/question.dart';
import '../learning/round_engine.dart';

class Fruit {
  const Fruit(this.key, this.singular, this.dual, this.plural);

  final String key;
  final String singular;
  final String dual;
  final String plural;

  String phrase(int count) => switch (count) {
    1 => '$singular واحدة',
    2 => dual,
    _ => '$count $plural',
  };
}

const fruits = [
  Fruit('apple', 'تفاحة', 'تفاحتان', 'تفاحات'),
  Fruit('orange', 'برتقالة', 'برتقالتان', 'برتقالات'),
  Fruit('banana', 'موزة', 'موزتان', 'موزات'),
  Fruit('lemon', 'ليمونة', 'ليمونتان', 'ليمونات'),
  Fruit('strawberry', 'فراولة', 'فراولتان', 'فراولات'),
];

abstract final class CountingGame {
  static const length = 5;
  static const maxCount = 9;
  static const activityId = 'kids.counting';
  static const concept = 'kids.counting';

  static const starsCap = 60;

  static Fruit fruitOf(Question q) =>
      fruits.firstWhere((f) => f.key == q.visual?.illustration);

  static int countOf(Question q) => q.visual!.count;

  static List<Question> generate(Random random, {int n = length}) {
    final questions = <Question>[];
    var previous = 0;
    for (var i = 0; i < n; i++) {
      final fruit = fruits[random.nextInt(fruits.length)];
      int count;
      do {
        count = 1 + random.nextInt(maxCount);
      } while (count == previous);
      previous = count;

      final options = <int>{count};
      while (options.length < 3) {
        final candidate = count + random.nextInt(7) - 3;
        if (candidate >= 1 && candidate <= maxCount) options.add(candidate);
      }
      final sorted = options.toList()..sort();

      questions.add(
        Question.fromJson({
          'id': '$activityId.$i',
          'type': 'choice',
          'concept': concept,
          'prompt': ArKids.howMany(fruit.singular),
          'choices': [for (final o in sorted) '$o'],
          'answer': sorted.indexOf(count),
          'visual': {
            'kind': 'items',
            'illustration': fruit.key,
            'count': count,
          },
          'hints': [ArKids.gameHint],
          'explanation': fruit.phrase(count),
        }),
      );
    }
    return questions;
  }

  static RoundState start(Random random) {
    final questions = generate(random);
    return RoundState(
      mode: RoundMode.practice,
      questions: questions,
      layouts: [
        for (final q in questions)
          QuestionLayout(
            order: List.generate(
              (q as ChoiceQuestion).choices.length,
              (i) => i,
            ),
          ),
      ],
    );
  }
}
