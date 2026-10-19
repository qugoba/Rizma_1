import 'package:flutter/painting.dart';

import '../db/enums.dart';

extension ProfileColorPalette on ProfileColor {
  Color get body => switch (this) {
    ProfileColor.teal => const Color(0xFF177A63),
    ProfileColor.coral => const Color(0xFFC7603A),
    ProfileColor.blue => const Color(0xFF2F66C9),
    ProfileColor.purple => const Color(0xFF6A4FB3),
    ProfileColor.amber => const Color(0xFFE9A23B),
  };

  Color get dark => switch (this) {
    ProfileColor.teal => const Color(0xFF0E5C4A),
    ProfileColor.coral => const Color(0xFF8E3A1D),
    ProfileColor.blue => const Color(0xFF1F4A99),
    ProfileColor.purple => const Color(0xFF4B358A),
    ProfileColor.amber => const Color(0xFFA86F12),
  };

  Color get fold => switch (this) {
    ProfileColor.teal => const Color(0xFF7FD7BC),
    ProfileColor.coral => const Color(0xFFF3B9A3),
    ProfileColor.blue => const Color(0xFFA9C2F0),
    ProfileColor.purple => const Color(0xFFC9BCEB),
    ProfileColor.amber => const Color(0xFFFFE2A8),
  };

  Color get avatarBackground => switch (this) {
    ProfileColor.teal => const Color(0xFFD3F3E8),
    ProfileColor.coral => const Color(0xFFFFE3D8),
    ProfileColor.blue => const Color(0xFFDEE8FA),
    ProfileColor.purple => const Color(0xFFECE5FA),
    ProfileColor.amber => const Color(0xFFFFEDCC),
  };
}
