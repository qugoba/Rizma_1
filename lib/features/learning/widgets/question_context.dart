import '../../content/question.dart';
import '../round_engine.dart';

class QuestionContext {
  const QuestionContext({
    required this.question,
    required this.layout,
    required this.mode,
    required this.phase,
    required this.lastAnswer,
    required this.number,
    required this.total,
    required this.onAnswer,
    required this.onSpeak,
  });

  final Question question;
  final QuestionLayout layout;
  final RoundMode mode;
  final RoundPhase phase;

  final Object? lastAnswer;
  final int number;
  final int total;

  final void Function(Object? answer) onAnswer;
  final void Function(String text, {bool slow}) onSpeak;

  bool get locked => phase != RoundPhase.answering;
  bool get revealed => phase == RoundPhase.revealed;
  bool get practice => mode == RoundMode.practice;
}
