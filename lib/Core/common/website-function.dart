import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the www.grro.ai website in the device's default browser.
Future<void> openGrroWebsite() async {
  const String url = 'https://www.grro.ai';
  final Uri uri = Uri.parse(url);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // open in real browser
      );
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    debugPrint('Error opening website: $e');
  }
}