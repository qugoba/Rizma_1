import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../strings/ar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'ledge.dart';
import 'offline_chip.dart';
import 'pressable_scale.dart';

class BackTile extends StatelessWidget {
  const BackTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: ArStrings.back,
      excludeSemantics: true,
      child: LedgeBox(
        radius: 14,
        depth: 3,
        clip: true,
        child: Material(
          color: AppColors.card,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.back,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.ink,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ).pressable(),
    );
  }
}

class ScreenTopBar extends StatelessWidget {
  const ScreenTopBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.onBack,
    this.end,
    this.showOffline = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? end;

  final bool showOffline;

  @override
  Widget build(BuildContext context) {
    final trailing = end ?? (showOffline ? const OfflineChip() : null);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
      child: Row(
        spacing: 12,
        children: [
          BackTile(onTap: onBack),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.caption13),
                Text(title, style: AppTextStyles.heading22),
              ],
            ),
          ),
          if (trailing != null) Flexible(child: trailing),
        ],
      ),
    );
  }
}
