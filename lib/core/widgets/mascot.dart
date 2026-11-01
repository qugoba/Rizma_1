import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../db/enums.dart';
import '../theme/profile_palette.dart';

enum MascotMood { happy, sleepy, thinking }

class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    required this.size,
    this.color = ProfileColor.teal,
    this.mood = MascotMood.happy,
  });

  final double size;
  final ProfileColor color;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      switch (mood) {
        MascotMood.happy => AppAssets.rizmaMascot,
        MascotMood.sleepy => AppAssets.rizmaMascotSleep,
        MascotMood.thinking => AppAssets.rizmaMascotThink,
      },
      width: size,
      height: size,
      colorMapper: _MascotColorMapper(
        body: color.body,
        dark: color.dark,
        leaf: color.fold,
      ),
    );
  }
}

class _MascotColorMapper extends ColorMapper {
  const _MascotColorMapper({
    required this.body,
    required this.dark,
    required this.leaf,
  });

  static const _originalBody = Color(0xFF177A63);
  static const _originalDark = Color(0xFF0E5C4A);
  static const _originalLeaf = Color(0xFF7FD7BC);

  final Color body;
  final Color dark;
  final Color leaf;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    final opaque = color.withValues(alpha: 1);
    if (opaque == _originalBody) return body.withValues(alpha: color.a);
    if (opaque == _originalDark) return dark.withValues(alpha: color.a);
    if (opaque == _originalLeaf) return leaf.withValues(alpha: color.a);
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is _MascotColorMapper &&
      other.body == body &&
      other.dark == dark &&
      other.leaf == leaf;

  @override
  int get hashCode => Object.hash(body, dark, leaf);
}
