import 'package:flutter/material.dart';

void showCommonSnackbar(BuildContext context, String message,) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2), // You can adjust the duration
    behavior: SnackBarBehavior.floating, // Optional: makes Snackbar float above UI elements
    backgroundColor: Colors.black, // Optional: set your preferred background color
  );

  // Show the snackbar using ScaffoldMessenger
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


void showCommonSnackbars({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white),),
      duration: duration,
    ),
  );
}