import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FractionBar extends StatelessWidget {
  const FractionBar({
    super.key,
    required this.parts,
    required this.filled,
    this.color = AppColors.teal,
    this.height = 28,
    this.gap = 5,
    this.outlined = false,
  }) : assert(parts > 0 && filled >= 0 && filled <= parts);

  final int parts;
  final int filled;
  final Color color;
  final double height;
  final double gap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: gap,
      children: [
        for (var i = 0; i < parts; i++)
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: i < filled
                    ? color
                    : (outlined ? AppColors.card : AppColors.mute),
                borderRadius: BorderRadius.circular(height * 0.24),
                border: outlined && i >= filled
                    ? Border.all(color: color, width: 1.5)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
