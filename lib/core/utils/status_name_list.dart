import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextSpan buildRichText(String text) {
  // List of all status keywords
  final keywords = [
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

  // Build a single regex pattern for all keywords, case-insensitive
  final pattern = keywords
      .map((e) => RegExp.escape(e))
      .join('|'); // New Lead|Contacted|...

  final regex = RegExp(pattern, caseSensitive: false);

  // Find all matches
  final matches = regex.allMatches(text).toList();

  // If no keyword found → return normal TextSpan
  if (matches.isEmpty) {
    return TextSpan(
      text: text,
      style: GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  // Build the rich text dynamically
  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (var match in matches) {
    // Add normal text before the match
    if (match.start > lastEnd) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd, match.start),
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      );
    }

    // Add bold text (the matched keyword with actual casing)
    spans.add(
      TextSpan(
        text: match.group(0), // actual matched text
        style: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w800, // bold
          color: Colors.black,
        ),
      ),
    );

    lastEnd = match.end;
  }

  // Add any remaining text at end
  if (lastEnd < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastEnd),
        style: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  return TextSpan(children: spans);
}
