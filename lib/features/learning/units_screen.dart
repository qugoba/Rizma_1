import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/tab_navigation.dart';
import '../../core/strings/ar.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../../core/widgets/tag_chip.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_index.dart';
import 'learning_providers.dart';
import 'widgets/learn_cards.dart';

class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key, required this.subjectId});

  final String subjectId;

  void _back(BuildContext context) {
    context.canPop() ? context.pop() : context.go(AppRoutes.subjects);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final subject = catalog?.subjectById(subjectId);
    final index = ref.watch(learningIndexProvider);
    final grade = ref.watch(activeProfileProvider).value?.grade;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: subject == null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenTopBar(
                      title: ArLearn.unitsTitle,
                      onBack: () => _back(context),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        12,
                        20,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 14,
                        children: [
                          _SubjectBanner(
                            subject: subject,
                            grade: grade,
                            fraction: index.fraction(subject.lessons),
                          ).fadeIn(0),
                          for (final (i, unit) in subject.units.indexed)
                            _UnitRow(
                              unit: unit,
                              index: index,
                              onTap: () =>
                                  context.push(AppRoutes.lessons(unit.id)),
                              onResume: (l) =>
                                  context.push(AppRoutes.lesson(l.id)),
                            ).fadeIn(i + 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNav(
        current: RizmaTab.subjects,
        onSelected: (tab) => onTabSelected(context, RizmaTab.subjects, tab),
      ),
    );
  }
}

class _SubjectBanner extends StatelessWidget {
  const _SubjectBanner({
    required this.subject,
    required this.grade,
    required this.fraction,
  });

  final CatalogSubject subject;
  final int? grade;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final percent = (fraction * 100).round();
    return LedgeBox(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: TagChip(label: ArLearn.curriculumChip, icon: 'shield'),
          ),
          Row(
            spacing: 12,
            children: [
              IconTile(
                iconName: subject.icon,
                iconColor: subject.color.fg,
                color: subject.color.tint,
                size: 48,
                iconSize: 24,
              ),
              Expanded(
                child: Text(
                  grade == null
                      ? subject.title
                      : '${subject.title} • ${ArStrings.gradeName(grade!)}',
                  style: AppTextStyles.heading22,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TagChip(
                label: ArLearn.unitsCount(subject.units.length),
                icon: 'list',
                background: AppColors.sky,
                foreground: AppColors.soft,
              ),
              TagChip(label: ArLearn.progressChip(percent), icon: 'chart'),
            ],
          ),
          ProgressBar(
            value: fraction,
            trackColor: AppColors.sky2,
            fillColor: AppColors.teal,
            height: 10,
          ),
        ],
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({
    required this.unit,
    required this.index,
    required this.onTap,
    required this.onResume,
  });

  final CatalogUnit unit;
  final LearningIndex index;
  final VoidCallback onTap;
  final ValueChanged<CatalogLesson> onResume;

  @override
  Widget build(BuildContext context) {
    final total = unit.lessons.length;
    final done = index.completedCount(unit.lessons);
    final started = index.startedAny(unit.lessons);
    final complete = total > 0 && done == total;
    final active = started && !complete;
    final fraction = index.fraction(unit.lessons);
    final resume = index.resumeLesson(unit.lessons);

    final status = complete
        ? const TagChip(label: ArLearn.unitDone, icon: 'checkc')
        : active
        ? const TagChip(
            label: ArLearn.unitActive,
            icon: 'bolt',
            background: AppColors.teal,
            foreground: AppColors.card,
          )
        : const TagChip(
            label: ArLearn.unitNotStarted,
            background: AppColors.sky,
            foreground: AppColors.soft,
          );

    return LearnRowCard(
      selected: active,
      onTap: onTap,
      semanticsLabel: '${ArLearn.unitOrdinal(unit.order)}، ${unit.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              status,
              const Spacer(),
              TagChip(
                label: ArLearn.lessonsCount(total),
                background: AppColors.sky,
                foreground: AppColors.soft,
              ),
            ],
          ),
          Text(
            ArLearn.unitHeading(unit.order, unit.title),
            style: AppTextStyles.h3_17,
          ),
          if (started)
            ProgressBar(
              value: fraction,
              trackColor: AppColors.sky2,
              fillColor: AppColors.teal,
              height: 8,
            ),
          if (active && resume != null) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.sky,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        const AppIcon('play', size: 12, color: AppColors.teal),
                        Text(
                          ArLearn.unitActiveLesson,
                          style: AppTextStyles.caption12.copyWith(
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                    Text(resume.title, style: AppTextStyles.body15),
                    Text(
                      ArLearn.lessonsAndDone(total, done),
                      style: AppTextStyles.caption12,
                    ),
                  ],
                ),
              ),
            ),
            RizmaButton(
              label: ArLearn.unitContinue,
              icon: 'fwd',
              onPressed: () => onResume(resume),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Text(
                    complete
                        ? ArLearn.lessonsAndDone(total, done)
                        : ArLearn.lessonsCount(total),
                    style: AppTextStyles.caption12,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: RizmaButton(
                    label: complete ? ArLearn.unitReview : ArLearn.unitStart,
                    icon: complete ? 'retry' : 'play',
                    kind: complete ? ButtonKind.soft : ButtonKind.outlined,
                    height: 42,
                    onPressed: onTap,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
