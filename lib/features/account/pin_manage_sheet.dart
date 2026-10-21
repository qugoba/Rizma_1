import 'package:flutter/material.dart';

import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/icon_tile.dart';

enum PinManageAction { change, disable }

Future<PinManageAction?> showPinManageSheet(BuildContext context) {
  return showModalBottomSheet<PinManageAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(ArStrings.pinManageTitle, style: AppTextStyles.section18),
            _ActionRow(
              icon: Icons.edit_outlined,
              iconColor: AppColors.teal,
              tint: AppColors.tealTint,
              label: ArStrings.pinChange,
              onTap: () => Navigator.of(context).pop(PinManageAction.change),
            ),
            _ActionRow(
              icon: Icons.lock_open_outlined,
              iconColor: AppColors.coral,
              tint: AppColors.coralTint,
              label: ArStrings.pinDisable,
              onTap: () => Navigator.of(context).pop(PinManageAction.disable),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              IconTile(
                iconData: icon,
                iconColor: iconColor,
                color: tint,
                size: 40,
                iconSize: 20,
                radius: 12,
              ),
              Expanded(child: Text(label, style: AppTextStyles.body15)),
            ],
          ),
        ),
      ),
    );
  }
}
