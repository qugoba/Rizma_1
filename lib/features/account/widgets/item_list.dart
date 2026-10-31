import 'package:flutter/material.dart';

import '../../../core/strings/ar_progress.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/ledge.dart';
import '../../downloads/download_service.dart';
import '../downloads_providers.dart';

class ItemSection extends StatelessWidget {
  const ItemSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.tint,
    required this.children,
  });

  final String title;
  final String icon;
  final Color color;
  final Color tint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LedgeBox(
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                spacing: 10,
                children: [
                  IconTile(
                    iconName: icon,
                    iconColor: color,
                    color: tint,
                    size: 36,
                    iconSize: 18,
                    radius: 10,
                  ),
                  Text(title, style: AppTextStyles.section18),
                ],
              ),
              const SizedBox(height: 6),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class ItemCheckRow extends StatelessWidget {
  const ItemCheckRow({
    super.key,
    required this.item,
    required this.title,
    required this.selected,
    required this.onChanged,
    this.note,
    this.sharing = false,
  });

  final DownloadItem item;
  final String title;
  final String? note;
  final bool selected;
  final ValueChanged<bool> onChanged;

  final bool sharing;

  @override
  Widget build(BuildContext context) {
    final onPhone = !sharing && item.state == DownloadItemState.onPhone;
    final size = Directionality(
      textDirection: TextDirection.ltr,
      child: Text(formatBytes(item.size), style: AppTextStyles.caption13),
    );
    final subtitle = [
      ?note,
      if (onPhone) ArProgress.chooseOnPhone,
      if (!onPhone && item.received > 0)
        ArProgress.progressLine(
          (item.received * 100 / item.size).round().clamp(0, 100),
          null,
          null,
        ),
    ].join(' · ');
    return Semantics(
      label: '$title، ${formatBytes(item.size)}',
      checked: onPhone ? null : selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPhone ? null : () => onChanged(!selected),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              if (onPhone)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.teal,
                  ),
                )
              else
                Checkbox(
                  value: selected,
                  activeColor: AppColors.teal,
                  onChanged: (v) => onChanged(v ?? false),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body15),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: AppTextStyles.caption13),
                  ],
                ),
              ),
              size,
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
