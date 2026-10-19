import 'package:flutter/material.dart';

import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/mascot.dart';
import '../../../core/widgets/math_text.dart';
import '../../../core/widgets/rizma_button.dart';
import '../../content/question.dart';

class _Panel extends StatelessWidget {
  const _Panel({
    required this.bg,
    required this.border,
    required this.children,
  });

  final Color bg;
  final Color border;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      color: bg,
      edge: border,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: children,
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, this.titleColor});

  final String title;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        const Mascot(size: 44),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.section18.copyWith(color: titleColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SolutionSteps extends StatelessWidget {
  const _SolutionSteps({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(ArLearn.solutionTitle, style: AppTextStyles.captionBold13),
            for (final (i, s) in steps.indexed)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text('${i + 1}.', style: AppTextStyles.body15),
                  Expanded(
                    child: MathText(
                      s,
                      style: AppTextStyles.body15.copyWith(height: 1.6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class CorrectPanel extends StatelessWidget {
  const CorrectPanel({
    super.key,
    required this.stars,
    required this.question,
    required this.nextLabel,
    required this.onNext,
  });

  final int stars;
  final Question question;
  final String nextLabel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      bg: AppColors.tealTint,
      border: AppColors.teal,
      children: [
        _PanelHeader(
          title: ArLearn.correctTitle(stars),
          titleColor: AppColors.tealDark,
        ),
        if (question.explanation != null)
          MathText(
            question.explanation!,
            style: AppTextStyles.body15.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        RizmaButton(label: nextLabel, icon: 'fwd', onPressed: onNext),
      ],
    );
  }
}

class RevealedPanel extends StatelessWidget {
  const RevealedPanel({
    super.key,
    required this.question,
    required this.nextLabel,
    required this.onNext,
  });

  final Question question;
  final String nextLabel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      bg: AppColors.amberTint,
      border: AppColors.amberLine,
      children: [
        const _PanelHeader(
          title: ArLearn.revealedTitle,
          titleColor: AppColors.amberDark,
        ),
        if (question.solution.isNotEmpty)
          _SolutionSteps(steps: question.solution),
        if (question.explanation != null)
          MathText(
            question.explanation!,
            style: AppTextStyles.body15.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        RizmaButton(label: nextLabel, icon: 'fwd', onPressed: onNext),
      ],
    );
  }
}

class HintPanel extends StatelessWidget {
  const HintPanel({
    super.key,
    required this.stage,
    required this.stages,
    required this.hint,
    this.onTryAgain,
    this.onLastHint,
  });

  final int stage;
  final int stages;
  final String hint;

  final VoidCallback? onTryAgain;

  final VoidCallback? onLastHint;

  @override
  Widget build(BuildContext context) {
    final tryAgain = onTryAgain == null
        ? null
        : RizmaButton(
            label: ArLearn.tryAgain,
            kind: ButtonKind.neutral,
            icon: 'retry',
            onPressed: onTryAgain,
          );
    final lastHint = onLastHint == null
        ? null
        : RizmaButton(
            label: ArLearn.lastHint,
            kind: ButtonKind.amber,
            icon: 'bulb',
            onPressed: onLastHint,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            const Mascot(size: 48),
            Expanded(
              child: LedgeBox(
                radius: 18,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.amberTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            const AppIcon(
                              'bulb',
                              size: 14,
                              color: AppColors.amberInk,
                            ),
                            Flexible(
                              child: Text(
                                ArLearn.hintStage(stage, stages),
                                style: AppTextStyles.caption12.copyWith(
                                  color: AppColors.amberInk,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    MathText(
                      hint,
                      style: AppTextStyles.body15.copyWith(height: 1.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (tryAgain != null && lastHint != null)
          Row(
            spacing: 10,
            children: [
              Expanded(child: tryAgain),
              Expanded(child: lastHint),
            ],
          )
        else
          ?tryAgain ?? lastHint,
      ],
    );
  }
}

class StarsChip extends StatelessWidget {
  const StarsChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count ${ArLearn.roundStars}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.amber,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Text(
                '$count',
                style: AppTextStyles.chip13.copyWith(color: AppColors.amberInk),
              ),
              const AppIcon('starf', size: 16, color: AppColors.amberInk),
            ],
          ),
        ),
      ),
    );
  }
}
