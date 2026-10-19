import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/rizma_card.dart';
import '../../../core/widgets/rizma_switch.dart';

class SettingsGroupCard extends StatelessWidget {
  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.children,
    this.footnote,
  });

  final String title;
  final List<Widget> children;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return RizmaCard(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(title, style: AppTextStyles.section18),
          ),
          ...children,
          if (footnote != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(footnote!, style: AppTextStyles.caption13),
            ),
        ],
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.label,
    this.onTap,
    this.value,
    this.valueColor = AppColors.teal,
    this.valueLtr = false,
    this.labelColor = AppColors.ink,
    this.trailing,
    this.semanticsLabel,
  });

  final String icon;
  final Color iconColor;
  final Color tint;
  final String label;
  final String? value;
  final Color valueColor;
  final bool valueLtr;
  final Color labelColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;

    final content = Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        spacing: 12,
        children: [
          IconTile(
            iconName: icon,
            iconColor: iconColor,
            color: tint,
            size: 40,
            iconSize: 20,
            radius: 12,
          ),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body15.copyWith(color: labelColor),
            ),
          ),
          if (value != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                value!,
                key: ValueKey(value),
                textDirection: valueLtr ? TextDirection.ltr : null,
                style: AppTextStyles.label14.copyWith(color: valueColor),
              ),
            ),
          if (trailing != null)
            trailing!
          else if (tappable)
            SvgPicture.asset(AppAssets.fwdRow, width: 18, height: 18),
        ],
      ),
    );

    if (!tappable) return content;

    return Semantics(
      button: true,
      label: semanticsLabel ?? (value == null ? label : '$label، $value'),
      excludeSemantics: true,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final Color iconColor;
  final Color tint;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      icon: icon,
      iconColor: iconColor,
      tint: tint,
      label: label,
      trailing: RizmaSwitch(
        value: value,
        onChanged: onChanged,
        semanticsLabel: label,
      ),
    );
  }
}

class SoonSettingRow extends StatelessWidget {
  const SoonSettingRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.label,
  });

  final String icon;
  final Color iconColor;
  final Color tint;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: false,
      label: '$label، ${ArStrings.accountSoon}',
      excludeSemantics: true,
      child: Opacity(
        opacity: 0.55,
        child: IgnorePointer(
          child: SettingRow(
            icon: icon,
            iconColor: iconColor,
            tint: tint,
            label: label,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                const _SoonChip(),
                RizmaSwitch(
                  value: false,
                  onChanged: (_) {},
                  semanticsLabel: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoonChip extends StatelessWidget {
  const _SoonChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.amberTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          ArStrings.accountSoon,
          style: AppTextStyles.chip13.copyWith(color: AppColors.amberDark),
        ),
      ),
    );
  }
}
