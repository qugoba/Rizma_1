import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/tab_navigation.dart';
import '../../core/db/database_provider.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/rizma_look.dart';
import '../../core/widgets/bottom_nav.dart';
import '../catalog/catalog_providers.dart';
import 'dev_tools_sheet.dart';
import 'home_providers.dart';
import 'kids_home.dart';
import 'teen_home.dart';
import 'home_state.dart';
import 'widgets/featured_lesson_card.dart';
import 'widgets/first_steps_card.dart';
import 'widgets/home_greeting.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/review_section.dart';
import 'widgets/reward_chips.dart';
import 'widgets/subjects_section.dart';
import '../../core/widgets/fade_slide_in.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openDevTools(BuildContext context, WidgetRef ref, HomeState s) {
    return showDevToolsSheet(
      context,
      db: ref.read(appDatabaseProvider),
      profile: s.profile,
      catalog: ref.read(catalogProvider).requireValue,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeStateProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: state.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Center(
            child: Text(ArStrings.homeLoadFailed, style: AppTextStyles.body15),
          ),
          data: (s) => s == null
              ? const SizedBox.shrink()
              : s.profile.grade <= 4
              ? KidsHomeBody(
                  state: s,
                  subjects: ref
                      .watch(catalogProvider)
                      .requireValue
                      .subjects
                      .take(4)
                      .toList(),
                  onGame: () => context.push(AppRoutes.kidsGame),
                  onSubject: (id) => context.push(AppRoutes.units(id)),
                )
              : s.profile.grade >= 9
              ? TeenHomeBody(state: s)
              : _HomeBody(
                  state: s,
                  onLesson: (id) => context.push(AppRoutes.lesson(id)),
                  onSubject: (id) => context.push(AppRoutes.units(id)),
                  onShowAll: () => context.go(AppRoutes.subjects),
                  onReview: (lessonId) =>
                      context.push(AppRoutes.review(lessonId)),
                  onAvatar: () => context.go(AppRoutes.account),
                  onAvatarLongPress: kDebugMode
                      ? () => _openDevTools(context, ref, s)
                      : null,
                ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: RizmaTab.home,
        onSelected: (tab) => onTabSelected(context, RizmaTab.home, tab),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.state,
    required this.onLesson,
    required this.onSubject,
    required this.onShowAll,
    required this.onReview,
    required this.onAvatar,
    required this.onAvatarLongPress,
  });

  final HomeState state;
  final ValueChanged<String> onLesson;
  final ValueChanged<String> onSubject;
  final VoidCallback onShowAll;
  final ValueChanged<String> onReview;
  final VoidCallback onAvatar;
  final VoidCallback? onAvatarLongPress;

  @override
  Widget build(BuildContext context) {
    final featured = state.featured;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          HomeTopBar(
            profile: state.profile,
            onAvatar: onAvatar,
            onAvatarLongPress: onAvatarLongPress,
          ),
          HomeGreeting(state: state).fadeIn(0),
          if (state.hasActivity && !RizmaLook.of(context).calm)
            RewardChips(stars: state.stars, streak: state.streak).fadeIn(1),
          if (featured != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: FeaturedLessonCard(
                lesson: featured,
                firstDay: state.isFirstDay,
                mascotColor: state.profile.color,
                onPressed: () => onLesson(featured.lesson.id),
              ),
            ).fadeIn(2),
          if (state.isFirstDay)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: FirstStepsCard(steps: state.firstSteps),
            ).fadeIn(3),
          if (state.showReviewPlaceholder)
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: ReviewPlaceholder(),
            ).fadeIn(4),
          if (state.showReviewSection)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: ReviewSection(
                items: state.review,
                onReview: (item) => onReview(item.lesson.id),
              ),
            ).fadeIn(4),
          SubjectsHeader(onShowAll: onShowAll).fadeIn(5),
          SubjectsCarousel(
            subjects: state.subjects,
            onOpen: (s) => onSubject(s.subject.id),
          ).fadeIn(6),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
