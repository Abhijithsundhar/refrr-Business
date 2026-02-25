import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/customtextfield.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/feature/pipeline/Controller/service_lead_controller.dart';
import 'package:refrr_admin/models/chatbox_model.dart';

void showStatusRejectConfirmation({
  required BuildContext context,
  required ChatModel chatMsg,
  required int index,
  required String serviceLeadId,
  required List<ChatModel> chatList,
  required WidgetRef ref,
}) {
  final TextEditingController reasonController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {  // ✅ Use different context name
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                "Reject Status Request",
                style: GoogleFonts.dmSans(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w700,
                ),
              ),

              AppSpacing.h01,

              /// Subtitle
              RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                    fontSize: width * .03,
                    color: Colors.black54,
                    height: 1,
                  ),
                  children: const [
                    TextSpan(text: 'Do you want to reject this status?'),
                  ],
                ),
              ),

              AppSpacing.h02,

              /// Reason TextField
              inputField(
                'Enter reason for rejection...',
                reasonController,
                TextInputType.text,
                const SizedBox(),
                maxLines: 1,
              ),

              AppSpacing.h02,

              /// Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.dmSans(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  /// Reject Button
                  GestureDetector(
                    onTap: () {
                      // ✅ Store values before closing
                      final reason = reasonController.text.trim();

                      // ✅ Close dialog IMMEDIATELY
                      Navigator.pop(dialogContext);

                      // ✅ Show snackbar immediately
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Rejecting status..."),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // ✅ Do Firebase update in background (no await)
                      _performReject(
                        context: context,
                        ref: ref,
                        chatMsg: chatMsg,
                        reason: reason,
                        serviceLeadId: serviceLeadId,
                        chatList: chatList,
                        index: index,
                      );
                    },
                    child: Text(
                      "Reject",
                      style: GoogleFonts.dmSans(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ✅ Separate function for Firebase update
Future<void> _performReject({
  required BuildContext context,
  required WidgetRef ref,
  required ChatModel chatMsg,
  required String reason,
  required String serviceLeadId,
  required List<ChatModel> chatList,
  required int index,
}) async {
  try {
    debugPrint('🔄 Rejecting status...');

    // Create updated chat model
    final updatedChat = chatMsg.copyWith(
      transactionStatus: 'rejected',
      description: 'Reject Reason: $reason',
    );

    // Update in Firebase
    await ref.read(serviceLeadsControllerProvider.notifier).updateChatAtIndex(
      serviceLeadId: serviceLeadId,
      currentChatList: chatList,
      index: index,
      updatedChat: updatedChat,
      context: context,
    );

    debugPrint('✅ Status rejected successfully');
    debugPrint('Reason: $reason');

    // Show success snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Status Rejected"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint('❌ Error rejecting status: $e');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}