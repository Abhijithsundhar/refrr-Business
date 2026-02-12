import 'package:url_launcher/url_launcher.dart';

/// Opens a maps app (Google Maps, Apple Maps, etc.) to show the given [address].
Future<void> openMapLocation(String address) async {
  // Always URL‑encode the address text
  final encodedAddress = Uri.encodeComponent(address);

  // Use Google Maps universal link (works everywhere including iOS)
  final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication, // open in Maps app or browser
    );
  } else {
    throw 'Could not launch map for $address';
  }
}
