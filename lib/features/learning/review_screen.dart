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
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';
import '../home/home_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_providers.dart';
import 'lesson_view.dart';
import 'review_plan.dart';
import 'widgets/learn_cards.dart';
import 'widgets/part_frame.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(lessonViewProvider(lessonId)).value;
    final profileId = ref.watch(activeProfileIdProvider).value;
    final mastery = profileId == null
        ? null
        : ref.watch(masteryProvider(profileId)).value;
    final index = ref.watch(learningIndexProvider);

    if (view == null || mastery == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final concepts = view.lesson.concepts;
    final plan = ReviewPlanner.build(
      lessonId: lessonId,
      lessonConcepts: [for (final c in concepts) c.id],
      mastery: {for (final m in mastery) m.conceptId: m.mastery},
      content: view.content,
      partsDone: index.partsDone(lessonId),
    );

    if (plan == null) {
      return PartFrame(
        title: ArLearn.reviewTitle,
        subtitle: ArLearn.reviewKicker,
        lessonId: lessonId,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const Mascot(size: 96),
              Text(
                ArLearn.reviewDoneTitle,
                style: AppTextStyles.heading22,
                textAlign: TextAlign.center,
              ),
              Text(
                ArLearn.reviewDoneBody,
                style: AppTextStyles.label14,
                textAlign: TextAlign.center,
              ),
              RizmaButton(
                label: ArLearn.backToLesson,
                kind: ButtonKind.outlined,
                onPressed: () => context.go(AppRoutes.lesson(lessonId)),
              ),
            ],
          ),
        ),
      );
    }

    final conceptTitle = concepts
        .where((c) => c.id == plan.conceptId)
        .map((c) => c.title)
        .firstOrNull;
    final current = plan.current;
    final percent = (plan.mastery * 100).round();

    return PartFrame(
      title: ArLearn.reviewTitle,
      subtitle: ArLearn.reviewKicker,
      lessonId: lessonId,
      bottom: current == null
          ? null
          : RizmaButton(
              label: ArLearn.reviewContinue(_title(current)),
              icon: 'play',
              onPressed: () => context.push(current.route),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          LedgeBox(
            color: AppColors.coralTint,
            edge: AppColors.coralDark,
            border: Border.all(color: AppColors.coral, width: 2),
            radius: 24,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TagChip(
                      label: ArLearn.reviewPriority,
                      icon: 'target',
                      background: AppColors.coral,
                      foreground: AppColors.card,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conceptTitle ?? plan.conceptId,
                              style: AppTextStyles.heading22,
                            ),
                            Text(
                              ArLearn.reviewCurrentLevel,
                              style: AppTextStyles.label14,
                            ),
                          ],
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '$percent%',
                          style: AppTextStyles.wordmark40.copyWith(
                            color: AppColors.coral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ProgressBar(
                    value: plan.mastery.clamp(0.0, 1.0),
                    trackColor: AppColors.card,
                    fillColor: AppColors.coral,
                    height: 10,
                  ),
                  Text(
                    ArLearn.reviewGoal,
                    style: AppTextStyles.captionBold13.copyWith(
                      color: AppColors.coralDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(ArLearn.reviewSteps, style: AppTextStyles.section18),
          for (final (i, step) in plan.steps.indexed)
            _StepRow(
              number: i + 1,
              step: step,
              isCurrent: identical(step, current),
            ).fadeIn(i),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.amberTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                spacing: 12,
                children: [
                  const Expanded(
                    child: Text(
                      ArLearn.reviewQuote,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.6,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const Mascot(size: 52),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _title(ReviewStep s) => switch (s.part) {
  LessonPart.explanation => ArLearn.reviewStepExplain,
  LessonPart.video => ArLearn.reviewStepVideo,
  LessonPart.practice => ArLearn.reviewStepPractice(s.count),
  _ => ArLearn.reviewStepQuiz,
};

String _meta(ReviewStep s) => switch (s.part) {
  LessonPart.explanation => ArLearn.minutesCount(s.minutes),
  LessonPart.video => ArLearn.minutesCount(s.minutes),
  LessonPart.practice => ArLearn.reviewStepPracticeNote,
  _ => ArLearn.reviewStepQuizNote,
};

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.step,
    required this.isCurrent,
  });

  final int number;
  final ReviewStep step;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final (icon, fg, tint) = switch (step.part) {
      LessonPart.explanation => (
        'bulb',
        AppColors.amberDark,
        AppColors.amberTint,
      ),
      LessonPart.video => ('video', AppColors.coral, AppColors.coralTint),
      LessonPart.practice => ('target', AppColors.purple, AppColors.purpleTint),
      _ => ('trophy', AppColors.teal, AppColors.tealTint),
    };

    return LearnRowCard(
      onTap: () => context.push(step.route),
      selected: isCurrent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      semanticsLabel: '${_title(step)}، ${_meta(step)}',
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.done ? AppColors.teal : AppColors.mute,
              border: isCurrent
                  ? Border.all(color: AppColors.teal, width: 2)
                  : null,
            ),
            child: step.done
                ? const AppIcon('check', size: 18, color: AppColors.card)
                : Text('$number', style: AppTextStyles.body15),
          ),
          IconTile(iconName: icon, iconColor: fg, color: tint, radius: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title(step), style: AppTextStyles.body16Strong),
                Text(_meta(step), style: AppTextStyles.caption13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
