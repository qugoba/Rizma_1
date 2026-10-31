import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/account_screen.dart';
import '../features/account/choose_downloads_screen.dart';
import '../features/account/downloads_screen.dart';
import '../features/account/student_code_screen.dart';
import '../features/sharing/nearby_send_screen.dart';
import '../features/sharing/receive_screen.dart';
import '../features/sharing/send_wifi_screen.dart';
import '../features/sharing/share_screen.dart';
import '../features/learning/attachment_screen.dart';
import '../features/home/home_screen.dart';
import '../features/kids/kids_game_screen.dart';
import '../features/launch/launch_screen.dart';
import '../features/learning/lesson_hub_screen.dart';
import '../features/learning/lesson_part_screen.dart';
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
import '../features/profiles/active_profile_provider.dart';
import '../features/profiles/pin_entry_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/wardrobe/wardrobe_screen.dart';
import '../features/profiles/profile_picker_screen.dart';
import '../features/sync/restore_screen.dart';
import 'page_transitions.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  String? requireActiveProfile(BuildContext context, GoRouterState state) {
    final active = ref.read(activeProfileIdProvider);
    return active.hasValue && active.value == null ? AppRoutes.launch : null;
  }

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
        path: AppRoutes.profiles,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const ProfilePickerScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.restore,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const RestoreScreen()),
      ),
      GoRoute(
        path: AppRoutes.pinPattern,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: PinEntryScreen(profileId: state.pathParameters['id']!),
        ),
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
        path: AppRoutes.account,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const AccountScreen(),
          motion: PageMotion.tab,
        ),
      ),
      GoRoute(
        path: AppRoutes.kidsGame,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const KidsGameScreen()),
      ),
      GoRoute(
        path: AppRoutes.wardrobe,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const WardrobeScreen()),
      ),
      GoRoute(
        path: AppRoutes.studentCode,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const StudentCodeScreen()),
      ),
      GoRoute(
        path: AppRoutes.downloads,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const DownloadsScreen()),
      ),
      GoRoute(
        path: AppRoutes.downloadsChoose,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const ChooseDownloadsScreen()),
      ),
      GoRoute(
        path: AppRoutes.share,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const ShareScreen()),
      ),
      GoRoute(
        path: AppRoutes.shareWifi,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const SendWifiScreen()),
      ),
      GoRoute(
        path: AppRoutes.shareNearby,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const NearbySendScreen()),
      ),
      GoRoute(
        path: AppRoutes.receive,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) =>
            appPage(state: state, child: const ReceiveScreen()),
      ),
      GoRoute(
        path: AppRoutes.progress,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: const ProgressScreen(),
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
          child: RoundEndScreen(attemptId: state.pathParameters['attemptId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.resultPattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: ResultScreen(attemptId: state.pathParameters['attemptId']!),
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
      GoRoute(
        path: AppRoutes.lessonFilePattern,
        redirect: requireActiveProfile,
        pageBuilder: (context, state) => appPage(
          state: state,
          child: AttachmentScreen(
            lessonId: state.pathParameters['lessonId']!,
            index: int.tryParse(state.pathParameters['index']!) ?? -1,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.partPattern,
        redirect: (context, state) {
          final redirect = requireActiveProfile(context, state);
          if (redirect != null) return redirect;
          final id = state.pathParameters['lessonId']!;
          return lessonPartScreen(id, state.pathParameters['part']!) == null
              ? AppRoutes.lesson(id)
              : null;
        },
        pageBuilder: (context, state) => appPage(
          state: state,
          child: lessonPartScreen(
            state.pathParameters['lessonId']!,
            state.pathParameters['part']!,
          )!,
        ),
      ),
    ],
  );
});
