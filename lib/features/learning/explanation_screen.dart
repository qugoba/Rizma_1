import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/enums.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ledge.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/fraction_bar.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/math_text.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';
import '../content/lesson_content.dart';
import '../content/speech_service.dart';
import '../profiles/active_profile_provider.dart';
import 'lesson_view.dart';
import 'widgets/part_frame.dart';

class ExplanationScreen extends ConsumerStatefulWidget {
  const ExplanationScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<ExplanationScreen> createState() => _ExplanationScreenState();
}

class _ExplanationScreenState extends ConsumerState<ExplanationScreen> {
  int _step = 0;
  bool _needMore = false;

  Future<void> _read(ExplainStep step) async {
    final ok = await ref
        .read(speechServiceProvider)
        .speak('${step.title}. ${_plain(step.body)}', language: 'ar');
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(ArLearn.speechUnavailable)));
    }
  }

  static String _plain(String text) => text
      .replaceAllMapped(
        RegExp(r'\{([^{}/]*)/([^{}]*)\}'),
        (m) => '${m[1]} على ${m[2]}',
      )
      .replaceAll('{?}', 'الخانة الفارغة');

  Future<void> _next(int total) async {
    ref.read(speechServiceProvider).stop();
    if (_step < total - 1) {
      setState(() {
        _step++;
        _needMore = false;
      });
      return;
    }
    await completeLessonPart(
      ref,
      lessonId: widget.lessonId,
      part: LessonPart.explanation,
    );
    if (!mounted) return;
    final hasSummary =
        ref
            .read(lessonViewProvider(widget.lessonId))
            .value
            ?.content
            ?.has(LessonPart.summary) ??
        false;
    if (hasSummary) {
      context.pushReplacement(
        AppRoutes.lessonPart(widget.lessonId, LessonPart.summary.name),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(lessonViewProvider(widget.lessonId)).value;
    final steps = view?.content?.steps ?? const <ExplainStep>[];
    final color =
        ref.watch(activeProfileProvider).value?.color ?? ProfileColor.teal;

    if (view == null || steps.isEmpty) {
      return PartFrame(
        title: ArLearn.explainTitle,
        subtitle: view?.lesson.title ?? '',
        lessonId: widget.lessonId,
        child: const PartUnavailable(),
      );
    }

    final step = steps[_step.clamp(0, steps.length - 1)];
    final isLast = _step == steps.length - 1;
    final hasSummary = view.content!.has(LessonPart.summary);

    return PartFrame(
      title: ArLearn.explainTitle,
      subtitle: view.lesson.title,
      lessonId: widget.lessonId,
      end: const TagChip(label: ArLearn.lessonLoaded, icon: 'download'),
      bottom: RizmaButton(
        label: isLast && hasSummary
            ? ArLearn.explainNextSummary
            : ArLearn.explainNext,
        icon: 'fwd',
        onPressed: () => _next(steps.length),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Column(
          key: ValueKey(_step),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    ArLearn.explainStep(_step + 1, steps.length),
                    style: AppTextStyles.body15,
                  ),
                ),
                const TagChip(label: ArLearn.explainKicker, icon: 'bulb'),
              ],
            ),
            _StepBar(current: _step, total: steps.length),
            _ConceptCard(step: step),
            _ListenCard(onTap: () => _read(step)),
            if (step.rows.isNotEmpty) _RowsCard(rows: step.rows),
            if (step.tip != null) _TipCard(text: step.tip!, color: color),
            _Feedback(
              needMore: _needMore,
              onGotIt: () => _next(steps.length),
              onNeedMore: () => setState(() => _needMore = true),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        for (var i = 0; i < total; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 8,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.teal : AppColors.sky2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.step});

  final ExplainStep step;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: TagChip(
              label: ArLearn.explainConcept,
              icon: 'bolt',
              background: AppColors.purpleTint,
              foreground: AppColors.purple,
            ),
          ),
          Text(step.title, style: AppTextStyles.heading22),
          if (step.body.isNotEmpty)
            MathText(
              step.body,
              style: AppTextStyles.body15.copyWith(
                color: AppColors.soft,
                fontWeight: FontWeight.w600,
                height: 1.7,
              ),
            ),
        ],
      ),
    );
  }
}

class _ListenCard extends StatelessWidget {
  const _ListenCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: ArLearn.explainRead,
      excludeSemantics: true,
      child: LedgeBox(
        color: AppColors.teal,
        radius: 20,
        clip: true,
        child: Material(
          color: AppColors.teal,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const AppIcon(
                      'volume',
                      size: 22,
                      color: AppColors.teal,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ArLearn.explainListen,
                          style: AppTextStyles.body16Strong.copyWith(
                            color: AppColors.card,
                          ),
                        ),
                        Text(
                          ArLearn.explainListenSub,
                          style: AppTextStyles.caption12.copyWith(
                            color: AppColors.onTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppIcon('play', size: 22, color: AppColors.card),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowsCard extends StatelessWidget {
  const _RowsCard({required this.rows});

  final List<BarRow> rows;

  static bool _same(BarRow a, BarRow b) =>
      a.filled * b.parts == b.filled * a.parts;

  @override
  Widget build(BuildContext context) {
    final allSame = rows.every((r) => _same(r, rows.first));

    return LedgeBox(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              const AppIcon('chart', size: 20, color: AppColors.teal),
              Expanded(
                child: Text(
                  ArLearn.explainVisual,
                  style: AppTextStyles.section18,
                ),
              ),
              const TagChip(
                label: ArLearn.explainVisualChip,
                background: AppColors.sky,
                foreground: AppColors.soft,
              ),
            ],
          ),
          for (final (i, r) in rows.indexed) ...[
            if (i > 0 && _same(r, rows[i - 1]))
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: Text(
                      ArLearn.explainEqual,
                      style: AppTextStyles.caption12.copyWith(
                        color: AppColors.card,
                      ),
                    ),
                  ),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: MathText(
                r.label,
                style: AppTextStyles.section18.copyWith(color: AppColors.teal),
              ),
            ),
            FractionBar(parts: r.parts, filled: r.filled, height: 34),
          ],
          if (allSame && rows.length > 1)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.sky,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  spacing: 8,
                  children: [
                    const AppIcon('bulb', size: 18, color: AppColors.teal),
                    Expanded(
                      child: Text(
                        ArLearn.explainNotice,
                        style: AppTextStyles.caption12.copyWith(
                          color: AppColors.soft,
                        ),
                      ),
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

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text, required this.color});

  final String text;
  final ProfileColor color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.amberTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amberLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Mascot(size: 56, color: color, mood: MascotMood.thinking),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 2,
                children: [
                  Text(
                    ArLearn.explainTipTitle,
                    style: AppTextStyles.body15.copyWith(
                      color: AppColors.amberInk,
                    ),
                  ),
                  MathText(
                    text,
                    style: AppTextStyles.label14.copyWith(
                      color: AppColors.amberInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.needMore,
    required this.onGotIt,
    required this.onNeedMore,
  });

  final bool needMore;
  final VoidCallback onGotIt;
  final VoidCallback onNeedMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(ArLearn.explainFeedback, style: AppTextStyles.label14),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: RizmaButton(
                label: ArLearn.explainGotIt,
                kind: ButtonKind.soft,
                icon: 'check',
                height: 48,
                onPressed: onGotIt,
              ),
            ),
            Expanded(
              child: RizmaButton(
                label: ArLearn.explainNeedMore,
                kind: ButtonKind.amber,
                icon: 'hand',
                height: 48,
                onPressed: onNeedMore,
              ),
            ),
          ],
        ),
        if (needMore)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              const AppIcon('hand', size: 20, color: AppColors.amberDark),
              Expanded(
                child: Text(
                  ArLearn.explainNeedMoreNote,
                  style: AppTextStyles.label14,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
