import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../features/home/home_screen.dart';
import '../features/launch/launch_screen.dart';
import '../features/learning/subjects_screen.dart';
import '../features/learning/units_screen.dart';
import '../features/onboarding/create_profile_draft.dart';
import '../features/onboarding/create_profile_step1_screen.dart';
import '../features/onboarding/create_profile_step2_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profiles/active_profile_provider.dart';
import 'page_transitions.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  String? requireActiveProfile(BuildContext context, GoRouterState state) {
    final active = ref.read(activeProfileIdProvider);
    return active.hasValue && active.value == null ? AppRoutes.launch : null;
  }

  Widget soon(GoRouterState state) => const _ComingSoonScreen();
  GoRoute later(String path) => GoRoute(
    path: path,
    pageBuilder: (context, state) =>
        appPage(state: state, child: soon(state)),
  );

  return GoRouter(
    initialLocation: AppRoutes.launch,
    routes: [
      GoRoute(
        path: AppRoutes.launch,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const LaunchScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const WelcomeScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.createStep1,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const CreateProfileStep1Screen()),
      ),
      GoRoute(
        path: AppRoutes.createStep2,
        redirect: (context, state) =>
            ref.read(createProfileDraftProvider) == null
            ? AppRoutes.createStep1
            : null,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const CreateProfileStep2Screen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const HomeScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.subjects,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const SubjectsScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.unitsPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: UnitsScreen(subjectId: state.pathParameters['subjectId']!),
        ),
      ),
      later(AppRoutes.profiles),
      later(AppRoutes.pinPattern),
      later(AppRoutes.account),
      later(AppRoutes.progress),
      later(AppRoutes.kidsGame),
      later(AppRoutes.lessonsPattern),
      later(AppRoutes.lessonPattern),
      later(AppRoutes.partPattern),
      later(AppRoutes.roundPattern),
      later(AppRoutes.quizPattern),
      later(AppRoutes.reviewPattern),
    ],
  );
});

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mute,
      appBar: AppBar(leading: const BackButton()),
      body: Center(
        child: Text('قريبًا', style: AppTextStyles.heading22),
      ),
    );
  }
}
