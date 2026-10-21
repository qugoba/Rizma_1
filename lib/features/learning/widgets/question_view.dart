import 'package:flutter/widgets.dart';

import '../../content/question.dart';
import 'choice_views.dart';
import 'interactive_views.dart';
import 'question_context.dart';

class QuestionView extends StatelessWidget {
  const QuestionView({super.key, required this.data});

  final QuestionContext data;

  @override
  Widget build(BuildContext context) {
    return switch (data.question) {
      ChoiceQuestion() => ChoiceView(context_: data),
      TrueFalseQuestion() => TrueFalseView(context_: data),
      DragDropQuestion() => DragDropView(context_: data),
      MatchPairsQuestion() => MatchPairsView(context_: data),
      OrderQuestion() => OrderView(context_: data),
      ListenChooseQuestion() => ListenChooseView(context_: data),
    };
  }
}
