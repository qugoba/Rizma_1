import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../features/account/account_screen.dart';
import '../features/account/student_code_screen.dart';
import '../features/home/home_screen.dart';
import '../features/launch/launch_screen.dart';
import '../features/learning/lesson_hub_screen.dart';
import '../features/learning/lessons_screen.dart';
import '../features/learning/result_screen.dart';
import '../features/learning/review_screen.dart';
import '../features/learning/round_end_screen.dart';
import '../features/learning/round_engine.dart';
import '../features/learning/round_screen.dart';
import '../features/learning/subjects_screen.dart';
import '../features/learning/units_screen.dart';
import '../features/onboarding/create_profile_draft.dart';
import '../features/onboarding/create_profile_step1_screen.dart';
import '../features/onboarding/create_profile_step2_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/profiles/pin_entry_screen.dart';
import '../features/profiles/profile_picker_screen.dart';
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
      GoRoute(
        path: AppRoutes.profiles,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const ProfilePickerScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.pinPattern,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: PinEntryScreen(profileId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.account,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const AccountScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.studentCode,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const StudentCodeScreen()),
      ),
      later(AppRoutes.wardrobe),
      later(AppRoutes.downloads),
      later(AppRoutes.progress),
      later(AppRoutes.kidsGame),
      GoRoute(
        path: AppRoutes.lessonsPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: LessonsScreen(unitId: state.pathParameters['unitId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.lessonPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: LessonHubScreen(lessonId: state.pathParameters['lessonId']!),
        ),
      ),
      later(AppRoutes.partPattern),
      GoRoute(
        path: AppRoutes.roundPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: RoundScreen(
            lessonId: state.pathParameters['lessonId']!,
            mode: RoundMode.practice,
            concept: state.uri.queryParameters['concept'],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.quizPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: RoundScreen(
            lessonId: state.pathParameters['lessonId']!,
            mode: RoundMode.quiz,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.roundEndPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: RoundEndScreen(
            attemptId: int.tryParse(state.pathParameters['attemptId']!) ?? -1,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.resultPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: ResultScreen(
            attemptId: int.tryParse(state.pathParameters['attemptId']!) ?? -1,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.reviewPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: ReviewScreen(lessonId: state.pathParameters['lessonId']!),
        ),
      ),
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
