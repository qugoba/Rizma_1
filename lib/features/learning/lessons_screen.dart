import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/enums.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../../core/widgets/tag_chip.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_providers.dart';
import '../content/content_providers.dart';
import 'learning_index.dart';
import 'learning_providers.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key, required this.unitId});

  final String unitId;

  void _back(BuildContext context, String? subjectId) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        subjectId == null ? AppRoutes.subjects : AppRoutes.units(subjectId),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final index = ref.watch(learningIndexProvider);
    final withContent = ref.watch(contentIndexProvider).value ?? const {};

    CatalogUnit? unit;
    CatalogSubject? subject;
    if (catalog != null) {
      for (final s in catalog.subjects) {
        for (final u in s.units) {
          if (u.id == unitId) {
            unit = u;
            subject = s;
          }
        }
      }
    }
    final u = unit;
    final s = subject;

    return Scaffold(
      body: SafeArea(
        child: u == null || s == null
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenTopBar(
                    title: ArLearn.lessonsTitle,
                    onBack: () => _back(context, s.id),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        12,
                        20,
                        12,
                      ),
                      child: _Body(
                        subject: s,
                        unit: u,
                        index: index,
                        withContent: withContent,
                        onDownload: () => context.push(AppRoutes.downloads),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.subject,
    required this.unit,
    required this.index,
    required this.withContent,
    required this.onDownload,
  });

  final CatalogSubject subject;
  final CatalogUnit unit;
  final LearningIndex index;
  final Set<String> withContent;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final done = index.completedCount(unit.lessons);
    final total = unit.lessons.length;
    final fraction = total == 0 ? 0.0 : done / total;
    final resume = index.resumeLesson(unit.lessons);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        LedgeBox(
          radius: 22,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TagChip(
                  label: ArLearn.lessonsKicker(subject.title, unit.order),
                  icon: subject.icon,
                ),
              ),
              Text(
                ArLearn.unitHeading(unit.order, unit.title),
                style: AppTextStyles.heading22,
              ),
              Row(
                children: [
                  Text(
                    '${(fraction * 100).round()}%',
                    style: AppTextStyles.body15.copyWith(color: AppColors.teal),
                  ),
                  const Spacer(),
                  Text(
                    ArLearn.lessonsDoneSentence(done, total),
                    style: AppTextStyles.caption12,
                  ),
                ],
              ),
              ProgressBar(
                value: fraction,
                trackColor: AppColors.sky2,
                fillColor: AppColors.teal,
                height: 10,
              ),
              RizmaButton(
                label: ArLearn.downloadUnit,
                kind: ButtonKind.outlined,
                icon: 'download',
                height: 46,
                onPressed: onDownload,
              ),
            ],
          ),
        ).fadeIn(0),
        Row(
          spacing: 8,
          children: [
            const AppIcon('bookmark', size: 20, color: AppColors.ink),
            Expanded(
              child: Text(ArLearn.lessonsPath, style: AppTextStyles.section18),
            ),
            TagChip(
              label: ArLearn.lessonsCount(total),
              background: AppColors.sky,
              foreground: AppColors.soft,
            ),
          ],
        ),
        for (final (i, lesson) in unit.lessons.indexed)
          _LessonRow(
            lesson: lesson,
            status: index.statusOf(lesson.id),
            progress: index.progressOf(lesson.id),
            hasContent: withContent.contains(lesson.id),
            current: lesson.id == resume?.id,
            last: i == unit.lessons.length - 1,
            onTap: () => context.push(AppRoutes.lesson(lesson.id)),
          ).fadeIn(i + 1),
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.status,
    required this.progress,
    required this.hasContent,
    required this.current,
    required this.last,
    required this.onTap,
  });

  final CatalogLesson lesson;
  final LessonStatus status;
  final double progress;
  final bool hasContent;
  final bool current;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = status == LessonStatus.completed;
    final inProgress = status == LessonStatus.inProgress;
    final isCurrent = current && !done;
    final percent = (progress * 100).round();
    final caption = done
        ? ArLearn.lessonDone
        : inProgress
        ? ArLearn.lessonInProgress(percent)
        : ArLearn.lessonNotStarted;

    final chip = done
        ? const TagChip(label: ArLearn.lessonDone, icon: 'checkc')
        : isCurrent
        ? const TagChip(
            label: ArLearn.lessonCurrent,
            background: AppColors.amberTint,
            foreground: AppColors.amberInk,
          )
        : const TagChip(
            label: ArLearn.lessonOpen,
            background: AppColors.blueTint,
            foreground: AppColors.blue,
          );

    final card = Semantics(
      container: true,
      button: true,
      label: '${lesson.title}، $caption',
      child: LedgeBox(
        radius: 20,
        clip: true,
        edge: isCurrent ? AppColors.amberDark : null,
        border: isCurrent ? Border.all(color: AppColors.amber, width: 2) : null,
        child: Material(
          color: AppColors.card,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: [
                  Row(
                    children: [
                      chip,
                      const Spacer(),
                      hasContent
                          ? const AppIcon(
                              'checkc',
                              size: 18,
                              color: AppColors.teal,
                            )
                          : const AppIcon(
                              'download',
                              size: 18,
                              color: AppColors.muteText,
                            ),
                    ],
                  ),
                  Text(
                    ArLearn.lessonNumbered(lesson.order, lesson.title),
                    style: AppTextStyles.h3_17,
                  ),
                  Text(
                    caption,
                    style: AppTextStyles.caption12.copyWith(
                      color: inProgress ? AppColors.teal : AppColors.muteText,
                    ),
                  ),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: RizmaButton(
                        label: ArLearn.lessonContinue,
                        icon: 'fwd',
                        height: 46,
                        onPressed: onTap,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                const SizedBox(height: 14),
                _StateCircle(
                  done: done,
                  current: isCurrent,
                  number: lesson.order,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.only(top: 4),
                      color: done ? AppColors.teal : AppColors.sky2,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: card),
        ],
      ),
    );
  }
}

class _StateCircle extends StatelessWidget {
  const _StateCircle({
    required this.done,
    required this.current,
    required this.number,
  });

  final bool done;
  final bool current;
  final int number;

  @override
  Widget build(BuildContext context) {
    final Color? fill = done
        ? AppColors.teal
        : current
        ? AppColors.amber
        : null;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: fill ?? AppColors.card,
        shape: BoxShape.circle,
        border: fill == null
            ? Border.all(color: AppColors.teal, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: done
          ? const AppIcon('check', size: 18, color: AppColors.card)
          : current
          ? const AppIcon('play', size: 16, color: AppColors.amberInk)
          : Text(
              '$number',
              style: AppTextStyles.label14.copyWith(color: AppColors.teal),
            ),
    );
  }
}
