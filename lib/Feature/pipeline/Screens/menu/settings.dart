import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/models/leads_model.dart';

class SettingsScreen extends ConsumerWidget {
  final LeadsModel currentFirm;
  const SettingsScreen({super.key, required this.currentFirm});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Settings'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SizedBox(height: width * .04),
            //
            // /// -----------------------------
            // /// Type of Offerings Tile
            // /// -----------------------------
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: Color(0xFFE5E9EB)),
            //   ),
            //   child: ListTile(
            //     title: Text(
            //       "Type of Offerings",
            //       style: GoogleFonts.dmSans(
            //         fontSize: width * .04,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            //     onTap: () {
            //       showTypeOfOfferingsSheet(context);
            //     },
            //   ),
            // ),

            SizedBox(height: width * .04),

            /// -----------------------------
            /// Delete Account
            /// -----------------------------
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE5E9EB)),
              ),
              child: ListTile(
                leading: Icon(
                  CupertinoIcons.delete,
                  color: Color(0xFFE50707),
                  size: width*.055,
                ),
                title: Text(
                  "Delete Account",
                  style: GoogleFonts.dmSans(
                    fontSize: width * .04,
                    color: Color(0xFFE50707),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  showDeleteAccountDialog(context,() {
                    final leadModel= currentFirm.copyWith(delete: true);
                    ref.watch(leadControllerProvider.notifier)
                        .updateLead(leadModel: leadModel, context: context);
                    showCommonSnackbar(context, 'Account deleted successfully');
                    Navigator.pop(context);
                  },);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void showTypeOfOfferingsSheet(BuildContext context) {
  String selected = "Both";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: width * 0.05,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF49454F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: width*.04,),
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Type of Offerings",
                      style: GoogleFonts.dmSans(
                        fontSize: width * .055,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: width * .09,
                        height: width * .09,
                        decoration: BoxDecoration(
                          color:Colors.black12 ,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.close, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: width * .06),

                // Options
                _optionTile(
                  width: width,
                  title: "Both",
                  isSelected: selected == "Both",
                  onTap: () {
                    setState(() => selected = "Both");
                    Navigator.pop(context, "Both");
                  },
                ),

                _optionTile(
                  width: width,
                  title: "Products",
                  isSelected: selected == "Products",
                  onTap: () {
                    setState(() => selected = "Products");
                    Navigator.pop(context, "Products");
                  },
                ),

                _optionTile(
                  width: width,
                  title: "Services",
                  isSelected: selected == "Services",
                  onTap: () {
                    setState(() => selected = "Services");
                    Navigator.pop(context, "Services");
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _optionTile({
  required double width,
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height*.07,
      margin: EdgeInsets.only(bottom: width * 0.03),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: width * 0.04,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.043,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Container(
              width: width * 0.055,
              height: width * 0.055,
              decoration: const BoxDecoration(
                color: Color(0xFF14DFED), // cyan tick bg
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    ),
  );
}
