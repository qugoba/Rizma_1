import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/constants/learning_rules.dart';
import '../../core/strings/ar_learning.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/db/enums.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/rizma_button.dart';
import '../catalog/catalog_providers.dart';
import '../profiles/active_profile_provider.dart';
import 'learning_providers.dart';
import 'round_engine.dart';

const masteredAt = kMasteryThreshold;

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(attemptDetailsProvider(attemptId)).value;
    final catalog = ref.watch(catalogProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final name = profile?.name ?? '';
    if (loaded == null) return const Scaffold(body: SizedBox.shrink());

    final d = loaded.details;
    final lesson = catalog?.lessonById(d.lessonId);
    final unit = lesson == null ? null : catalog?.unitOfLesson(lesson);
    final titles = {
      for (final c in lesson?.concepts ?? const []) c.id: c.title,
    };
    final percent = RoundEngine.percent(d.results);
    final rating = RoundEngine.ratingStars(d.results);

    final mastered = <MapEntry<String, double>>[];
    final review = <MapEntry<String, double>>[];
    for (final e in d.masteryAfter.entries) {
      final v = e.value ?? 0;
      (v >= masteredAt ? mastered : review).add(MapEntry(e.key, v));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    Text(
                      [
                        if (unit != null)
                          ArLearn.quizHeader(ArLearn.unitOrdinal(unit.order)),
                        if (lesson != null) lesson.title,
                      ].join(' · '),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label14,
                    ),
                    Center(
                      child: Mascot(
                        size: 104,
                        color: profile?.color ?? ProfileColor.teal,
                      ),
                    ).fadeIn(0),
                    Text(
                      percent >= 60
                          ? ArLearn.resultHeadingGood(name)
                          : ArLearn.resultHeadingTry(name),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title26,
                    ),
                    _Stars(rating: rating).fadeIn(0),
                    _ScoreCard(
                      correct: d.results.where((r) => r.correct).length,
                      total: d.results.length,
                      percent: percent,
                    ).fadeIn(1),
                    if (mastered.isNotEmpty)
                      _ConceptCard(
                        title: ArLearn.resultMastered,
                        rows: [
                          for (final e in mastered)
                            (titles[e.key] ?? e.key, e.value),
                        ],
                        fg: AppColors.teal,
                        bg: AppColors.card,
                        icon: 'checkc',
                      ).fadeIn(2),
                    if (review.isNotEmpty)
                      _ConceptCard(
                        title: ArLearn.resultNeedsReview,
                        rows: [
                          for (final e in review)
                            (titles[e.key] ?? e.key, e.value),
                        ],
                        fg: AppColors.coral,
                        bg: AppColors.coralTint,
                        icon: 'target',
                        note: ArLearn.resultReviewNote,
                      ).fadeIn(3),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 24),
              child: Column(
                spacing: 10,
                children: [
                  if (review.isNotEmpty)
                    RizmaButton(
                      label: ArLearn.resultStartReview,
                      icon: 'bolt',
                      onPressed: () =>
                          context.pushReplacement(AppRoutes.review(d.lessonId)),
                    ),
                  RizmaButton(
                    label: ArLearn.backToLesson,
                    kind: ButtonKind.outlined,
                    onPressed: () => context.go(AppRoutes.lesson(d.lessonId)),
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

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    const sizes = [48.0, 64.0, 48.0];
    return Semantics(
      label: '$rating / 3',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          for (var i = 0; i < 3; i++)
            AppIcon(
              i < rating ? 'starf' : 'star',
              size: sizes[i],
              color: i < rating ? AppColors.amber : AppColors.disabled,
            ),
        ],
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({
    required this.title,
    required this.rows,
    required this.fg,
    required this.bg,
    required this.icon,
    this.note,
  });

  final String title;
  final List<(String, double)> rows;
  final Color fg;
  final Color bg;
  final String icon;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      color: bg,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(title, style: AppTextStyles.body16Strong.copyWith(color: fg)),
            for (final (name, value) in rows)
              Row(
                spacing: 10,
                children: [
                  Expanded(child: Text(name, style: AppTextStyles.body15)),
                  Text(
                    '${(value * 100).round()}%',
                    style: AppTextStyles.captionBold13.copyWith(color: fg),
                  ),
                  AppIcon(icon, size: 22, color: fg),
                ],
              ),
            if (note != null) Text(note!, style: AppTextStyles.label14),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.correct,
    required this.total,
    required this.percent,
  });

  final int correct;
  final int total;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 22,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ArLearn.resultYourScore, style: AppTextStyles.label14),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$correct',
                          style: AppTextStyles.big44.copyWith(
                            color: AppColors.teal,
                          ),
                        ),
                        TextSpan(
                          text: ' / $total',
                          style: AppTextStyles.section18.copyWith(
                            color: AppColors.muteText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ProgressRing(
            value: percent / 100,
            size: 84,
            stroke: 10,
            trackColor: AppColors.sky2,
            fillColor: AppColors.teal,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text('$percent%', style: AppTextStyles.body16Strong),
            ),
          ),
        ],
      ),
    );
  }
}
