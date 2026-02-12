import 'package:flutter/material.dart';

class StatusColors {
  final Color background;
  final Color border;
  final Color circleAvatarBorder;
  final Color bigBackground;

  const StatusColors({
    required this.background,
    required this.border,
    required this.circleAvatarBorder,
    required this.bigBackground,
  });
}


StatusColors getStatusColors(String status) {
  switch (status) {
    case 'New Lead':
      return StatusColors(
        background: const Color(0xFF29ABE2).withOpacity(0.1),
        border: const Color(0xFF29ABE2).withOpacity(.3),
        circleAvatarBorder: const Color(0xFFFFFF00),
        bigBackground: const Color(0xFF29ABE2).withOpacity(0.1),
      );

    case 'Contacted':
    case 'Interested':
    case 'Follow-up-Needed':
    case 'Proposal Sent':
    case 'Negotiation':
    case 'Converted':
    case 'Invoice Raised':
    case 'Work in Progress':
      return StatusColors(
        background: const Color(0xFFFFAB19).withOpacity(0.1), // 🟡 fixed (added missing F)
        border: const Color(0xFFFFAB19).withOpacity(.3),
        circleAvatarBorder: const Color(0xFFA3B500),
        bigBackground: const Color(0xFFFFAB19).withOpacity(.1),
      );

    case 'Completed':
      return StatusColors(
        background: const Color(0xFF30C67C).withOpacity(.1), // ✅ fixed
        border: const Color(0xFF30C67C).withOpacity(.3),
        circleAvatarBorder: const Color(0xFFB6FFD8),
        bigBackground: const Color(0xFF30C67C).withOpacity(.1),
      );

    case 'Not Qualified':
    case 'Lost':
      return StatusColors(
        background: const Color(0xFFE50707).withOpacity(.1), // ✅ fixed
        border: const Color(0xFFE50707).withOpacity(.3),
        circleAvatarBorder: const Color(0xFFFF0000),
        bigBackground: const Color(0xFFE50707).withOpacity(.1),
      );

    default:
      return StatusColors(
        background: Colors.grey[300]!,
        border: Colors.grey[600]!,
        circleAvatarBorder: Colors.grey[700]!,
        bigBackground: Colors.grey[200]!,
      );
  }
}
