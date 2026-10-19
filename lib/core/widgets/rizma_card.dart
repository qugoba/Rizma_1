import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'ledge.dart';

class RizmaCard extends StatelessWidget {
  const RizmaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(color: color, padding: padding, child: child);
  }
}
