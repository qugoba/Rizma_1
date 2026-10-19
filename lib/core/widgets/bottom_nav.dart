import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../strings/ar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'pressable_scale.dart';
import '../utils/haptics.dart';

enum RizmaTab { home, subjects, progress, profile }

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.current, required this.onSelected});

  final RizmaTab current;
  final ValueChanged<RizmaTab> onSelected;

  static const _items = [
    (tab: RizmaTab.home, label: ArStrings.navHome, asset: AppAssets.navHome),
    (
      tab: RizmaTab.subjects,
      label: ArStrings.navSubjects,
      asset: AppAssets.navBook,
    ),
    (
      tab: RizmaTab.progress,
      label: ArStrings.navProgress,
      asset: AppAssets.navChart,
    ),
    (
      tab: RizmaTab.profile,
      label: ArStrings.navProfile,
      asset: AppAssets.navUser,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in _items)
                Flexible(
                  child: _NavItem(
                    label: item.label,
                    asset: item.asset,
                    selected: item.tab == current,
                    onTap: () {
                      if (item.tab != current) Haptics.tap();
                      onSelected(item.tab);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.teal : AppColors.soft;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.tealTint : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                SvgPicture.asset(
                  asset,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTextStyles.captionBold13.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).pressable();
  }
}
