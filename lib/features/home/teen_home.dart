import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar.dart';
import '../../core/strings/ar_kids.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/progress_ring.dart';
import '../account/downloads_providers.dart';
import '../catalog/catalog_providers.dart';
import '../learning/widgets/learn_cards.dart';
import 'exam_prep.dart';
import 'home_providers.dart';
import 'home_state.dart';

class TeenHomeBody extends ConsumerWidget {
  const TeenHomeBody({super.key, required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = state.profile;
    final catalog = ref.watch(catalogProvider).value;
    final installed = ref.watch(installedLessonsProvider).value;
    final attempts = ref.watch(attemptsProvider(profile.id)).value;
    final mastery = ref.watch(masteryProvider(profile.id)).value;
    if (catalog == null ||
        installed == null ||
        attempts == null ||
        mastery == null) {
      return const SizedBox.shrink();
    }
    final prep = ExamPrep.derive(
      catalog: catalog,
      installed: installed,
      attempts: attempts,
      mastery: mastery,
    );
    final mock = prep.mockLesson;
    final weakest = prep.weak.isEmpty ? null : prep.weak.first;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ArKids.examKicker(
                        ArStrings.gradeName(
                          profile.grade,
                        ).replaceFirst('الصف ', ''),
                      ),
                      style: AppTextStyles.caption13,
                    ),
                    Text(ArKids.examTitle, style: AppTextStyles.heading22),
                  ],
                ),
              ),
              if (state.streak > 0)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.coralTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        const AppIcon(
                          'flame',
                          size: 16,
                          color: AppColors.coral,
                        ),
                        Text(
                          ArStrings.streakDays(state.streak),
                          style: AppTextStyles.chip13.copyWith(
                            color: AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ).fadeIn(0),
          _ReadinessCard(prep: prep).fadeIn(1),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                _Tile(
                  icon: 'list',
                  fg: AppColors.blue,
                  tint: AppColors.blueTint,
                  title: ArKids.tileSummaries,
                  note: ArKids.tileSummariesNote(prep.summaryLessons),
                  onTap: () => context.go(AppRoutes.subjects),
                ),
                _Tile(
                  icon: 'trophy',
                  fg: AppColors.teal,
                  tint: AppColors.tealTint,
                  title: ArKids.tileMock,
                  note: ArKids.tileMockNote(mock?.quizCount ?? 0),
                  onTap: mock == null
                      ? null
                      : () => context.push(AppRoutes.quiz(mock.lesson.id)),
                ),
                _Tile(
                  icon: 'target',
                  fg: AppColors.purple,
                  tint: AppColors.purpleTint,
                  title: ArKids.tileBank,
                  note: ArKids.tileBankNote,
                  onTap: weakest == null
                      ? null
                      : () => context.push(
                          '${AppRoutes.round(weakest.lesson.id)}?concept=${weakest.concept.id}',
                        ),
                ),
              ],
            ),
          ).fadeIn(2),
          _WeakCard(prep: prep).fadeIn(3),
          _PlanCard(prep: prep).fadeIn(4),
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.prep});

  final ExamPrep prep;

  @override
  Widget build(BuildContext context) {
    final r = prep.readiness;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ArKids.readiness,
                    style: AppTextStyles.section18.copyWith(
                      color: AppColors.card,
                    ),
                  ),
                  Text(
                    r == null
                        ? ArKids.readinessNone
                        : ArKids.readinessBased(prep.basedOn),
                    style: AppTextStyles.caption13.copyWith(
                      color: AppColors.onTeal,
                    ),
                  ),
                ],
              ),
            ),
            ProgressRing(
              value: (r ?? 0) / 100,
              size: 88,
              stroke: 10,
              trackColor: const Color(0xFF2A4A4C),
              fillColor: const Color(0xFF7ED3B2),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${r ?? 0}%',
                  style: AppTextStyles.body16Strong.copyWith(
                    color: AppColors.card,
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

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.fg,
    required this.tint,
    required this.title,
    required this.note,
    required this.onTap,
  });

  final String icon;
  final Color fg;
  final Color tint;
  final String title;
  final String note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: LearnRowCard(
          onTap: onTap,
          semanticsLabel: '$title، $note',
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: AppIcon(icon, size: 22, color: fg)),
              ),
              Text(title, style: AppTextStyles.body15),
              Text(note, style: AppTextStyles.caption13),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeakCard extends StatelessWidget {
  const _WeakCard({required this.prep});

  final ExamPrep prep;

  static Color _colorOf(double m) => m < 0.6
      ? AppColors.amberDark
      : (m < 0.8 ? AppColors.blue : AppColors.teal);

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 24,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(ArKids.weakTitle, style: AppTextStyles.section18),
            if (prep.weak.isEmpty)
              Text(ArKids.weakEmpty, style: AppTextStyles.label14)
            else
              for (final w in prep.weak)
                Row(
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        w.concept.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body15,
                      ),
                    ),
                    Expanded(
                      child: ProgressBar(
                        value: w.mastery.clamp(0.0, 1.0),
                        trackColor: AppColors.mute,
                        fillColor: _colorOf(w.mastery),
                        height: 10,
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(w.mastery * 100).round()}%',
                        textAlign: TextAlign.end,
                        style: AppTextStyles.captionBold13.copyWith(
                          color: _colorOf(w.mastery),
                        ),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.prep});

  final ExamPrep prep;

  static const _days = [
    ArKids.planToday,
    ArKids.planTomorrow,
    ArKids.planAfter,
  ];

  @override
  Widget build(BuildContext context) {
    String task(PlanItem p) {
      switch (p.kind) {
        case PlanKind.review:
          final title = prep.weak.isEmpty
              ? null
              : prep.weak.first.concept.title;
          return ArKids.planReview(
            title ?? prep.mockLesson?.lesson.title ?? '',
          );
        case PlanKind.practice:
          return ArKids.planPractice(p.count);
        case PlanKind.quiz:
          return ArKids.planQuiz;
        case PlanKind.start:
          return ArKids.planStart;
      }
    }

    return LedgeBox(
      radius: 24,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(ArKids.planTitle, style: AppTextStyles.section18),
            for (final (i, p) in prep.plan.indexed)
              InkWell(
                onTap: () => context.push(p.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    spacing: 12,
                    children: [
                      if (p.kind != PlanKind.start)
                        SizedBox(
                          width: 56,
                          child: Text(
                            _days[i % _days.length],
                            style: AppTextStyles.caption13,
                          ),
                        ),
                      Expanded(
                        child: Text(task(p), style: AppTextStyles.body15),
                      ),
                      const AppIcon('clock', size: 20, color: AppColors.soft),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
