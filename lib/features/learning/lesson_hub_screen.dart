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
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../../core/widgets/tag_chip.dart';
import '../account/account_providers.dart';
import '../catalog/catalog_models.dart';
import '../catalog/catalog_providers.dart';
import '../content/content_providers.dart';
import '../content/lesson_content.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_providers.dart';
import 'widgets/learn_cards.dart';
import 'widgets/lesson_files.dart';

class LessonHubScreen extends ConsumerWidget {
  const LessonHubScreen({super.key, required this.lessonId});

  final String lessonId;

  void _back(BuildContext context, CatalogLesson? lesson) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        lesson == null ? AppRoutes.subjects : AppRoutes.lessons(lesson.unitId),
      );
    }
  }

  Future<void> _toggleBookmark(
    BuildContext context,
    WidgetRef ref,
    bool saved,
  ) async {
    final profileId = ref.read(activeProfileIdProvider).value;
    if (profileId == null) return;
    await ref
        .read(preferencesRepositoryProvider)
        .setBookmarked(profileId, lessonId, !saved);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? ArLearn.lessonUnsaved : ArLearn.lessonSaved),
      ),
    );
  }

  void _open(BuildContext context, LessonPart part) {
    switch (part) {
      case LessonPart.practice:
        context.push(AppRoutes.round(lessonId));
      case LessonPart.quiz:
        context.push(AppRoutes.quiz(lessonId));
      case _:
        context.push(AppRoutes.lessonPart(lessonId, part.name));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final lesson = catalog?.lessonById(lessonId);
    final unit = lesson == null ? null : catalog?.unitOfLesson(lesson);
    final content = ref.watch(lessonContentProvider(lessonId));
    final index = ref.watch(learningIndexProvider);
    final saved =
        ref.watch(bookmarksProvider).value?.contains(lessonId) ?? false;

    return Scaffold(
      body: SafeArea(
        child: lesson == null || unit == null
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenTopBar(
                    title: lesson.title,
                    subtitle: ArLearn.lessonKicker(lesson.order, unit.order),
                    onBack: () => _back(context, lesson),
                    end: Semantics(
                      button: true,
                      label: saved
                          ? ArLearn.lessonUnsaved
                          : ArLearn.lessonSaved,
                      excludeSemantics: true,
                      child: Material(
                        color: AppColors.mute,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _toggleBookmark(context, ref, saved),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: AppIcon(
                                'bookmark',
                                color: saved ? AppColors.teal : AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: content.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (c) => SingleChildScrollView(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          12,
                          20,
                          24,
                        ),
                        child: _Body(
                          lessonId: lessonId,
                          content: c,
                          progress: index.progressOf(lessonId),
                          done: index.partsDone(lessonId),
                          onOpen: (p) => _open(context, p),
                        ),
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
    required this.lessonId,
    required this.content,
    required this.progress,
    required this.done,
    required this.onOpen,
  });

  final String lessonId;
  final LessonContent? content;
  final double progress;
  final Set<LessonPart> done;
  final ValueChanged<LessonPart> onOpen;

  static List<LessonPart> _shown(LessonContent c) {
    final parts = c.parts;
    return [
      if (parts.contains(LessonPart.words)) LessonPart.words,
      for (final p in parts)
        if (p != LessonPart.words) p,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = content;
    final shown = c == null ? const <LessonPart>[] : _shown(c);
    final available = [
      for (final p in shown)
        if (c!.has(p)) p,
    ];
    final doneCount = available.where(done.contains).length;
    final next = available.where((p) => !done.contains(p)).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _SummaryCard(
          done: doneCount,
          total: available.length,
          progress: progress,
          loaded: c != null,
        ).fadeIn(0),
        Text(
          c == null ? ArLearn.lessonNoContent : ArLearn.lessonChoose,
          style: AppTextStyles.caption13,
        ),
        if (c != null)
          for (final (i, part) in shown.indexed)
            _PartRow(
              part: part,
              content: c,
              done: done.contains(part),
              next: part == next,
              onTap: c.has(part) ? () => onOpen(part) : null,
            ).fadeIn(i + 1),
        if (c != null && c.attachments.isNotEmpty)
          LessonFilesSection(
            lessonId: lessonId,
            attachments: c.attachments,
          ).fadeIn(shown.length + 1),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.done,
    required this.total,
    required this.progress,
    required this.loaded,
  });

  final int done;
  final int total;
  final double progress;
  final bool loaded;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      color: AppColors.teal,
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  ArLearn.stationsDone(done, total),
                  style: AppTextStyles.h3_17.copyWith(color: AppColors.card),
                ),
              ),
              TagChip(
                label: loaded ? ArLearn.lessonLoaded : ArLearn.lessonNoContent,
                icon: loaded ? 'checkc' : 'clock',
                background: AppColors.tealDark,
                foreground: AppColors.card,
              ),
            ],
          ),
          ProgressBar(
            value: progress,
            trackColor: AppColors.tealDark,
            fillColor: AppColors.mint,
            height: 10,
          ),
        ],
      ),
    );
  }
}

class _PartStyle {
  const _PartStyle(this.icon, this.fg, this.tint, this.title);

  final String icon;
  final Color fg;
  final Color tint;
  final String title;
}

const _styles = {
  LessonPart.pack: _PartStyle(
    'file',
    AppColors.teal,
    AppColors.tealTint,
    ArLearn.partPack,
  ),
  LessonPart.explanation: _PartStyle(
    'bulb',
    AppColors.amberDark,
    AppColors.amberTint,
    ArLearn.partExplanation,
  ),
  LessonPart.summary: _PartStyle(
    'list',
    AppColors.blue,
    AppColors.blueTint,
    ArLearn.partSummary,
  ),
  LessonPart.video: _PartStyle(
    'video',
    AppColors.coral,
    AppColors.coralTint,
    ArLearn.partVideo,
  ),
  LessonPart.words: _PartStyle(
    'volume',
    AppColors.purple,
    AppColors.purpleTint,
    ArLearn.partWords,
  ),
  LessonPart.practice: _PartStyle(
    'target',
    AppColors.purple,
    AppColors.purpleTint,
    ArLearn.partPractice,
  ),
  LessonPart.quiz: _PartStyle(
    'trophy',
    AppColors.teal,
    AppColors.tealTint,
    ArLearn.partQuiz,
  ),
};

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.part,
    required this.content,
    required this.done,
    required this.next,
    required this.onTap,
  });

  final LessonPart part;
  final LessonContent content;
  final bool done;

  final bool next;
  final VoidCallback? onTap;

  String get _meta {
    if (!content.has(part)) return ArLearn.lessonComingSoon;
    return switch (part) {
      LessonPart.pack => ArLearn.packMeta(content.pages.length),
      LessonPart.explanation => ArLearn.explanationMeta(content.steps.length),
      LessonPart.summary => ArLearn.summaryMeta(content.summary.length),
      LessonPart.video => ArLearn.videoMeta(content.video!.minutes),
      LessonPart.words => ArLearn.wordsMeta(content.words.length),
      LessonPart.practice => ArLearn.practiceMeta(
        content.practice.length.clamp(0, 8),
      ),
      LessonPart.quiz => ArLearn.quizMeta(content.quiz.length),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _styles[part]!;
    final enabled = onTap != null;

    if (next && enabled) {
      return LedgeBox(
        color: AppColors.amberTint,
        edge: AppColors.amberDark,
        border: Border.all(color: AppColors.amber, width: 2),
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              spacing: 12,
              children: [
                IconTile(
                  iconName: style.icon,
                  iconColor: AppColors.card,
                  color: AppColors.amber,
                  radius: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(style.title, style: AppTextStyles.h3_17),
                      Text(_meta, style: AppTextStyles.caption13),
                    ],
                  ),
                ),
              ],
            ),
            RizmaButton(
              label: ArLearn.stationStart,
              kind: ButtonKind.amber,
              icon: 'play',
              height: 46,
              onPressed: onTap,
            ),
          ],
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: LearnRowCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        semanticsLabel: '${style.title}، $_meta',
        child: Row(
          spacing: 14,
          children: [
            IconTile(
              iconName: style.icon,
              iconColor: style.fg,
              color: style.tint,
              radius: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(style.title, style: AppTextStyles.body16Strong),
                  Text(_meta, style: AppTextStyles.caption13),
                ],
              ),
            ),
            if (done)
              const AppIcon('checkc', size: 24, color: AppColors.teal)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.disabled, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
