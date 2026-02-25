import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/core/utils/extract_status_from_chat_message.dart';
import 'package:refrr_admin/feature/pipeline/Controller/service_lead_controller.dart';
import 'package:refrr_admin/models/affiliate_model.dart';
import 'package:refrr_admin/models/chatbox_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';

void showStatusAcceptConfirmation({
  required BuildContext context,
  required LeadsModel currentFirm,
  required AffiliateModel affiliate,
  required ChatModel chatMsg,
  required int index,
  required String serviceLeadId,
  required List<ChatModel> chatList,
  required WidgetRef ref,
  required ServiceLeadModel service
}) {
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
              Text(
                "Accept Status Request",
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
                  children: [
                    const TextSpan(
                      text: 'Do you want to accept this status request?',
                    ),

                  ],
                ),
              ),

              AppSpacing.h03,

              /// Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.dmSans(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  /// Accept Button
                  GestureDetector(
                    onTap: () async {
                      try {
                        // ✅ Validate index
                        if (index < 0 || index >= chatList.length) {
                          debugPrint('❌ Invalid index: $index');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error: Invalid chat index")),
                          );
                          return;
                        }

                        // 1. Create updated chat model
                        final updatedChat = chatMsg.copyWith(
                          transactionStatus: 'accepted',
                          description: "status accepted by ${currentFirm.name ?? ''}",
                        );
                        debugPrint('🟡 Step 2: Updated chat created');

                        // 2. Create updated chat list with the new chat at index
                        final updatedChatList = List<ChatModel>.from(chatList);
                        updatedChatList[index] = updatedChat;
                        debugPrint('🟡 Step 3: Chat list updated at index $index');

                        // 3. ✅ FIX: Create a completely NEW list (deep copy)
                        final List<Map<String, dynamic>> existingStatusList =
                        List<Map<String, dynamic>>.from(service.statusHistory.map((e) => Map<String, dynamic>.from(e)));

                        debugPrint('📋 Step 4a: Existing status count: ${existingStatusList.length}');
                        debugPrint('📋 Step 4b: Existing statuses: $existingStatusList');

                        // 4. Create new status
                        final newStatus = {
                          'added': currentFirm.reference?.id ?? '',
                          'date': DateTime.now(),
                          'status': extractStatus(chatMsg.message),
                        };

                        // ✅ Add to the NEW list
                        existingStatusList.add(newStatus);

                        debugPrint('📋 Step 4c: New status count after add: ${existingStatusList.length}');
                        debugPrint('📋 Step 4d: New status added: $newStatus');

                        // 5. Create updated service with BOTH chat and status history
                        final updatedService = service.copyWith(
                          chat: updatedChatList,          // ✅ Include updated chat
                          statusHistory: existingStatusList,  // ✅ Pass the new list
                        );
                        debugPrint('🟡 Step 5: Service model updated');

                        // 6. Update service leads in Firebase (SINGLE UPDATE)
                        await ref.read(serviceLeadsControllerProvider.notifier).updateServiceLeads(
                          serviceLeadsModel: updatedService, context: context,);

                        debugPrint('🟢 Step 6: Service leads updated in Firebase');

                        // 7. Close dialog and show success
                        Navigator.pop(context);

                      } catch (e, stackTrace) {
                        debugPrint('❌ Error accepting transaction: $e');
                        debugPrint('❌ Stack trace: $stackTrace');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Accept",
                      style: GoogleFonts.dmSans(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}