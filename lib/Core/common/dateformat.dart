import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(dynamic date) {
  if (date == null) return '';
  if (date is Timestamp) {
    final dt = date.toDate();
    return DateFormat('dd-MM-yyyy').format(dt); // change format as needed
  }
  if (date is DateTime) {
    return DateFormat('dd-MM-yyyy').format(date);
  }
  // already a string
  return date.toString();
}
