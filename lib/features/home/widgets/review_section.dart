import 'package:flutter/material.dart';

import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/icon_tile.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../home_state.dart';

class ReviewPlaceholder extends StatelessWidget {
  const ReviewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DashedBorderBox(
      color: AppColors.sky2,
      radius: 18,
      dash: 6,
      gap: 5,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Row(
        spacing: 12,
        children: [
          const IconTile(
            iconName: 'retry',
            iconColor: AppColors.muteText,
            color: AppColors.sky,
            size: 40,
            iconSize: 20,
            radius: 12,
          ),
          Expanded(
            child: Text(
              ArStrings.homeReviewPlaceholder,
              style: AppTextStyles.label14,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key, required this.items, required this.onReview});

  final List<ReviewItem> items;
  final ValueChanged<ReviewItem> onReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(ArStrings.homeNeedsReview, style: AppTextStyles.section18),
        for (final item in items)
          _ReviewCard(item: item, onTap: () => onReview(item)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item, required this.onTap});

  final ReviewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (item.mastery * 100).round();

    return LedgeBox(
      color: AppColors.coralTint,
      radius: 20,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.coral,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const AppIcon('retry', size: 22, color: AppColors.card),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.concept.title, style: AppTextStyles.body16Strong),
                Text(
                  ArStrings.homeMastery(percent),
                  style: AppTextStyles.captionBold13.copyWith(
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
          ),
          LedgeBox(
            color: AppColors.coral,
            radius: 14,
            depth: 3,
            clip: true,
            child: Material(
              color: AppColors.coral,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Text(
                    ArStrings.homeReviewButton,
                    style: AppTextStyles.body15.copyWith(color: AppColors.card),
                  ),
                ),
              ),
            ),
          ).pressable(),
        ],
      ),
    );
  }
}
