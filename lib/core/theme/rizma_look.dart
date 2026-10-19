import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class RizmaLook extends ThemeExtension<RizmaLook> {
  const RizmaLook._({
    required this.calm,
    required this.background,
    required this.ledgeDepth,
    required this.cardBorderWidth,
    required this.buttonHeight,
  });

  static const playful = RizmaLook._(
    calm: false,
    background: AppColors.bg,
    ledgeDepth: 4,
    cardBorderWidth: 0,
    buttonHeight: 56,
  );

  static const quiet = RizmaLook._(
    calm: true,
    background: AppColors.cream,
    ledgeDepth: 2,
    cardBorderWidth: 1.5,
    buttonHeight: 52,
  );

  static RizmaLook forGrade(int? grade) =>
      grade != null && grade > lastPlayfulGrade ? quiet : playful;

  static const lastPlayfulGrade = 6;

  final bool calm;

  final Color background;

  final double ledgeDepth;

  final double cardBorderWidth;

  final double buttonHeight;

  Color get cardLedge => calm ? AppColors.line : AppColors.sky2;

  static RizmaLook of(BuildContext context) =>
      Theme.of(context).extension<RizmaLook>() ?? playful;

  @override
  RizmaLook copyWith() => this;

  @override
  RizmaLook lerp(RizmaLook? other, double t) =>
      other == null || t < 0.5 ? this : other;
}
