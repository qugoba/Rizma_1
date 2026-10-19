import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ledge.dart';
import '../../../core/widgets/pressable_scale.dart';

class LearnRowCard extends StatelessWidget {
  const LearnRowCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final card = LedgeBox(
      radius: 20,
      clip: true,
      edge: selected ? AppColors.tealDark : null,
      border: selected ? Border.all(color: AppColors.teal, width: 2) : null,
      child: Material(
        color: AppColors.card,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    final result = Semantics(
      container: true,
      button: onTap != null,
      label: semanticsLabel,
      child: card,
    );
    return onTap == null ? result : result.pressable();
  }
}
