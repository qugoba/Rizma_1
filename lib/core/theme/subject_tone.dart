import 'package:flutter/painting.dart';

import 'app_colors.dart';

enum SubjectTone {
  teal(AppColors.teal, AppColors.tealTint),
  coral(AppColors.coral, AppColors.coralTint),
  blue(AppColors.blue, AppColors.blueTint),
  purple(AppColors.purple, AppColors.purpleTint),
  amber(AppColors.amberDark, AppColors.amberTint),
  slate(AppColors.slate, AppColors.slateTint);

  const SubjectTone(this.fg, this.tint);

  final Color fg;
  final Color tint;
}
