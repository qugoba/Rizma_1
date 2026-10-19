import 'package:flutter/material.dart';

import '../../../core/db/app_database.dart';
import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/mascot.dart';
import '../../../core/widgets/offline_chip.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.profile,
    required this.onAvatar,
    this.onAvatarLongPress,
  });

  final Profile profile;
  final VoidCallback onAvatar;
  final VoidCallback? onAvatarLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: Row(
        spacing: 8,
        children: [
          Mascot(size: 34, color: profile.color),
          Text(
            ArStrings.appName,
            style: AppTextStyles.heading22.copyWith(color: AppColors.teal),
          ),
          const Spacer(),
          const Flexible(child: OfflineChip()),
          Semantics(
            button: true,
            label: ArStrings.navProfile,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: onAvatar,
              onLongPress: onAvatarLongPress,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const AppIcon('user', size: 20, color: AppColors.card),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
