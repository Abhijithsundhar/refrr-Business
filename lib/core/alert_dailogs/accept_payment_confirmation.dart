import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/feature/pipeline/Controller/service_lead_controller.dart';
import 'package:refrr_admin/feature/team/controller/affiliate_controller.dart';
import 'package:refrr_admin/models/addMoney_model.dart';
import 'package:refrr_admin/models/affiliate_model.dart';
import 'package:refrr_admin/models/chatbox_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';
import 'package:refrr_admin/models/totalcredit_model.dart';

void showAcceptConfirmation({
  required BuildContext context,
  required LeadsModel currentFirm,
  required AffiliateModel affiliate,
  required ChatModel chatMsg,
  required int index,
  required String serviceLeadId,
  required List<ChatModel> chatList,
  required WidgetRef ref,
  required ServiceLeadModel service,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {  // ✅ Use dialogContext
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
                "Accept Transaction",
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
                      text: 'Do you want to accept this transaction of ',
                    ),
                    TextSpan(
                      text: '₹${chatMsg.amount}',
                      style: GoogleFonts.dmSans(
                        fontSize: width * .04,
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

              AppSpacing.h03,

              /// Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),  // ✅ Use dialogContext
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
                      // ✅ Store navigator BEFORE async operations
                      final navigator = Navigator.of(dialogContext);
                      final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);

                      try {
                        debugPrint('🟡 Step 1: Starting accept transaction...');
                        debugPrint('🟡 Index: $index');
                        debugPrint('🟡 ServiceLeadId: $serviceLeadId');
                        debugPrint('🟡 ChatList length: ${chatList.length}');

                        // ✅ Validate index
                        if (index < 0 || index >= chatList.length) {
                          debugPrint('❌ Invalid index: $index');
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text("Error: Invalid chat index")),
                          );
                          return;
                        }

                        // 1. Create updated chat model
                        final updatedChat = chatMsg.copyWith(
                          transactionStatus: 'accepted',
                          message: "Payment added to ${service.marketerName ?? 'Unknown'}'s account",
                        );
                        debugPrint('🟡 Step 2: Updated chat created');

                        // 2. Create updated chat list with the new chat at index
                        final updatedChatList = List<ChatModel>.from(chatList);
                        updatedChatList[index] = updatedChat;
                        debugPrint('🟡 Step 3: Chat list updated at index $index');

                        // 3. Create new credit entry
                        final newCreditAmount = PaymentModel(
                          amount: chatMsg.amount ?? 0,
                          date: DateTime.now(),
                          added: currentFirm.reference?.id ?? '',
                          remarks: 'Payment for the lead: $serviceLeadId',
                          receiver: service.marketerId ?? '',
                        );
                        debugPrint('🟡 Step 4: Payment model created');

                        // 4. Create updated service with BOTH chat and credit amount
                        final existingCreditEntries = service.creditedAmount ?? [];
                        final updatedService = service.copyWith(
                          chat: updatedChatList,
                          creditedAmount: [...existingCreditEntries, newCreditAmount],
                        );
                        debugPrint('🟡 Step 5: Service model updated');

                        // 5. Update service leads in Firebase (SINGLE UPDATE)
                        await ref.read(serviceLeadsControllerProvider.notifier).updateServiceLeads(
                          serviceLeadsModel: updatedService,
                          context: dialogContext,  // ✅ Use dialogContext
                        );
                        debugPrint('🟢 Step 6: Service leads updated in Firebase');

                        // 6. Create new total credit entry for affiliate
                        final newTotalCreditEntry = TotalCreditModel(
                          amount: (chatMsg.amount ?? 0).toDouble(),
                          addedTime: DateTime.now(),
                          acceptBy: currentFirm.reference?.id ?? '',
                          moneyAddedBy: currentFirm.reference?.id ?? '',
                          currency: currentFirm.currency,
                          description: 'Payment for the lead: $serviceLeadId',
                          image: '',
                        );
                        debugPrint('🟡 Step 7: Total credit entry created');

                        // 7. Update affiliate
                        final existingTotalCredits = affiliate.totalCredits ?? [];
                        final updatedAffiliate = affiliate.copyWith(
                          totalBalance: (affiliate.totalBalance ?? 0) + (chatMsg.amount ?? 0),
                          totalCredit: (affiliate.totalCredit ?? 0) + (chatMsg.amount ?? 0),
                          totalCredits: [...existingTotalCredits, newTotalCreditEntry],
                        );

                        await ref.read(affiliateControllerProvider.notifier).updateAffiliate(
                          affiliateModel: updatedAffiliate,
                          context: dialogContext,  // ✅ Use dialogContext
                        );
                        debugPrint('🟢 Step 8: Affiliate updated');

                        debugPrint('✅ Transaction accepted successfully: ${chatMsg.amount}');

                        // ✅ Close dialog using stored navigator
                        navigator.pop();

                      } catch (e, stackTrace) {
                        debugPrint('❌ Error accepting transaction: $e');
                        debugPrint('❌ Stack trace: $stackTrace');

                        scaffoldMessenger.showSnackBar(
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