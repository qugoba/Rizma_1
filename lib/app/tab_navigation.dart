import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/bottom_nav.dart';
import 'routes.dart';

void onTabSelected(BuildContext context, RizmaTab current, RizmaTab target) {
  if (target == current) return;
  switch (target) {
    case RizmaTab.home:
      context.go(AppRoutes.home);
    case RizmaTab.profile:
      context.go(AppRoutes.account);
    case RizmaTab.subjects:
      context.go(AppRoutes.subjects);
    case RizmaTab.progress:
      context.go(AppRoutes.progress);
  }
}
