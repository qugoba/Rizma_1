import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/widgets/mascot.dart';
import '../profiles/active_profile_provider.dart';
import 'launch_plan.dart';
import '../../core/widgets/fade_slide_in.dart';

class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final LaunchPlan plan;
    try {
      plan = await ref.read(launchPlanProvider.future);
    } catch (_) {
      if (mounted) context.go(AppRoutes.welcome);
      return;
    }
    if (!mounted) return;

    switch (plan.target) {
      case LaunchTarget.welcome:
        context.go(AppRoutes.welcome);
      case LaunchTarget.picker:
        context.go(AppRoutes.profiles);
      case LaunchTarget.home:
        await ref
            .read(activeProfileIdProvider.notifier)
            .select(plan.profileId!);
        if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const Mascot(size: 96).fadeIn()));
  }
}
