import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/core/utils/status_name_list.dart';
import 'package:refrr_admin/models/leads_model.dart';

Widget dateLabel(String date) {
  return Container(
    width: double.infinity, // FULL WIDTH
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Color(0xFFE5E9EB),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          date,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: Color(0xFFE5E9EB),
          ),
        ),
      ],
    ),
  );
}

Widget simpleMessage(String msg, String time,String bgimage) {
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
          backgroundImage:CachedNetworkImageProvider(bgimage),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ⭐ RICH TEXT PARSING
              RichText(
                text: buildRichText(msg),
              ),

              const SizedBox(height: 5),
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
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
}

Widget bottomChatInput({
  required String profileImageUrl,
  required VoidCallback onWalletTap,
  required VoidCallback onRefreshTap,
  required VoidCallback onCalendarTap,
  required VoidCallback onAvatarTap,
  required VoidCallback onSendTap,
  required TextEditingController msgController
}) {
  return Container(
    height: height * .08,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 50,
                  maxWidth: 3000,
                ),
              child: IntrinsicWidth(
                child: TextField(
                  controller: msgController,
                  maxLines: 1,
                  minLines: 1,
                  keyboardType: TextInputType.text,

                  scrollPhysics: const BouncingScrollPhysics(),
                  scrollPadding: EdgeInsets.zero,

                  decoration: InputDecoration(
                    hintText: "Add Your Story Here...",
                    hintStyle: GoogleFonts.urbanist(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                  ),

                  // ⭐ VERY IMPORTANT FOR HORIZONTAL SCROLLING
                  expands: false,
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
          )
          ,
        ),

        const SizedBox(width: 8),
        circleButton(Icons.cached_rounded, onTap: onRefreshTap),
        const SizedBox(width: 8),

        circleButton(Icons.account_balance_wallet_outlined, onTap: onWalletTap),
        const SizedBox(width: 8),

        circleButton(Icons.calendar_month, onTap: onCalendarTap),
        const SizedBox(width: 8),

        /// ---------------- AVATAR OR SEND BUTTON ----------------
        hasText
            ? sendButton(onSendTap)
            : networkAvatar(
          imageUrl: profileImageUrl,
          radius: 16,
          onTap: onAvatarTap,
        ),
      ],
    ),
  );
}

Widget networkAvatar({
  required String imageUrl,
  required double radius,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,

        // When loading
        placeholder: (context, url) => Container(
          width: radius * 2,
          height: radius * 2,
          color: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.grey, size: 20),
        ),

        // When error
        errorWidget: (context, url, error) => Container(
          width: radius * 2,
          height: radius * 2,
          color: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.grey, size: 18),
        ),
      ),
    ),
  );
}

Widget sendButton(VoidCallback onSendTap) {
  return GestureDetector(
    onTap: onSendTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: const Icon(Icons.send, size: 14, color: Colors.white),
    ),
  );
}

Widget circleButton(IconData icon, {required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5E9EB)),
      ),
      child: Icon(icon, size: 16, color: Colors.black),
    ),
  );
}

Widget transactionMessage({
  required String amount,
  required String message,
  required String description,
  required String time,
  required String bgImage
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔵 Avatar
        CircleAvatar(
          radius: 16,
          backgroundImage: CachedNetworkImageProvider(bgImage),
        ),

        const SizedBox(width: 10),

        /// 📝 Message Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ₹1000.00 + main message
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "₹$amount \n",
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00D1FF),
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              /// description
              Text(
                message,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 10),

              /// time
              Row(
                children: [
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    ),
  );
}
Widget transactionsMessageWithActions({
  required String amount,
  required String message,
  required String description,
  required String time,
  required String bgImage,
  required VoidCallback onAccept,
  required VoidCallback onReject,
  String transactionStatus = '', // ✅ Default value added
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔵 Avatar
        CircleAvatar(
          radius: 16,
          backgroundImage: CachedNetworkImageProvider(bgImage),
        ),

        const SizedBox(width: 10),

        /// 📝 Message Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ₹1000.00 + main message
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "₹$amount \n",
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00D1FF),
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              /// description
              message.isNotEmpty
                  ? Text(
                message,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              )
                  : const SizedBox.shrink(),

              AppSpacing.h01,

              /// time + action buttons / status
              Row(
                children: [
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),

                  // ✅ Conditional UI based on transactionStatus
                  _buildTransactionAction(
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

/// ✅ Helper Widget for Transaction Actions
Widget _buildTransactionAction({
  required String transactionStatus,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  // ✅ If Accepted
  if (transactionStatus.toLowerCase() == 'accepted' ||
      transactionStatus.toLowerCase() == 'accept') {
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

  // ✅ If Rejected
  if (transactionStatus.toLowerCase() == 'rejected' ||
      transactionStatus.toLowerCase() == 'reject') {
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
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: onReject,
        child: Text(
          "Reject",
          style: GoogleFonts.urbanist(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      AppSpacing.w03,
      GestureDetector(
        onTap: onAccept,
        child: Text(
          "Accept",
          style: GoogleFonts.urbanist(
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

///chat screen wallet button
void showAddPaymentSheet(BuildContext context,String name,TextEditingController amountController,
    TextEditingController remarksController,LeadsModel? currentFirm,VoidCallback onTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// --- Top small bar ---
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFF49454F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(height: 15),

                /// --- Title ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Money",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "To $name",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: width*.04,
                        backgroundColor: Color(0xFFF3F3F3),
                          child: Icon(Icons.close, size: 18)),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                /// --- Amount Field ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color:  Color(0x1A14DFED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF14DFED)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter Amount",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: height*.03,
                        width: width*.115,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(currentFirm?.currency??'',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: width*.03
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                /// --- Remarks Field ---
                Container(
                  height: height * .055,
                  padding: EdgeInsets.symmetric(horizontal: 9), // add padding here
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFE5E9EB)),
                  ),
                  child: TextField(
                    controller: remarksController,
                    decoration: InputDecoration(
                      hintText: "Remarks..",
                      hintStyle: TextStyle(fontSize: width * .04),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                /// --- Button ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onTap,
                    child: Text(
                      "Add Money",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

///hide delete alert box
void showHideDeleteMenu(
    BuildContext context,
    Offset position, {
      VoidCallback? onHide,
      VoidCallback? onDelete,
    }) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy - 10, 40, 40),
      Offset.zero & overlay.size,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    color: Colors.white,
    items: [
      // PopupMenuItem(
      //   onTap: onHide,
      //   child: Row(
      //     children: [
      //       Icon(Icons.visibility_off_outlined, color: Colors.black),
      //       SizedBox(width: 10),
      //       Text("Hide", style: TextStyle(color: Colors.black)),
      //     ],
      //   ),
      // ),
      PopupMenuItem(
        onTap: onDelete,
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 10),
            Text("Delete", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ],
  );
}






