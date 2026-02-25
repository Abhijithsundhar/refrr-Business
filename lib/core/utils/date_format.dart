import 'package:intl/intl.dart';


String formatDateOnly(String dateString) {
  try {
    final dateTime = DateTime.parse(dateString);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return "$day-$month-$year";
  } catch (e) {
    return dateString; // fallback if parse fails
  }
}

///date custom format
String formatDateTime(
    DateTime date, {
      bool showDate = true,
      bool showTime = true,
    }) {
  if (showDate && showTime) {
    return DateFormat("dd/MM/yyyy   hh:mm a").format(date);
  } else if (showDate) {
    return DateFormat("dd/MM/yyyy").format(date);
  } else if (showTime) {
    return DateFormat("hh:mm a").format(date);
  } else {
    return "";
  }
}