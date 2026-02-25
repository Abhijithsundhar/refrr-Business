import 'package:url_launcher/url_launcher.dart';

///whats app and phone call funtions
Future<void> callNumber(String phoneNumber) async {
  final String cleanedNumber = phoneNumber.replaceAll(" ", "");
  final Uri url = Uri.parse("tel:$cleanedNumber");

  if (!await launchUrl(url)) {
    throw Exception("Could not launch phone dialer");
  }
}