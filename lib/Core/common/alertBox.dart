import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';

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


void showLogoutDialog(BuildContext context,VoidCallback onTap) {
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
              Text(
                "Logout",
                style: GoogleFonts.dmSans(
                  fontSize: width*.055,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                "Are you sure you want to Logout?",
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
                        "Once you confirm deletion, the account enters a 14-day grace period. During these 14 days, you can contact support to restore your account before it is permanently deleted.",
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

