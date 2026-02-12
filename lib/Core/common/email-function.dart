import 'package:url_launcher/url_launcher.dart';

/// Opens the default mail application to compose a new email.
/// [emailAddress] is the recipient email to send to.
/// Optionally pass a [subject] and [body].
Future<void> openEmail({required String emailAddress, String? subject, String? body}) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: emailAddress,
    queryParameters: {
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
    },
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw Exception('Could not launch $emailUri');
  }
}