import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/db/enums.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/rizma_button.dart';
import '../catalog/catalog_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_providers.dart';
import 'widgets/question_parts.dart';

class RoundEndScreen extends ConsumerWidget {
  const RoundEndScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(attemptDetailsProvider(attemptId)).value;
    final catalog = ref.watch(catalogProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final name = profile?.name ?? '';

    if (loaded == null) return const Scaffold(body: SizedBox.shrink());
    final a = loaded.attempt;
    final d = loaded.details;
    final lessonId = d.lessonId;
    final concepts = {
      for (final c in catalog?.lessonById(lessonId)?.concepts ?? const [])
        c.id: c.title,
    };
    final kinds = {for (final r in d.results) r.kind};

    Widget stat(
      String icon,
      String value,
      String label,
      Color fg,
      Color bg,
    ) => LedgeBox(
      color: bg,
      radius: 20,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 22, color: AppColors.card),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  value,
                  style: AppTextStyles.section18.copyWith(color: AppColors.ink),
                ),
              ),
            ),
          ),
          Text(label, style: AppTextStyles.captionBold13.copyWith(color: fg)),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.amber, width: 5),
                        ),
                        alignment: Alignment.center,
                        child: Mascot(
                          size: 104,
                          color: profile?.color ?? ProfileColor.teal,
                        ),
                      ),
                    ).fadeIn(0),
                    Text(
                      ArLearn.roundEndTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title26,
                    ),
                    Text(
                      ArLearn.roundEndSubtitle(name, a.score, a.total),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label14,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        stat(
                          'checkc',
                          '${a.score}/${a.total}',
                          ArLearn.roundEndCorrectLabel,
                          AppColors.teal,
                          AppColors.tealTint,
                        ),
                        if (a.score < a.total)
                          stat(
                            'retry',
                            '${a.total - a.score}',
                            ArLearn.roundEndToReview,
                            AppColors.coral,
                            AppColors.coralTint,
                          ),
                        stat(
                          'starf',
                          '+${a.starsEarned}',
                          ArLearn.roundEndStarsLabel,
                          AppColors.amberDark,
                          AppColors.amberTint,
                        ),
                      ],
                    ).fadeIn(1),
                    if (a.starsEarned == 0 && d.rawStars > 0)
                      const Text(
                        ArLearn.roundEndNoNewStars,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.soft,
                        ),
                      ),
                    _Card(
                      title: ArLearn.roundEndGames,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final k in kinds)
                            Builder(
                              builder: (_) {
                                final chip = kindChip(k);
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: chip.tint,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      chip.label,
                                      style: AppTextStyles.chip13.copyWith(
                                        color: chip.fg,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ).fadeIn(2),
                    for (final (i, e) in d.masteryAfter.entries.indexed)
                      _MasteryCard(
                        title: concepts[e.key] ?? e.key,
                        before: d.masteryBefore[e.key],
                        after: e.value ?? 0,
                      ).fadeIn(3 + i),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 24),
              child: Column(
                spacing: 10,
                children: [
                  RizmaButton(
                    label: ArLearn.roundEndNew,
                    icon: 'shuffle',
                    onPressed: () =>
                        context.pushReplacement(AppRoutes.round(lessonId)),
                  ),
                  RizmaButton(
                    label: ArLearn.backToLesson,
                    kind: ButtonKind.outlined,
                    onPressed: () => context.go(AppRoutes.lesson(lessonId)),
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

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            if (title.isNotEmpty)
              Text(title, style: AppTextStyles.captionBold13),
            child,
          ],
        ),
      ),
    );
  }
}

class _MasteryCard extends StatelessWidget {
  const _MasteryCard({
    required this.title,
    required this.before,
    required this.after,
  });

  final String title;
  final double? before;
  final double after;

  @override
  Widget build(BuildContext context) {
    final to = '${(after * 100).round()}%';
    final change = before == null ? to : '${(before! * 100).round()}% → $to';
    return _Card(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.body16Strong)),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  change,
                  style: AppTextStyles.body15.copyWith(color: AppColors.teal),
                ),
              ),
            ],
          ),
          ProgressBar(
            value: after.clamp(0.0, 1.0),
            trackColor: AppColors.track,
            fillColor: AppColors.teal,
            height: 8,
          ),
        ],
      ),
    );
  }
}
