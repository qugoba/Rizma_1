import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'rizma_look.dart';

abstract final class AppTheme {
  static ThemeData get light => forLook(RizmaLook.playful);

  static ThemeData forLook(RizmaLook look) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.teal,
          onPrimary: AppColors.card,
          surface: look.background,
          onSurface: AppColors.ink,
          error: AppColors.red,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: look.background,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: look.background),
      fontFamily: AppTextStyles.fontFamily,
      extensions: [look],
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.label14.copyWith(color: AppColors.card),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
