import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/rizma_look.dart';

Color ledgeEdgeFor(Color fill, RizmaLook look) {
  if (fill == AppColors.card) return look.cardLedge;
  if (fill == AppColors.teal) return AppColors.tealDark;
  if (fill == AppColors.amber) return AppColors.amberDark;
  if (fill == AppColors.coral) return AppColors.coralDark;
  if (fill == AppColors.blue) return AppColors.blueDark;
  if (fill == AppColors.purple) return AppColors.purpleDark;
  if (fill == AppColors.tealTint) return AppColors.mint;
  if (fill == AppColors.amberTint) return AppColors.amberLine;
  if (fill == AppColors.coralTint) return const Color(0xFFF6C3AF);
  if (fill == AppColors.sky) return AppColors.sky2;
  final hsl = HSLColor.fromColor(fill);
  return hsl.withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0)).toColor();
}

class LedgeBox extends StatelessWidget {
  const LedgeBox({
    super.key,
    required this.child,
    this.color = AppColors.card,
    this.edge,
    this.radius = 20,
    this.depth,
    this.border,
    this.padding,
    this.clip = false,
  });

  final Widget child;
  final Color color;
  final Color? edge;
  final double radius;
  final double? depth;

  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  final bool clip;

  @override
  Widget build(BuildContext context) {
    final look = RizmaLook.of(context);
    final d = depth ?? look.ledgeDepth;
    final shape = BorderRadius.circular(radius);
    final resolvedBorder =
        border ??
        (color == AppColors.card && look.cardBorderWidth > 0
            ? Border.all(color: AppColors.line, width: look.cardBorderWidth)
            : null);
    Widget inner = padding == null
        ? child
        : Padding(padding: padding!, child: child);
    if (clip) inner = ClipRRect(borderRadius: shape, child: inner);

    if (resolvedBorder != null) {
      inner = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(borderRadius: shape, border: resolvedBorder),
        child: inner,
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: d),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: shape,
          boxShadow: d <= 0
              ? null
              : [
                  BoxShadow(
                    color: edge ?? ledgeEdgeFor(color, look),
                    offset: Offset(0, d),
                  ),
                ],
        ),
        child: inner,
      ),
    );
  }
}
