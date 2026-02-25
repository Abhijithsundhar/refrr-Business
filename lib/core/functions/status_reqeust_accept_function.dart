import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:refrr_admin/core/utils/status_name_list.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget statusMessageWithActions({
  required String message,
  required String time,
  required String bgImage,
  required String transactionStatus,
  required VoidCallback onAccept,
  required VoidCallback onReject,
  String? description,
}) {
  debugPrint('🔵 statusMessageWithActions called - transactionStatus: "$transactionStatus"');

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: bgImage.isNotEmpty
              ? CachedNetworkImageProvider(bgImage)
              : null,
          child: bgImage.isEmpty ? const Icon(Icons.person, size: 16) : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Message
              RichText(
                text: buildRichText(message),
              ),
              const SizedBox(height: 8),
              description!.isEmpty?SizedBox.shrink():Text(description??''),
              /// Time + Actions
              Row(
                children: [
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),

                  // ✅ Actions or Badge
                  _buildStatusAction(
                    transactionStatus: transactionStatus,
                    onAccept: onAccept,
                    onReject: onReject,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusAction({
  required String transactionStatus,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  final status = transactionStatus.toLowerCase().trim();
  debugPrint('🔍 _buildStatusAction - status: "$status"');

  // ✅ If Accepted - Show Green Badge
  if (status == 'accepted' || status == 'accept') {
    debugPrint('🟢 Showing ACCEPTED badge');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 14),
          const SizedBox(width: 4),
          Text(
            "Accepted",
            style: GoogleFonts.urbanist(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ If Rejected - Show Red Badge
  if (status == 'rejected' || status == 'reject') {
    debugPrint('🔴 Showing REJECTED badge');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 14),
          const SizedBox(width: 4),
          Text(
            "Rejected",
            style: GoogleFonts.urbanist(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Default: Show Accept & Reject Buttons
  debugPrint('🔵 Showing BUTTONS');
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Reject Button
      GestureDetector(
        onTap: () {
          debugPrint('🔴 Reject button TAPPED!');
          onReject();
        },
        child: Text(
          "Reject",
          style: GoogleFonts.urbanist(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      const SizedBox(width: 10),
      // Accept Button
      GestureDetector(
        onTap: () {
          debugPrint('🟢 Accept button TAPPED!');
          onAccept();
        },
        child: Text(
          "Accept",
          style: GoogleFonts.urbanist(
            color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    ],
  );
}