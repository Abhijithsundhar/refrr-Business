import 'dart:ui';
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
      return const StatusColors(
        background: Color(0xFFD1E8FF),
        border: Color(0xFF3FA2FF),
        circleAvatarBorder: Color(0xFFFFFF00),
        bigBackground: Color(0xFFF5FAFF),
      );
    case 'Contacted':
    case 'Interested':
    case 'Follow-up-Needed':
    case 'Proposal Sent':
    case 'Negotiation':
    case 'Converted':
    case 'Invoice Raised':
    case 'Work in Progress':
      return  StatusColors(
        background: Color(0x1AA3B500).withOpacity(0.1),
        border: Color(0x80A3B500),
        circleAvatarBorder: Color(0xFFA3B500),
        bigBackground: Color(0x0DA3B500),
      );

    case 'Completed':
      return const StatusColors(
        background: Color(0xFFCEF8E2),
        border:Color(0xFF3FFF99),
        circleAvatarBorder: Color(0xFFB6FFD8),
        bigBackground: Color(0xFFF0FFF7),
      );

    case 'Not Qualified':
    case 'Lost':
      return const StatusColors(
        background: Color(0xFFFFDADA),
        border: Color(0xFFFF0000),
        circleAvatarBorder: Color(0xFFFF0000),
        bigBackground: Color(0xFFFFF2F2),
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

