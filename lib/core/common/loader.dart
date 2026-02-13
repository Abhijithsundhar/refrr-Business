import 'package:flutter/material.dart';
import 'package:refrr_admin/core/theme/pallet.dart';

class CommonLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const CommonLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 30,
      width: size ?? 30,
      child: CircularProgressIndicator(
        color: color ?? Pallet.primaryColor,
        strokeWidth: strokeWidth ?? 3,
      ),
    );
  }
}
