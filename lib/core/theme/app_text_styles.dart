import 'package:flutter/painting.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const fontFamily = 'Cairo';

  static TextStyle _cairo(
    double size,
    FontWeight weight,
    double height,
    Color color,
  ) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  static final wordmark40 = _cairo(40, FontWeight.w800, 1.3, AppColors.light);
  static final tagline18 = _cairo(18, FontWeight.w700, 1.6, AppColors.light);
  static final title26 = _cairo(26, FontWeight.w800, 1.35, AppColors.ink);
  static final heading22 = _cairo(22, FontWeight.w800, 1.35, AppColors.ink);
  static final cardTitle20 = _cairo(20, FontWeight.w800, 1.4, AppColors.card);
  static final section18 = _cairo(18, FontWeight.w800, 1.4, AppColors.ink);

  static final body16Strong = _cairo(16, FontWeight.w800, 1.5, AppColors.ink);
  static final body15 = _cairo(15, FontWeight.w700, 1.5, AppColors.ink);
  static final label14 = _cairo(14, FontWeight.w700, 1.45, AppColors.soft);
  static final caption13 = _cairo(13, FontWeight.w600, 1.45, AppColors.soft);
  static final captionBold13 = _cairo(
    13,
    FontWeight.w700,
    1.45,
    AppColors.soft,
  );
  static final percent12 = _cairo(12, FontWeight.w800, 1.4, AppColors.ink);

  static final display30 = _cairo(30, FontWeight.w800, 1.35, AppColors.ink);

  static final number30 = _cairo(30, FontWeight.w800, 1.3, AppColors.ink);

  static final big44 = _cairo(44, FontWeight.w800, 1.25, AppColors.ink);

  static final h3_17 = _cairo(17, FontWeight.w700, 1.4, AppColors.ink);

  static final bodyL16 = _cairo(16, FontWeight.w600, 1.5, AppColors.ink);

  static final caption12 = _cairo(
    12,
    FontWeight.w700,
    1.45,
    AppColors.muteText,
  );

  static final button16 = _cairo(17, FontWeight.w800, 1.4, AppColors.card);
  static final input17 = _cairo(17, FontWeight.w700, 1.5, AppColors.ink);
  static final gradeNumber24 = _cairo(24, FontWeight.w800, 1.3, AppColors.ink);
  static final chip13 = _cairo(13, FontWeight.w700, 1.5, AppColors.ink);
}
