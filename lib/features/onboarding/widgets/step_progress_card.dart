import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../core/widgets/tag_chip.dart';

class StepProgressCard extends StatelessWidget {
  const StepProgressCard({super.key, required this.label, required this.value});

  final String label;

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return LedgeBox(
      radius: 20,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label14.copyWith(color: AppColors.ink),
                ),
              ),
              TagChip(
                label: '$percent%',
                icon: percent >= 100 ? 'checkc' : 'bolt',
              ),
            ],
          ),
          ProgressBar(
            value: value,
            trackColor: AppColors.sky2,
            fillColor: AppColors.teal,
            height: 10,
          ),
        ],
      ),
    );
  }
}
