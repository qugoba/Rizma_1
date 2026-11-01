import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/rizma_look.dart';
import 'app_icon.dart';
import 'ledge.dart';
import 'pressable_scale.dart';

enum ButtonKind { filled, outlined, soft, neutral, ink, amber, coral }

class RizmaButton extends StatelessWidget {
  const RizmaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ButtonKind.filled,
    this.icon,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final String? icon;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final look = RizmaLook.of(context);
    final enabled = onPressed != null;
    final (bg, fg) = switch (kind) {
      ButtonKind.filled => (AppColors.teal, AppColors.card),
      ButtonKind.outlined => (AppColors.card, AppColors.teal),
      ButtonKind.soft => (AppColors.tealTint, AppColors.tealDark),
      ButtonKind.neutral => (AppColors.sky, AppColors.ink),
      ButtonKind.ink => (AppColors.ink, AppColors.card),
      ButtonKind.amber => (AppColors.amber, AppColors.amberInk),
      ButtonKind.coral => (AppColors.coral, AppColors.card),
    };
    final edge = kind == ButtonKind.ink ? Colors.black : ledgeEdgeFor(bg, look);
    final border = kind == ButtonKind.outlined
        ? const BorderSide(color: AppColors.line, width: 1.5)
        : BorderSide.none;
    final depth = enabled ? look.ledgeDepth : 0.0;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: look.ledgeDepth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: depth == 0
                ? null
                : [BoxShadow(color: edge, offset: Offset(0, depth))],
          ),
          child: Material(
            color: enabled ? bg : AppColors.disabled,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: enabled ? border : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: height ?? look.buttonHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.button16.copyWith(
                            color: enabled ? fg : AppColors.card,
                          ),
                        ),
                      ),
                      if (icon != null)
                        AppIcon(
                          icon!,
                          size: 20,
                          color: enabled ? fg : AppColors.card,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ).pressable(enabled: enabled),
    );
  }
}
