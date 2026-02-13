import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ✅ Open WhatsApp Chat - Supports Any Country Code
Future<void> openWhatsAppChat(
    String phoneNumber, {
      String? message,
      BuildContext? context,
    }) async {
  try {
    // Remove spaces, dashes, parentheses, but keep + and digits
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    debugPrint('📱 Original number: $phoneNumber');
    debugPrint('📱 Cleaned number: $cleaned');

    String fullNumber;

    // Check different formats
    if (cleaned.startsWith('+')) {
      // Already has + with country code, just remove the +
      // Example: +91 9876543210 → 919876543210
      // Example: +1 234 567 8900 → 12345678900
      // Example: +971 50 123 4567 → 971501234567
      fullNumber = cleaned.substring(1).replaceAll(RegExp(r'\D'), '');
    } else if (cleaned.startsWith('00')) {
      // International format with 00 prefix
      // Example: 00971501234567 → 971501234567
      fullNumber = cleaned.substring(2).replaceAll(RegExp(r'\D'), '');
    } else {
      // Number without + (might already have country code or not)
      // Just clean it and use as is
      // Example: 919876543210 → 919876543210
      // Example: 971501234567 → 971501234567
      fullNumber = cleaned.replaceAll(RegExp(r'\D'), '');
    }

    debugPrint('📱 Final number for WhatsApp: $fullNumber');

    // Validate number
    if (fullNumber.isEmpty || fullNumber.length < 7) {
      _showError(context, 'Invalid phone number');
      return;
    }

    // Build WhatsApp URL (NO + sign needed in wa.me URL)
    String whatsappUrl = 'https://wa.me/$fullNumber';

    // Add message if provided
    if (message != null && message.isNotEmpty) {
      final encodedMessage = Uri.encodeComponent(message);
      whatsappUrl = '$whatsappUrl?text=$encodedMessage';
    }

    debugPrint('📱 WhatsApp URL: $whatsappUrl');

    final uri = Uri.parse(whatsappUrl);

    // Try to launch
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      debugPrint('❌ Primary URL failed, trying alternative...');

      // Try alternative whatsapp:// scheme
      String altUrl = 'whatsapp://send?phone=$fullNumber';
      if (message != null && message.isNotEmpty) {
        altUrl = '$altUrl&text=${Uri.encodeComponent(message)}';
      }

      final altUri = Uri.parse(altUrl);
      final altLaunched = await launchUrl(
        altUri,
        mode: LaunchMode.externalApplication,
      );

      if (!altLaunched) {
        _showError(context, 'Could not open WhatsApp. Make sure WhatsApp is installed.');
      }
    }
  } catch (e) {
    debugPrint('❌ WhatsApp Error: $e');
    _showError(context, 'Error opening WhatsApp: $e');
  }
}

/// Show error message
void _showError(BuildContext? context, String message) {
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
