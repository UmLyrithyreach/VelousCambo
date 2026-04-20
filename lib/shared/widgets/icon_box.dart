import 'package:flutter/material.dart';

/// A rounded square container with a centered icon.
/// Used everywhere a colored icon badge is needed.
class IconBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final double radius;

  const IconBox({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.size = 46,
    this.iconSize = 22,
    this.radius = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}
