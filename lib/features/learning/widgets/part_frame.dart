import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/strings/ar_learning.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/screen_top_bar.dart';

class PartFrame extends StatelessWidget {
  const PartFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lessonId,
    required this.child,
    this.end,
    this.bottom,
    this.scrollable = true,
  });

  final String title;
  final String subtitle;
  final String lessonId;
  final Widget child;

  final Widget? end;
  final Widget? bottom;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
      child: child,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTopBar(
              title: title,
              subtitle: subtitle,
              end: end,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.lesson(lessonId)),
            ),
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(child: content)
                  : content,
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 24),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class TopTile extends StatelessWidget {
  const TopTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.mute,
    this.iconColor = AppColors.ink,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(child: AppIcon(icon, color: iconColor)),
          ),
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.icon,
    this.fg = AppColors.ink,
    this.bg = AppColors.mute,
  });

  final String label;
  final String? icon;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (icon != null) AppIcon(icon!, size: 16, color: fg),
            Text(label, style: AppTextStyles.chip13.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

class PartUnavailable extends StatelessWidget {
  const PartUnavailable({super.key, this.message = ArLearn.partUnavailable});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.label14,
        ),
      ),
    );
  }
}
