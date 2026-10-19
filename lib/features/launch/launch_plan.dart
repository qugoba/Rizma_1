import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../profiles/profile_providers.dart';

enum LaunchTarget {
  welcome,

  home,

  picker,
}

class LaunchPlan {
  const LaunchPlan(this.target, {this.profileId});

  final LaunchTarget target;

  final String? profileId;
}

LaunchPlan decideLaunchPlan(List<Profile> profiles) {
  if (profiles.isEmpty) return const LaunchPlan(LaunchTarget.welcome);
  if (profiles.length == 1 && profiles.single.pinHash == null) {
    return LaunchPlan(LaunchTarget.home, profileId: profiles.single.id);
  }
  return const LaunchPlan(LaunchTarget.picker);
}

final launchPlanProvider = FutureProvider.autoDispose<LaunchPlan>((ref) async {
  final profiles = await ref.read(profileRepositoryProvider).getAll();
  return decideLaunchPlan(profiles);
});
