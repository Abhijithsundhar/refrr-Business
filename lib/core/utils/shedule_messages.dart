import 'package:refrr_admin/core/utils/date_format.dart';

String getMessageText(String? msg, String date,String? description) {
  final formattedDate = formatDateOnly(date);

  // Add a space + description only if it's not null/empty
  final descText = (description != null && description.isNotEmpty)
      ? ". $description" : "";
  switch (msg) {
    case "Meeting":
      return "A meeting has been scheduled on $formattedDate$descText.";

    case "Remind":
      return "A reminder has been set for $formattedDate$descText.";

    case "Followup":
      return "A follow-up has been scheduled on $formattedDate$descText.";

    case "Call":
      return "A call has been scheduled on $formattedDate$descText.";

    default:
      return msg ?? "";
  }
}
