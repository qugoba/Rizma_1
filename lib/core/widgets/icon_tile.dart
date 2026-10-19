import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_icon.dart';

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    this.asset,
    this.iconData,
    this.iconName,
    this.iconColor,
    required this.color,
    this.size = 48,
    this.iconSize = 24,
    this.radius = 14,
  }) : assert(
         (asset != null ? 1 : 0) +
                 (iconData != null ? 1 : 0) +
                 (iconName != null ? 1 : 0) ==
             1,
         'مرّر واحدًا فقط من asset أو iconData أو iconName',
       );

  final String? asset;
  final IconData? iconData;

  final String? iconName;
  final Color? iconColor;
  final Color color;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: switch ((asset, iconName)) {
        (final a?, _) => SvgPicture.asset(a, width: iconSize, height: iconSize),
        (_, final n?) => AppIcon(
          n,
          size: iconSize,
          color: iconColor ?? Colors.black,
        ),
        _ => Icon(iconData, size: iconSize, color: iconColor),
      },
    );
  }
}
