import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/db/enums.dart';
import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/rizma_look.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/mascot.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/tag_chip.dart';
import '../home_state.dart';

class FeaturedLessonCard extends StatelessWidget {
  const FeaturedLessonCard({
    super.key,
    required this.lesson,
    required this.firstDay,
    required this.onPressed,
    this.mascotColor = ProfileColor.teal,
  });

  final LessonRef lesson;
  final bool firstDay;
  final VoidCallback onPressed;
  final ProfileColor mascotColor;

  @override
  Widget build(BuildContext context) {
    if (firstDay) return _firstDay();
    if (RizmaLook.of(context).calm) return _calm();
    return _active();
  }

  Widget _subjectChip({required Color bg, required Color fg}) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 10, 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          AppIcon(lesson.subject.icon, size: 16, color: fg),
          Flexible(
            child: Text(
              ArStrings.homeSubjectUnit(lesson.subject.title, lesson.unit.title),
              style: AppTextStyles.caption12.copyWith(color: fg),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _firstDay() {
    return LedgeBox(
      color: AppColors.amberTint,
      edge: AppColors.amberDark,
      border: Border.all(color: AppColors.amber, width: 2),
      radius: 24,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              const TagChip(
                label: ArStrings.homeFirstMission,
                icon: 'target',
                background: AppColors.amberInk,
                foreground: AppColors.card,
              ),
              TagChip(
                label: ArStrings.homeLessonMeta(lesson.lesson.estimatedMinutes),
                icon: 'clock',
                background: AppColors.card,
                foreground: AppColors.amberInk,
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      ArStrings.homeStartFirstLesson(lesson.lesson.title),
                      style: AppTextStyles.heading22,
                    ),
                    Text(
                      ArStrings.homeSubjectUnit(
                        lesson.subject.title,
                        lesson.unit.title,
                      ),
                      style: AppTextStyles.caption13,
                    ),
                  ],
                ),
              ),
              Mascot(size: 72, color: mascotColor),
            ],
          ),
          PrimaryButton(
            label: ArStrings.homeStartLesson,
            iconAsset: AppAssets.play,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget _calm() {
    final percent = (lesson.progress * 100).round();
    return LedgeBox(
      radius: 24,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            ArStrings.homeResumeKicker,
            style: AppTextStyles.caption12.copyWith(color: AppColors.teal),
          ),
          _subjectChip(bg: AppColors.tealTint, fg: AppColors.teal),
          Text(
            ArStrings.homeLessonTitle(lesson.lesson.order, lesson.lesson.title),
            style: AppTextStyles.heading22,
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: ProgressBar(
                  value: lesson.progress,
                  trackColor: AppColors.sky2,
                  fillColor: AppColors.teal,
                  height: 10,
                ),
              ),
              Text(
                '$percent%',
                style: AppTextStyles.label14.copyWith(color: AppColors.teal),
              ),
            ],
          ),
          PrimaryButton(
            label: ArStrings.homeContinue,
            iconAsset: AppAssets.play,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget _active() {
    final percent = (lesson.progress * 100).round();

    return LedgeBox(
      color: AppColors.teal,
      radius: 24,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _subjectChip(bg: AppColors.tealDark, fg: AppColors.card),
          Text(
            ArStrings.homeLessonTitle(lesson.lesson.order, lesson.lesson.title),
            style: AppTextStyles.title26.copyWith(color: AppColors.card),
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: ProgressBar(
                  value: lesson.progress,
                  trackColor: AppColors.tealDark,
                  fillColor: AppColors.mint,
                  height: 12,
                ),
              ),
              Text(
                '$percent%',
                style: AppTextStyles.label14.copyWith(color: AppColors.card),
              ),
            ],
          ),
          PrimaryButton(
            label: ArStrings.homeContinue,
            iconAsset: AppAssets.play,
            backgroundColor: AppColors.card,
            foregroundColor: AppColors.teal,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
