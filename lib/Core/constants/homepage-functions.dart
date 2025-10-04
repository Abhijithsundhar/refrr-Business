import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

// Use one canonical list everywhere
final List<String> statusOptions = const [
  'New Lead',
  'Contacted',
  'Interested',
  'Follow-Up-Needed',
  'Proposal Sent',
  'Negotiation',
  'Converted',
  'Invoice Raised',
  'Work in Progress',
  'Completed',
  'Not Qualified',
  'Lost',
];

// Robust: convert Timestamp/DateTime to DateTime
DateTime _toDateTime(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return DateTime(0);
}


// Fast, non-mutating latest status from history
String? getLatestStatus(List<Map<String, dynamic>> statusHistory) {
  if (statusHistory.isEmpty) return null;

  String? latestStatus;
  DateTime latestDate = DateTime(0);
  for (final h in statusHistory) {
    final date = _toDateTime(h['date']);
    if (date.isAfter(latestDate)) {
      latestDate = date;
      latestStatus = h['status']?.toString();
    }
  }
  return latestStatus;
}

// Colors for chips in the bottom sheet
Color chipBackground(String status) {
  switch (status) {
    case 'New Lead':
      return const Color(0xFFF5FAFF);
    case 'Completed':
      return const Color(0xFFF0FFF7);
    case 'Not Qualified':
    case 'Lost':
      return const Color(0xFFFFF2F2);
    default:
      return const Color(0xFFFAFBF2);
  }
}

Color chipAccent(String status) {
  switch (status) {
    case 'New Lead':
      return const Color(0xFF3FA2FF);
    case 'Completed':
      return const Color(0xFF3FFF99);
    case 'Not Qualified':
    case 'Lost':
      return const Color(0xFFFF7979);
    default:
      return const Color(0xFFCFD879);
  }
}

