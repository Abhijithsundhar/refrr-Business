
const List<String> leadStatuses = [
  "New Lead",
  "Contacted",
  "Interested",
  "Follow-up-needed",
  "Proposal Sent",
  "Negotiation",
  "Converted",
  "Invoice Raised",
  "Work in Progress",
  "Completed",
  "Not Qualified",
  "Lost",
];



String? extractStatus(String? message) {
  if (message == null) return null;

  final trimmedMessage = message.trim();

  for (final status in leadStatuses) {
    if (trimmedMessage.endsWith(status)) {
      return status;
    }
  }

  return null;
}
