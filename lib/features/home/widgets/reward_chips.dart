import 'package:flutter/material.dart';

import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/ledge.dart';

class RewardChips extends StatelessWidget {
  const RewardChips({super.key, required this.stars, required this.streak});

  final int stars;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: _Tile(
              icon: 'starf',
              label: ArStrings.stars(stars),
              tint: AppColors.amberTint,
              solid: AppColors.amber,
              text: AppColors.amberInk,
            ),
          ),
          if (streak > 0)
            Expanded(
              child: _Tile(
                icon: 'flame',
                label: ArStrings.streakDays(streak),
                tint: AppColors.coralTint,
                solid: AppColors.coral,
                text: AppColors.coralDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.tint,
    required this.solid,
    required this.text,
  });

  final String icon;
  final String label;
  final Color tint;
  final Color solid;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      color: tint,
      radius: 18,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: solid,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 20, color: AppColors.card),
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: AppTextStyles.body15.copyWith(color: text),
            ),
          ),
        ],
      ),
    );
  }
}
