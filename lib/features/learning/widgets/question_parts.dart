import 'package:flutter/material.dart';

import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/rizma_look.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/fraction_bar.dart';
import '../../../core/widgets/illustration.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/math_text.dart';
import '../../content/question.dart';

class QuestionVisualView extends StatelessWidget {
  const QuestionVisualView(
    this.visual, {
    super.key,
    this.height = 28,
    this.color = AppColors.teal,
    this.outlined = false,
  });

  final QuestionVisual visual;
  final double height;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (visual.kind == 'bars') {
      return FractionBar(
        parts: visual.parts,
        filled: visual.filled,
        height: height,
        color: color,
        outlined: outlined,
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < visual.count; i++)
          Illustration(visual.illustration ?? '', size: 40),
      ],
    );
  }
}

class QuestionHeaderCard extends StatelessWidget {
  const QuestionHeaderCard({
    super.key,
    required this.kindLabel,
    required this.kindColor,
    required this.kindTint,
    required this.child,
  });

  final String kindLabel;
  final Color kindColor;
  final Color kindTint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: kindTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                child: Text(
                  kindLabel,
                  style: AppTextStyles.chip13.copyWith(color: kindColor),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class PromptText extends StatelessWidget {
  const PromptText(this.text, {super.key, this.size = 20});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return MathText(
      text,
      style: AppTextStyles.section18.copyWith(fontSize: size, height: 1.7),
    );
  }
}

enum CardMark { idle, selected, correct, wrong }

class PressCard extends StatelessWidget {
  const PressCard({
    super.key,
    required this.child,
    required this.onTap,
    this.mark = CardMark.idle,
    this.accent = AppColors.teal,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    this.semanticsLabel,
    this.minHeight = 64,
  });

  final Widget child;
  final VoidCallback? onTap;
  final CardMark mark;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final look = RizmaLook.of(context);
    final (bg, border, edge) = switch (mark) {
      CardMark.idle => (
        AppColors.card,
        look.calm ? AppColors.line : Colors.transparent,
        look.cardLedge,
      ),
      CardMark.selected => (
        Color.lerp(accent, AppColors.card, .82)!,
        accent,
        Color.lerp(accent, AppColors.ink, .3)!,
      ),
      CardMark.correct => (
        AppColors.tealTint,
        AppColors.teal,
        AppColors.tealDark,
      ),
      CardMark.wrong => (
        AppColors.coralTint,
        AppColors.coral,
        AppColors.coralDark,
      ),
    };

    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: mark == CardMark.selected,
      label: semanticsLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
            width: mark == CardMark.idle ? 1.5 : 2,
          ),
          boxShadow: [
            BoxShadow(color: edge, offset: Offset(0, look.ledgeDepth)),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap == null
                ? null
                : () {
                    Haptics.tap();
                    onTap!();
                  },
            child: Padding(
              padding: padding,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

Color markTextColor(CardMark mark) => switch (mark) {
  CardMark.selected => AppColors.tealDark,
  CardMark.wrong => AppColors.coral,
  CardMark.correct => AppColors.tealDark,
  CardMark.idle => AppColors.ink,
};

({String label, Color fg, Color tint}) kindChip(QuestionKind kind) =>
    switch (kind) {
      QuestionKind.choice => (
        label: ArLearn.kindChoice,
        fg: AppColors.teal,
        tint: AppColors.tealTint,
      ),
      QuestionKind.trueFalse => (
        label: ArLearn.kindTrueFalse,
        fg: AppColors.purple,
        tint: AppColors.purpleTint,
      ),
      QuestionKind.dragDrop => (
        label: ArLearn.kindDragDrop,
        fg: AppColors.blue,
        tint: AppColors.blueTint,
      ),
      QuestionKind.matchPairs => (
        label: ArLearn.kindMatch,
        fg: AppColors.amberDark,
        tint: AppColors.amberTint,
      ),
      QuestionKind.order => (
        label: ArLearn.kindOrder,
        fg: AppColors.coral,
        tint: AppColors.coralTint,
      ),
      QuestionKind.listenChoose => (
        label: ArLearn.kindListen,
        fg: AppColors.teal,
        tint: AppColors.tealTint,
      ),
    };
