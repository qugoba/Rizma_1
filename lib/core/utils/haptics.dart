import 'package:flutter/services.dart';

abstract final class Haptics {
  static void tap() => HapticFeedback.selectionClick();

  static void heavy() => HapticFeedback.mediumImpact();
}
