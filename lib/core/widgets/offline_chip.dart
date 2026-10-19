import 'package:flutter/material.dart';

import '../strings/ar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

class OfflineChip extends StatelessWidget {
  const OfflineChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 3, 10, 3),
      decoration: BoxDecoration(
        color: AppColors.tealTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(
            child: Text(
              ArStrings.offlineChip,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption12.copyWith(color: AppColors.teal),
            ),
          ),
          const AppIcon('cloudoff', size: 14, color: AppColors.teal),
        ],
      ),
    );
  }
}
