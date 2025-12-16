import 'package:flutter/material.dart';

/// Small pill‑shaped line used under the image.
Widget curvedDivider({double? width}) {
  return Container(
    width: width ?? 60,          // default width if you don't pass one
    height: 4,
    decoration: BoxDecoration(
      color: const Color(0xFFE5E9EB),
      borderRadius: BorderRadius.circular(50),
    ),
  );
}