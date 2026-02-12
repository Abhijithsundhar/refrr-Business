import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:flutter/services.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
// for clipboard copy


void showCommonAlertBox(BuildContext context, String message, VoidCallback onYesPressed, String buttonText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        title: Text(
          message,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Action Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onYesPressed();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      buttonText,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      );
    },
  );
}


void showLogoutDialog(BuildContext context,Future<void> Function() onTap) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text("Logout",
                style: GoogleFonts.dmSans(
                  fontSize: width*.055,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text("Are you sure you want to Logout?",
                style: GoogleFonts.dmSans(
                  fontSize: width*.04,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // Logout Button
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Logout",
                      style: GoogleFonts.dmSans(
                        fontSize: width*.045,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
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

void showDeleteAccountDialog(BuildContext context,VoidCallback onTap) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Title
              Text(
                "Delete Account",
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: width * 0.02),

              // Subtitle
              Text(
                "Are you sure you want to Delete this account?",
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.038,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: width * 0.04),

              // Info Box
              Container(
                padding: EdgeInsets.all(width * 0.03),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8FF), // light blue Bg
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E9F4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: width * 0.05, color: Colors.black54),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: Text(
                        "account Deletion\n\n"
                            "Users can delete their account at any time from within the application. "
                            "Once deleted, the account will be permanently disabled and access will be revoked. "
                            "All personal data will be removed from active systems and will no longer be visible to other users. "
                            "Certain business-related records may be retained for security, legal, or compliance purposes, "
                            "in accordance with applicable laws.",
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.035,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: width * 0.05),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.043,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  // Delete
                  TextButton(
                    onPressed: onTap,
                    child: Text(
                      "Delete",
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.043,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
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

void commonAlert(BuildContext context,String title,String subtitle,String buttonName,VoidCallback onTap) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                 Text(title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                /// SUBTITLE
                 Text(subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 22),

                /// ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// CANCEL
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                       Spacer(),
                    /// DOWNLOAD
                    GestureDetector(
                      onTap: onTap,
                      child:  Text(buttonName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

///successful  alert box
/// SUCCESSFUL ALERT BOX
void showSuccessAlertDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  String buttonText = "Close",
  required VoidCallback onTap,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // user can't close by tapping outside
    builder: (dialogContext) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// SUCCESS ICON
                SvgPicture.asset('assets/svg/checked.svg'),

                const SizedBox(height: 20),

                /// TITLE
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                /// SUBTITLE
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 26),

                /// CLOSE BUTTON
                SizedBox(
                  width: width * .3,
                  height: 48,
                  child: GestureDetector(
                    onTap: () {
                      // ✅ close the alert dialog first
                      Navigator.pop(dialogContext);
                      Navigator.pop(dialogContext);
                      // ✅ then run the caller’s custom callback
                      onTap();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
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

///city delete
void showDeleteMenu(
    BuildContext context,
    Offset position,
    VoidCallback onTap,
    ) {
  showMenu(
    context: context,
    color: Colors.white,
    elevation: 0,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),

    // 🔴 Set constraints to control width
    constraints: const BoxConstraints(
      minWidth: 100,  // Increased width
      maxWidth: 200,  // Maximum width
    ),

    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      10,
      0,
    ),
    items: [
      PopupMenuItem(
        value: 'delete',

        // 🔴 Decreased height
        height: 28,

        // 🔴 Remove internal padding
        padding: EdgeInsets.zero,

        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,  // Reduced vertical padding
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 16,  // Slightly smaller icon
              ),
              SizedBox(width: 6),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ).then((value) {
    if (value == 'delete') {
      onTap();
    }
  });
}

///publish successful

Future<void> publishSuccessAlertDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String websiteUrl,
  String buttonText = "Close",
  required VoidCallback onTapClose,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Success Icon
                SvgPicture.asset('assets/svg/checked.svg', width: 80, height: 80,),

                const SizedBox(height: 20),

                // ✅ Title
                Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 15),

                // ✅ Website Link Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // URL Text
                  Expanded(
                  child: Text(
                  websiteUrl.length > 30
                  ? "${websiteUrl.substring(0, 30)}..."
                  : websiteUrl,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
          ),

                      // Copy Link Button
                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: websiteUrl));
                          showCommonSnackbar(context,'Copied to clipboard');
                        },
                        child: const Text("Copy Link",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 04),

                      // Share / arrow icon
                     SvgPicture.asset('assets/svg/publishShare.svg')
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Close Button at Bottom
                SizedBox(
                  width: width * .5,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // First close the dialog route safely
                      Navigator.of(context, rootNavigator: true).pop();
                      // Then run whatever navigation logic you passed in
                      onTapClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
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



shareButtonOnTapPopup({
  required BuildContext context,
  required VoidCallback
  onShare,
  required String url,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text("Share",
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Spacer(),
                CircleIconButton(icon: Icons.close, onTap: (){Navigator.pop(context);}),
              ],
            ),
            const SizedBox(height: 6),
            Text("Share Your Website URL",
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // URL + Copy Link pill
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      if (url.isEmpty) return; // prevent blank copy
                      await Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      "Copy Link",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A58FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Social icons row
            // Row(
            //   children: [
            //     _socialCircle(
            //       bg: const Color(0xFF1877F2),
            //       child: SvgPicture.asset(
            //         "assets/svg/fb-logo.svg",
            //         width: 35,
            //         height: 35,
            //       ),
            //       onTap: onShare, // replace with actual share to FB
            //     ),
            //     SizedBox(width: 16),
            //     _socialCircle(
            //       bg: const Color(0xFF25D366),
            //       child: SvgPicture.asset(
            //         "assets/svg/whatsapp-logo.svg",
            //         width: 35,
            //         height: 35,
            //       ),
            //       onTap: onShare, // replace with actual share to WhatsApp
            //     ),
            //     const SizedBox(width: 16),
            //     _socialCircle(
            //       bg: const Color(0xFFE1306C),
            //       child: SvgPicture.asset(
            //         "assets/svg/instagram-logo.svg",
            //         width: 35,
            //         height: 35,
            //       ),
            //       onTap: onShare, // replace with actual share to Instagram
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    ),
  );
}

 Widget _socialCircle({
required Color bg,
required Widget child,
required VoidCallback onTap,
}) {
return InkResponse(onTap: onTap, radius: 30, child: child);
}

void showTeamLimitAlert(BuildContext context, int teamLimit) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap close
    builder: (context) {
      return AlertDialog(
         backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Text('team Limit Reached',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    CircleIconButton(icon: Icons.close, onTap: (){Navigator.pop(context);})
                  ],
                ),
                const SizedBox(height: 8),
                Text('Your maximum team limit of $teamLimit has been reached.\n'
                      'Contact Grro Admin to add more members.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
