import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp(String phone) async {
  final Uri url = Uri.parse("https://wa.me/$phone");

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception("Could not open WhatsApp");
  }
}
