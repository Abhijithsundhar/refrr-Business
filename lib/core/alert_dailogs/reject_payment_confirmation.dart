import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/customtextfield.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/feature/pipeline/Controller/service_lead_controller.dart';
import 'package:refrr_admin/models/chatbox_model.dart';

void showRejectConfirmation({
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
    builder: (context) {
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
              Text("Reject Transaction",
                style: GoogleFonts.dmSans(
                  fontSize: width*.04,
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
                  children: [
                    const TextSpan(
                      text: 'Do you want to reject this transaction of ',
                    ),
                    TextSpan(
                      text: '₹${chatMsg.amount}',
                      style: GoogleFonts.dmSans(
                        fontSize: width * .035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const TextSpan(
                      text: '?',
                    ),
                  ],
                ),
              ),
              AppSpacing.h02,
              /// Reason TextField
              inputField('Enter reason for rejection...', reasonController, TextInputType.text, SizedBox(),maxLines: 1),
              AppSpacing.h02,
              /// Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:  Text("Cancel",
                      style: GoogleFonts.dmSans(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  /// Reject Button
                  GestureDetector(
                    onTap: () async {
                        try {
                          // Create updated chat model using copyWith
                          final updatedChat = chatMsg.copyWith(transactionStatus: 'rejected',message: 'Reject Reason : ${reasonController.text.trim()}');
                          // Update the chat at index
                          await ref.read(serviceLeadsControllerProvider.notifier).updateChatAtIndex(
                            serviceLeadId: serviceLeadId,
                            currentChatList: chatList,
                            index: index,
                            updatedChat: updatedChat,
                            context: context,
                          );

                          debugPrint('Rejected: ${chatMsg.amount}');
                          debugPrint('Reason: ${reasonController.text.trim()}');

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Transaction Rejected")),
                          );
                        } catch (e) {
                          debugPrint('Error rejecting transaction: $e');
                        }

                    },
                    child:  Text("Reject",
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