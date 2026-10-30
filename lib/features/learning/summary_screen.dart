import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/enums.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/ledge.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/math_text.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';
import '../content/lesson_content.dart';
import 'lesson_view.dart';
import 'widgets/part_frame.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _marked = false;
  int _card = 0;

  void _markOnce() {
    if (_marked) return;
    _marked = true;
    completeLessonPart(
      ref,
      lessonId: widget.lessonId,
      part: LessonPart.summary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(lessonViewProvider(widget.lessonId)).value;
    final points = view?.content?.summary ?? const <SummaryPoint>[];

    if (view == null || points.isEmpty) {
      return PartFrame(
        title: ArLearn.summaryTitle,
        subtitle: view?.lesson.title ?? '',
        lessonId: widget.lessonId,
        child: const PartUnavailable(),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markOnce();
    });

    final content = view.content!;
    final card = _card.clamp(0, points.length - 1);
    return PartFrame(
      title: ArLearn.summaryTitle,
      subtitle: view.lesson.title,
      lessonId: widget.lessonId,
      bottom: Row(
        spacing: 12,
        children: [
          if (content.has(LessonPart.video))
            Expanded(
              child: RizmaButton(
                label: ArLearn.summaryVideo,
                kind: ButtonKind.outlined,
                icon: 'video',
                onPressed: () => context.pushReplacement(
                  AppRoutes.lessonPart(widget.lessonId, LessonPart.video.name),
                ),
              ),
            ),
          if (content.has(LessonPart.practice))
            Expanded(
              child: RizmaButton(
                label: ArLearn.summaryPracticeNow,
                icon: 'fwd',
                onPressed: () =>
                    context.pushReplacement(AppRoutes.round(widget.lessonId)),
              ),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ArLearn.summaryCardOf(card + 1, points.length),
                  style: AppTextStyles.body15,
                ),
              ),
              Text(
                '${((card + 1) * 100 / points.length).round()}%',
                style: AppTextStyles.caption12.copyWith(
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              for (var i = 0; i < points.length; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= card ? AppColors.purple : AppColors.sky2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _RuleCard(
              key: ValueKey(card),
              number: card + 1,
              point: points[card],
            ),
          ),
          if (points.length > 1)
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: RizmaButton(
                    label: ArLearn.summaryPrevCard,
                    kind: ButtonKind.outlined,
                    icon: 'back',
                    height: 48,
                    onPressed: card > 0
                        ? () => setState(() => _card = card - 1)
                        : null,
                  ),
                ),
                Expanded(
                  child: RizmaButton(
                    label: ArLearn.summaryNextCard,
                    icon: 'fwd',
                    height: 48,
                    onPressed: card < points.length - 1
                        ? () => setState(() => _card = card + 1)
                        : null,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            spacing: 8,
            children: [
              const AppIcon('copy', size: 20, color: AppColors.ink),
              Expanded(
                child: Text(
                  ArLearn.summaryCardsTitle,
                  style: AppTextStyles.section18,
                ),
              ),
              TagChip(
                label: ArLearn.summaryPoints(points.length),
                background: AppColors.sky,
                foreground: AppColors.soft,
              ),
            ],
          ),
          _CardsGrid(
            points: points,
            current: card,
            onTap: (i) => setState(() => _card = i),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({super.key, required this.number, required this.point});

  final int number;
  final SummaryPoint point;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 22,
      edge: AppColors.purpleDark,
      border: Border.all(color: AppColors.purple, width: 2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TagChip(
              label: ArLearn.summaryRule(number),
              icon: 'bulb',
              background: AppColors.amber,
              foreground: AppColors.amberInk,
            ),
          ),
          MathText(
            point.text,
            style: AppTextStyles.section18.copyWith(height: 1.6),
          ),
          if (point.math != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.purpleTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  spacing: 4,
                  children: [
                    MathText(
                      point.math!,
                      style: AppTextStyles.heading22.copyWith(
                        color: AppColors.purple,
                      ),
                    ),
                    if (point.mathNote != null)
                      Text(
                        point.mathNote!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption13,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  const _CardsGrid({
    required this.points,
    required this.current,
    required this.onTap,
  });

  final List<SummaryPoint> points;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    Widget tile(int i) {
      final selected = i == current;
      final seen = i < current;
      return Semantics(
        button: true,
        selected: selected,
        label: ArLearn.summaryCardN(i + 1),
        child: GestureDetector(
          onTap: () => onTap(i),
          child: LedgeBox(
            radius: 18,
            color: selected ? AppColors.purpleTint : AppColors.card,
            edge: selected ? AppColors.purpleDark : null,
            border: selected
                ? Border.all(color: AppColors.purple, width: 2)
                : null,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ArLearn.summaryCardN(i + 1),
                        style: AppTextStyles.caption12,
                      ),
                    ),
                    if (seen)
                      const AppIcon('checkc', size: 16, color: AppColors.teal),
                  ],
                ),
                Text(
                  points[i].text.replaceAll(RegExp(r'[{}]'), ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption13.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      spacing: 10,
      children: [
        for (var i = 0; i < points.length; i += 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(child: tile(i)),
              Expanded(
                child: i + 1 < points.length
                    ? tile(i + 1)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
      ],
    );
  }
}
