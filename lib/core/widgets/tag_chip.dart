import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.tealTint,
    this.foreground = AppColors.teal,
    this.outline = false,
  });

  final String label;
  final String? icon;
  final Color background;
  final Color foreground;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 3, 10, 3),
      decoration: BoxDecoration(
        color: outline ? AppColors.card : background,
        borderRadius: BorderRadius.circular(999),
        border: outline ? Border.all(color: foreground, width: 1.2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption12.copyWith(color: foreground),
            ),
          ),
          if (icon != null) AppIcon(icon!, size: 14, color: foreground),
        ],
      ),
    );
  }
}
