import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> openDialer(String phoneNumber, {BuildContext? context}) async {
  // Clean the phone number
  final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

  if (cleanedNumber.isEmpty) {
    _showError(context, 'Invalid phone number');
    return;
  }

  final Uri uri = Uri(scheme: 'tel', path: cleanedNumber);

  try {
    // Method 1: Try with externalApplication mode
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    try {
      // Method 2: Try with platformDefault mode
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e2) {
      try {
        // Method 3: Use method channel (Android specific)
        await _launchDialerWithMethodChannel(cleanedNumber);
      } catch (e3) {
        // Final fallback: Copy to clipboard
        _handleError(context, cleanedNumber);
      }
    }
  }
}

// Android-specific method using platform channel
Future<void> _launchDialerWithMethodChannel(String phoneNumber) async {
  const platform = MethodChannel('flutter.native/helper');
  try {
    await platform.invokeMethod('openDialer', {'phoneNumber': phoneNumber});
  } catch (e) {
    throw 'Method channel failed: $e';
  }
}

void _handleError(BuildContext? context, String phoneNumber) {
  if (context != null) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone number copied: $phoneNumber\nPlease dial manually.'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

void _showError(BuildContext? context, String message) {
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  debugPrint(message);
}
