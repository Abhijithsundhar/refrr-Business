import 'package:flutter/material.dart';

class CircleSvgButton extends StatelessWidget {
  final Widget child;
  final double size;
  final EdgeInsets padding;
  final Color borderColor;
  final Color? bgColor;

  const CircleSvgButton({
    super.key,
    required this.child,
    this.size = 36, // circle diameter
    this.padding = const EdgeInsets.all(4),
    this.borderColor = Colors.black12,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
         color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Center(child: child),
    );
  }
}


class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 35,
    this.iconSize = 18,
    this.borderColor = Colors.black12,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    // Shift only for iOS arrow icons
    final bool isIOSArrow = icon == Icons.arrow_back_ios ||
        icon == Icons.arrow_back_ios_new_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Transform.translate(
            offset: isIOSArrow ? const Offset(2, 0) : Offset.zero,
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
