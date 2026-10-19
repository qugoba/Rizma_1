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
import '../../core/widgets/offline_chip.dart';
import '../../core/widgets/progress_bar.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_index.dart';
import 'learning_providers.dart';
import 'widgets/learn_cards.dart';
import 'widgets/lesson_search_sheet.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  Future<void> _search(
    BuildContext context,
    WidgetRef ref,
    Catalog catalog,
  ) async {
    final lesson = await showLessonSearchSheet(context, catalog);
    if (lesson != null && context.mounted) {
      context.push(AppRoutes.lesson(lesson.id));
    }
  }

  static String? lastSubjectId(Catalog catalog, LearningIndex index) {
    String? best;
    DateTime? bestAt;
    for (final l in catalog.allLessons) {
      final at = index.updatedAtOf(l.id);
      if (at != null && (bestAt == null || at.isAfter(bestAt))) {
        best = l.subjectId;
        bestAt = at;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final index = ref.watch(learningIndexProvider);
    final grade = ref.watch(activeProfileProvider).value?.grade;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: catalog.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Center(
            child: Text(ArStrings.homeLoadFailed, style: AppTextStyles.body15),
          ),
          data: (c) {
            final highlighted = lastSubjectId(c, index);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(onSearch: () => _search(context, ref, c)),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      12,
                      20,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        if (grade != null)
                          Text(
                            ArLearn.subjectsOfGrade(ArStrings.gradeName(grade)),
                            style: AppTextStyles.title26,
                          ),
                        _List(
                          subjects: c.subjects,
                          index: index,
                          highlighted: highlighted,
                          onOpen: (s) => context.push(AppRoutes.units(s.id)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: RizmaTab.subjects,
        onSelected: (tab) => onTabSelected(context, RizmaTab.subjects, tab),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 4),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Text(ArLearn.subjectsTitle, style: AppTextStyles.heading22),
          ),
          const OfflineChip(),
          Semantics(
            button: true,
            label: ArLearn.subjectsSearchHint,
            excludeSemantics: true,
            child: Material(
              color: AppColors.mute,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSearch,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(child: AppIcon('search')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.subjects,
    required this.index,
    required this.highlighted,
    required this.onOpen,
  });

  final List<CatalogSubject> subjects;
  final LearningIndex index;
  final String? highlighted;
  final ValueChanged<CatalogSubject> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final (i, s) in subjects.indexed)
          _SubjectRow(
            subject: s,
            fraction: index.fraction(s.lessons),
            started: index.startedAny(s.lessons),
            current: index.resumeLesson(s.lessons),
            selected: s.id == highlighted,
            onTap: () => onOpen(s),
          ).fadeIn(i + 1),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.subject,
    required this.fraction,
    required this.started,
    required this.current,
    required this.selected,
    required this.onTap,
  });

  final CatalogSubject subject;
  final double fraction;
  final bool started;
  final CatalogLesson? current;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = subject.color.fg;
    final percent = (fraction * 100).round();

    return LearnRowCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
      semanticsLabel: started
          ? '${subject.title}، $percent%'
          : '${subject.title}، ${ArLearn.subjectNotStarted}',
      child: Row(
        spacing: 12,
        children: [
          IconTile(
            iconName: subject.icon,
            iconColor: fg,
            color: subject.color.tint,
            size: 48,
            iconSize: 24,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(subject.title, style: AppTextStyles.h3_17),
                    ),
                    Text(
                      started ? '$percent%' : ArLearn.subjectNotStarted,
                      style: AppTextStyles.caption12.copyWith(
                        color: started ? fg : AppColors.muteText,
                      ),
                    ),
                  ],
                ),
                ProgressBar(
                  value: fraction,
                  trackColor: AppColors.sky2,
                  fillColor: fg,
                  height: 7,
                ),
                if (current != null)
                  Text(
                    ArLearn.subjectCurrent(current!.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption12,
                  ),
              ],
            ),
          ),
          const AppIcon('fwd', size: 18, color: AppColors.muteText),
        ],
      ),
    );
  }
}
