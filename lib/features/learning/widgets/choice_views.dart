import 'package:flutter/material.dart';

import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/illustration.dart';
import '../../../core/widgets/math_text.dart';
import '../../content/question.dart';
import '../round_engine.dart';
import 'question_context.dart';
import 'question_parts.dart';

Color accentOf(QuestionContext c) =>
    c.practice ? AppColors.teal : AppColors.blue;

CardMark choiceMark(
  QuestionContext c, {
  required int original,
  required int correctIndex,
  required int? selected,
}) {
  final last = c.lastAnswer;
  switch (c.phase) {
    case RoundPhase.correct:
      return original == last ? CardMark.correct : CardMark.idle;
    case RoundPhase.revealed:
      if (original == correctIndex) return CardMark.correct;
      return original == last ? CardMark.wrong : CardMark.idle;
    case RoundPhase.answering:
      if (selected == original) return CardMark.selected;
      return original == last ? CardMark.wrong : CardMark.idle;
  }
}

class ChoiceView extends StatefulWidget {
  const ChoiceView({super.key, required this.context_});

  final QuestionContext context_;

  @override
  State<ChoiceView> createState() => _ChoiceViewState();
}

class _ChoiceViewState extends State<ChoiceView> {
  int? _selected;

  void _pick(int original) {
    setState(() => _selected = original);
    widget.context_.onAnswer(original);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context_;
    final q = c.question as ChoiceQuestion;
    final chip = kindChip(q.kind);
    final longest = q.choices.fold<int>(
      0,
      (m, s) => s.length > m ? s.length : m,
    );
    final columns = longest > 14 ? 1 : 2;
    final order = c.layout.order;

    Widget card(int position) {
      final original = order[position];
      final mark = choiceMark(
        c,
        original: original,
        correctIndex: q.answerIndex,
        selected: _selected,
      );
      return PressCard(
        mark: mark,
        accent: accentOf(c),
        onTap: c.locked ? null : () => _pick(original),
        semanticsLabel: q.choices[original],
        child: Row(
          spacing: 8,
          children: [
            _LetterBubble(position: position, mark: mark),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: MathText(
                  q.choices[original],
                  textAlign: TextAlign.center,
                  color: markTextColor(mark),
                  blankColor: markTextColor(mark),
                  style: AppTextStyles.section18.copyWith(
                    fontSize: 24,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        QuestionHeaderCard(
          kindLabel: chip.label,
          kindColor: chip.fg,
          kindTint: chip.tint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              PromptText(q.prompt),
              if (q.visual != null) QuestionVisualView(q.visual!),
            ],
          ),
        ),
        for (var i = 0; i < order.length; i += columns)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                for (var j = i; j < i + columns; j++)
                  Expanded(
                    child: j < order.length ? card(j) : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class TrueFalseView extends StatefulWidget {
  const TrueFalseView({super.key, required this.context_});

  final QuestionContext context_;

  @override
  State<TrueFalseView> createState() => _TrueFalseViewState();
}

class _TrueFalseViewState extends State<TrueFalseView> {
  bool? _selected;

  void _pick(bool value) {
    setState(() => _selected = value);
    widget.context_.onAnswer(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context_;
    final q = c.question as TrueFalseQuestion;
    final chip = kindChip(q.kind);

    CardMark markOf(bool value) {
      final last = c.lastAnswer;
      switch (c.phase) {
        case RoundPhase.correct:
          return value == last ? CardMark.correct : CardMark.idle;
        case RoundPhase.revealed:
          if (value == q.answer) return CardMark.correct;
          return value == last ? CardMark.wrong : CardMark.idle;
        case RoundPhase.answering:
          if (_selected == value) return CardMark.selected;
          return last == value ? CardMark.wrong : CardMark.idle;
      }
    }

    Widget option(bool value) {
      final mark = markOf(value);
      final isTrue = value;
      final color = isTrue ? AppColors.teal : AppColors.coral;
      final tint = isTrue ? AppColors.tealTint : AppColors.coralTint;
      final selected = mark == CardMark.selected;
      return PressCard(
        mark: mark,
        accent: accentOf(c),
        minHeight: 120,
        semanticsLabel: isTrue ? ArLearn.answerTrue : ArLearn.answerFalse,
        onTap: c.locked ? null : () => _pick(value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.card
                    : (mark == CardMark.idle ? tint : color),
              ),
              child: Center(
                child: AppIcon(
                  isTrue ? 'check' : 'x',
                  size: 28,
                  color: mark == CardMark.idle || selected
                      ? color
                      : AppColors.card,
                ),
              ),
            ),
            Text(
              isTrue ? ArLearn.answerTrue : ArLearn.answerFalse,
              style: AppTextStyles.heading22.copyWith(
                color: markTextColor(mark),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        QuestionHeaderCard(
          kindLabel: chip.label,
          kindColor: chip.fg,
          kindTint: chip.tint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Text(q.prompt, style: AppTextStyles.label14),
              Center(
                child: MathText(
                  q.statement,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title26.copyWith(
                    fontSize: 30,
                    height: 1.6,
                  ),
                ),
              ),
              if (q.visual != null) QuestionVisualView(q.visual!),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Expanded(child: option(true)),
              Expanded(child: option(false)),
            ],
          ),
        ),
      ],
    );
  }
}

class ListenChooseView extends StatefulWidget {
  const ListenChooseView({super.key, required this.context_});

  final QuestionContext context_;

  @override
  State<ListenChooseView> createState() => _ListenChooseViewState();
}

class _ListenChooseViewState extends State<ListenChooseView> {
  int? _selected;

  void _pick(int original) {
    setState(() => _selected = original);
    widget.context_.onAnswer(original);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.context_;
    final q = c.question as ListenChooseQuestion;
    final chip = kindChip(q.kind);
    final order = c.layout.order;

    Widget pill(String label, String icon, VoidCallback onTap) => Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Text(
                  label,
                  style: AppTextStyles.chip13.copyWith(color: AppColors.teal),
                ),
                AppIcon(icon, size: 16, color: AppColors.teal),
              ],
            ),
          ),
        ),
      ),
    );

    Widget card(int position) {
      final original = order[position];
      final mark = choiceMark(
        c,
        original: original,
        correctIndex: q.answerIndex,
        selected: _selected,
      );
      final shown = mark == CardMark.selected ? CardMark.correct : mark;
      return PressCard(
        mark: shown,
        minHeight: 112,
        semanticsLabel: q.choices[original],
        onTap: c.locked ? null : () => _pick(original),
        child: Illustration(q.choices[original], size: 64),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        QuestionHeaderCard(
          kindLabel: chip.label,
          kindColor: chip.fg,
          kindTint: chip.tint,
          child: Column(
            spacing: 12,
            children: [
              Semantics(
                button: true,
                label: ArLearn.partWords,
                excludeSemantics: true,
                child: Material(
                  color: AppColors.teal,
                  shape: const CircleBorder(),
                  elevation: 3,
                  shadowColor: AppColors.teal,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => c.onSpeak(q.word),
                    child: const SizedBox(
                      width: 96,
                      height: 96,
                      child: Center(
                        child: AppIcon(
                          'volume',
                          size: 44,
                          color: AppColors.card,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                q.prompt,
                textAlign: TextAlign.center,
                style: AppTextStyles.label14,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  pill(ArLearn.listenAgain, 'retry', () => c.onSpeak(q.word)),
                  pill(
                    ArLearn.listenSlow,
                    'volume',
                    () => c.onSpeak(q.word, slow: true),
                  ),
                ],
              ),
            ],
          ),
        ),
        for (var i = 0; i < order.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                for (var j = i; j < i + 2; j++)
                  Expanded(
                    child: j < order.length ? card(j) : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LetterBubble extends StatelessWidget {
  const _LetterBubble({required this.position, required this.mark});

  static const _letters = ['أ', 'ب', 'ج', 'د', 'هـ', 'و'];

  final int position;
  final CardMark mark;

  @override
  Widget build(BuildContext context) {
    final (bg, child) = switch (mark) {
      CardMark.selected || CardMark.correct => (
        AppColors.teal,
        const AppIcon('check', size: 16, color: AppColors.card) as Widget,
      ),
      CardMark.wrong => (
        AppColors.coral,
        const AppIcon('x', size: 16, color: AppColors.card) as Widget,
      ),
      CardMark.idle => (
        AppColors.sky,
        Text(
              _letters[position % _letters.length],
              style: AppTextStyles.chip13.copyWith(color: AppColors.tealDark),
            )
            as Widget,
      ),
    };
    return ExcludeSemantics(
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
