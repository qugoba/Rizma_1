import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/haptics.dart';

class RizmaSwitch extends StatelessWidget {
  const RizmaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticsLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticsLabel;

  void _toggle() {
    Haptics.tap();
    onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: _toggle,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: value ? AppColors.teal : AppColors.disabled,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 24, height: 24),
            ),
          ),
        ),
      ),
    );
  }
}
