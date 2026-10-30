import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/tab_navigation.dart';
import '../../core/db/enums.dart';
import '../../core/strings/ar.dart';
import '../../core/strings/ar_progress.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/offline_chip.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/tag_chip.dart';
import '../learning/widgets/learn_cards.dart';
import '../profiles/active_profile_provider.dart';
import 'progress_providers.dart';
import 'progress_state.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(progressStateProvider);
    final profile = ref.watch(activeProfileProvider).value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: s == null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        16,
                        20,
                        4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ArProgress.title,
                              style: AppTextStyles.heading22,
                            ),
                          ),
                          const OfflineChip(),
                        ],
                      ),
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
                          if (profile != null)
                            _ProfileCard(
                              name: profile.name,
                              color: profile.color,
                              grade: s.grade,
                              streak: s.streak,
                            ).fadeIn(0),
                          _OverallCard(s).fadeIn(0),
                          _StarsHero(s.stars).fadeIn(1),
                          _StatsGrid(s).fadeIn(1),
                          _WeekCard(s).fadeIn(2),
                          _SubjectsCard(s).fadeIn(3),
                          _ReviewCard(
                            s,
                            onOpen: (lessonId) =>
                                context.push(AppRoutes.review(lessonId)),
                          ).fadeIn(4),
                          _BadgesCard(s).fadeIn(5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNav(
        current: RizmaTab.progress,
        onSelected: (tab) => onTabSelected(context, RizmaTab.progress, tab),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(18)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(radius: 24, padding: padding, child: child);
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.color,
    required this.grade,
    required this.streak,
  });

  final String name;
  final ProfileColor color;
  final int grade;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 14,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(name, style: AppTextStyles.title26),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (streak > 0)
                    TagChip(
                      label: ArProgress.streakDays(streak),
                      icon: 'flame',
                      background: AppColors.coralTint,
                      foreground: AppColors.coral,
                    ),
                  TagChip(
                    label: ArStrings.gradeName(grade),
                    icon: 'book',
                    background: AppColors.purpleTint,
                    foreground: AppColors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sky2, width: 3),
          ),
          alignment: Alignment.center,
          child: Mascot(size: 68, color: color),
        ),
      ],
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard(this.s);

  final ProgressState s;

  @override
  Widget build(BuildContext context) {
    final percent = (s.overall * 100).round();
    return _Card(
      child: Row(
        spacing: 16,
        children: [
          ProgressRing(
            value: s.overall,
            size: 112,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text('$percent%', style: AppTextStyles.heading22),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                const Text(
                  ArProgress.overall,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  s.hasActivity
                      ? ArProgress.overallKeepGoing
                      : ArProgress.overallNoActivity,
                  style: AppTextStyles.label14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid(this.s);

  final ProgressState s;

  @override
  Widget build(BuildContext context) {
    Widget stat(String icon, int value, String label, Color color) {
      return Expanded(
        child: _Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(icon, size: 22, color: color),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: AppTextStyles.title26.copyWith(
                  color: color,
                  fontSize: 30,
                ),
              ),
              Text(label, style: AppTextStyles.caption13),
            ],
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          stat(
            'checkc',
            s.completedLessons,
            ArProgress.statLessons,
            AppColors.teal,
          ),
          stat('retry', s.reviewCount, ArProgress.statReview, AppColors.coral),
          stat('trophy', s.quizzes, ArProgress.statQuizzes, AppColors.blue),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard(this.s);

  final ProgressState s;

  @override
  Widget build(BuildContext context) {
    final max = s.week.fold<int>(1, (m, v) => v > m ? v : m);
    const chartHeight = 120.0;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ArProgress.weekTitle,
                  style: AppTextStyles.section18,
                ),
              ),
              Text(
                ArProgress.weekTotal(s.weekTotal),
                style: AppTextStyles.captionBold13.copyWith(
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                Semantics(
                  label: '${ArProgress.dayLetters[i]} ${s.week[i]}',
                  excludeSemantics: true,
                  child: SizedBox(
                    width: 28,
                    child: Column(
                      spacing: 6,
                      children: [
                        SizedBox(
                          height: chartHeight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              width: 28,
                              height: s.week[i] == 0
                                  ? 6
                                  : 14 + (chartHeight - 14) * s.week[i] / max,
                              decoration: BoxDecoration(
                                color: s.week[i] == 0
                                    ? AppColors.track
                                    : AppColors.teal,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          ArProgress.dayLetters[i],
                          style: AppTextStyles.caption13,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard(this.s);

  final ProgressState s;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(ArProgress.subjectsTitle, style: AppTextStyles.section18),
          for (final b in s.subjects)
            Row(
              spacing: 10,
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    b.subject.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body15,
                  ),
                ),
                Expanded(
                  child: ProgressBar(
                    value: b.fraction.clamp(0.0, 1.0),
                    trackColor: AppColors.mute,
                    fillColor: b.subject.color.fg,
                    height: 10,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    b.hasContent
                        ? '${(b.fraction * 100).round()}%'
                        : ArProgress.subjectSoon,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.captionBold13.copyWith(
                      color: b.hasContent
                          ? b.subject.color.fg
                          : AppColors.placeholder,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(this.s, {required this.onOpen});

  final ProgressState s;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(ArProgress.reviewTitle, style: AppTextStyles.section18),
          if (s.review.isEmpty)
            Text(ArProgress.reviewEmpty, style: AppTextStyles.label14)
          else
            for (final r in s.review)
              LearnRowCard(
                onTap: () => onOpen(r.lesson.id),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                semanticsLabel: r.concept.title,
                child: Row(
                  spacing: 10,
                  children: [
                    const AppIcon('warn', size: 22, color: AppColors.amberDark),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.concept.title, style: AppTextStyles.body15),
                          Text(r.lesson.title, style: AppTextStyles.caption13),
                        ],
                      ),
                    ),
                    const AppIcon(
                      'back',
                      size: 18,
                      color: AppColors.placeholder,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  const _BadgesCard(this.s);

  final ProgressState s;

  static const _meta = {
    BadgeKind.firstLesson: ('book', ArProgress.badgeFirstLesson),
    BadgeKind.streak: ('flame', ArProgress.badgeStreak),
    BadgeKind.stars: ('star', ArProgress.badgeStars),
    BadgeKind.listener: ('volume', ArProgress.badgeListener),
    BadgeKind.quizAce: ('trophy', ArProgress.badgeQuizAce),
  };

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(ArProgress.badgesTitle, style: AppTextStyles.section18),
          Wrap(
            spacing: 12,
            runSpacing: 14,
            children: [
              for (final b in s.badges)
                SizedBox(
                  width: 72,
                  child: Semantics(
                    label: _meta[b.kind]!.$2,
                    value: b.earned ? '✓' : null,
                    excludeSemantics: true,
                    child: Column(
                      spacing: 6,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: b.earned
                                ? AppColors.amberTint
                                : AppColors.mute,
                          ),
                          child: Center(
                            child: AppIcon(
                              _meta[b.kind]!.$1,
                              size: 26,
                              color: b.earned
                                  ? AppColors.amberDark
                                  : AppColors.placeholder,
                            ),
                          ),
                        ),
                        Text(
                          _meta[b.kind]!.$2,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.captionBold13.copyWith(
                            color: b.earned
                                ? AppColors.ink
                                : AppColors.placeholder,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarsHero extends StatelessWidget {
  const _StarsHero(this.stars);

  final int stars;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      color: AppColors.amber,
      radius: 24,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const AppIcon('starf', size: 30, color: AppColors.star),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArProgress.starsTotalTitle,
                  style: AppTextStyles.label14.copyWith(
                    color: AppColors.amberInk,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: 6,
                  children: [
                    Text(
                      '$stars',
                      style: AppTextStyles.number30.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      ArProgress.statStars,
                      style: AppTextStyles.section18.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
