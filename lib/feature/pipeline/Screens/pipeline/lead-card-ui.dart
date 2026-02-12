import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/homepage-functions.dart';
import 'package:refrr_admin/Core/constants/servicelead-color.dart';
import 'package:refrr_admin/Feature/Login/Screens/home.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/models/add-money-on-lead-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

creditMoney(
    ServiceLeadModel lead,
    BuildContext context,
    WidgetRef ref,
    String remarks,
    String receiverId,
    LeadsModel currentFirm,
    ) async {

  final TextEditingController amountController = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Add Money"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter amount",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = amountController.text.trim();
              if (amount.isEmpty) return;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final newCreditEntry = PaymentModel(
                  amount: int.parse(amountController.text),
                  date: DateTime.now(),
                  added: lead.reference?.id ?? "",
                  remarks: remarks,
                  receiver: receiverId,
                );

                final updatedCreditAmount = [...lead.creditedAmount, newCreditEntry];

                final updatedLead = lead.copyWith(creditedAmount: updatedCreditAmount);

                await ref
                    .read(serviceLeadsControllerProvider.notifier)
                    .updateServiceLeads(
                  context: context,
                  serviceLeadsModel: updatedLead,
                );

                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(dialogContext, rootNavigator: true).pop();

                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(lead: currentFirm, index: 0),
                    ),
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Amount added successfully",
                        style: TextStyle(color: Colors.black)),
                    backgroundColor: Colors.white,
                  ),
                );
              } catch (e) {
                Navigator.of(context, rootNavigator: true).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}


/// Update a single lead's status (adds a new history entry)
Future<void> updateStatus(
  ServiceLeadModel lead,
  BuildContext context,
  WidgetRef ref,
    LeadsModel currentFirm
) async {
  final String? status = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext bottomSheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lead status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: width * .04),
                InkWell(
                  onTap: () async {
                    Navigator.of(bottomSheetContext).pop();
                    await creditMoney(lead, context, ref, remarksController.text,lead.marketerId,currentFirm,
                    );

                  },
                  child: Center(
                    child: Text(
                      ' + Add money',
                      style: GoogleFonts.roboto(
                        color: Colors.blue,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        decorationThickness: 1,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (Navigator.of(bottomSheetContext).canPop()) {
                      Navigator.of(bottomSheetContext).pop();
                    }
                  },
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            SizedBox(height: height * .05),

            // Status chips
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: statusOptions.map((s) {
                  final colors = getStatusColors(s); // your helper for pastel colors
                  final bool selected = s == s;
                  return GestureDetector(
                    onTap: () {
                      if (Navigator.of(bottomSheetContext).canPop()) {
                        Navigator.of(bottomSheetContext).pop(s);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 18),
                      decoration: BoxDecoration(
                        color: colors.bigBackground,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: colors.bigBackground,
                        ),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5E5E5E),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );

  if (status == null) return;

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final newHistoryEntry = {
      "status": status,
      "date": DateTime.now(),
      'added': lead.marketerName ?? ''
    };

    final updatedHistory = [...lead.statusHistory, newHistoryEntry];

    final updatedLead = lead.copyWith(
      statusHistory: updatedHistory,
    );

    await ref.read(serviceLeadsControllerProvider.notifier).updateServiceLeads(
          context: context,
          serviceLeadsModel: updatedLead,
        );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to $status'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating status: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

String getTimeAgo(DateTime date) {
  final Duration diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) {
    return "Just now";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
  } else if (diff.inDays == 1) {
    return "Yesterday";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
  } else if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    return "$weeks week${weeks > 1 ? 's' : ''} ago";
  } else if (diff.inDays < 365) {
    final months = (diff.inDays / 30).floor();
    return "$months month${months > 1 ? 's' : ''} ago";
  } else {
    final years = (diff.inDays / 365).floor();
    return "$years year${years > 1 ? 's' : ''} ago";
  }
}

Widget buildLeadCard(ServiceLeadModel item, StatusColors statusColors, String latestStatus, LeadsModel currentFirm) {
  return Container(
    decoration: BoxDecoration(
      color: statusColors.bigBackground,
      border: Border.all(color: statusColors.border, width: width * .0015),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.symmetric(vertical: height * .008), // ✅ Reduced padding
    child: Column(
      mainAxisSize: MainAxisSize.min, // ✅ Shrink to fit content
      children: [
        /// Header band
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .015, vertical: height * .005), // ✅ Reduced padding
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: statusColors.background,
                borderRadius: const BorderRadius.all(Radius.circular(8))
            ),
            padding: EdgeInsets.symmetric(
                horizontal: width * .02, vertical: height * .008), // ✅ Reduced padding
            child: Row(
              children: [
                CircleAvatar(
                  radius: width * 0.038,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: width * 0.033,
                    backgroundImage: item.leadLogo.isEmpty
                        ? const AssetImage('assets/image.png')
                        : CachedNetworkImageProvider(item.leadLogo) as ImageProvider,
                  ),
                ),
                SizedBox(width: width * .01),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ Shrink to fit
                    children: [
                      Text(
                        item.marketerName,
                        style: GoogleFonts.dmSans(
                          fontSize: width * .029, // ✅ Slightly smaller
                          fontWeight: FontWeight.w600,
                          height: 1.2, // ✅ Tighter line height
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * .001), // ✅ Minimal spacing
                      Text(
                        item.marketerLocation,
                        style: GoogleFonts.dmSans(
                          fontSize: width * .024, // ✅ Smaller
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: height * .008), // ✅ Reduced spacing

        /// Type button (hot, cool, warm)
        Container(
          width: width * .13,
          height: height * .022, // ✅ Slightly smaller
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  item.leadType =='Cool'?
                  'assets/svg/coolImogi.svg':
                  item.leadType == 'Warm'?
                  'assets/svg/warmimogi.svg':
                  'assets/svg/fireimogi.svg',
                  width: 9,
                  height: 9,
                ),
                SizedBox(width: width * .005),
                Text(
                  item.leadType,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: width * .025,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: height * .005), // ✅ Reduced spacing

        /// Time text
        Text(
          getTimeAgo(item.createTime),
          style: GoogleFonts.dmSans(
            fontSize: width * .028, // ✅ Smaller
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E7C87),
            height: 1.2, // ✅ Tighter
          ),
        ),

        SizedBox(height: height * .006), // ✅ Reduced spacing

        /// Service name
        Text(
          item.serviceName,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: width * .038, // ✅ Slightly smaller
            fontWeight: FontWeight.w700,
            color: Color(0xFF027DCF),
            height: 1.2,
          ),
        ),

        SizedBox(height: height * .003), // ✅ Minimal spacing

        /// Lead name
        Text(
          item.firmName,
          style: GoogleFonts.dmSans(
            fontSize: width * .032, // ✅ Slightly smaller
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),

        SizedBox(height: height * .01), // ✅ Reduced spacing

        /// Status button
        Container(
          height: height * .035, // ✅ Smaller button
          width: width * .28, // ✅ Slightly narrower
          decoration: BoxDecoration(
            border: Border.all(
              color: statusColors.border,
              width: width * .002,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              latestStatus,
              style: GoogleFonts.dmSans(
                fontSize: width * .028, // ✅ Smaller text
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        SizedBox(height: height * .008), // ✅ Bottom padding
      ],
    ),
  );
}
