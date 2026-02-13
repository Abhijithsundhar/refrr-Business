import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/custom_round_button.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/models/leads_model.dart';

class NotificationScreen extends ConsumerWidget {
  final LeadsModel? currentFirm;
  const NotificationScreen({super.key, required this.currentFirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: width * .05),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: width * .09,
                height: width * .09,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              ),
            ),
            SizedBox(width: width * .03),
            Text(
              "Notifications",
              style: GoogleFonts.dmSans(
                fontSize: width * .055,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black12,
            height: 1,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .04, vertical: width * .03),
        child: ListView(
          children: [
            SizedBox(height: height*.02,),
            NotificationTile(
              title: "New Employee Requested",
              date: "24/12/2025  10:10 AM",
              showButtons: true,
            ),

            NotificationTile(
              title: "Raju has requested to withdrawal of",
              subtitleBold: "INR 10000",
              date: "24/12/2025  10:10 AM",
              showButtons: true,
            ),

            NotificationTile(
              title: "Raju added a New Lead",
              subtitle: "ABC LTD. Malappuram",
              date: "24/12/2025  10:10 AM",
              showButtons: false,
            ),

            NotificationTile(
              title:
              "Sneha updated the lead status from New Lead to Converted",
              subtitle: "ABC LTD. Malappuram",
              date: "24/12/2025  10:10 AM",
              showButtons: false,
            ),

          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Notification Tile Widget
/// ---------------------------------------------------------------------------

class NotificationTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? subtitleBold;
  final String date;
  final bool showButtons;

  const NotificationTile({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleBold,
    required this.date,
    this.showButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: height * .02),
      padding: EdgeInsets.all(width * .035),
      decoration: BoxDecoration(
        color: Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             CircleSvgButton(
                 bgColor: Colors.white,
                 child: SvgPicture.asset('assets/svg/bell.svg')),
              SizedBox(width: width * .03),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TITLE
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: width * .040,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    /// OPTIONAL SUBTITLE (normal)
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.dmSans(
                          fontSize: width * .034,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400
                        ),
                      ),

                    /// OPTIONAL SUBTITLE (bold)
                    if (subtitleBold != null)
                      Text(
                        subtitleBold!,
                        style: GoogleFonts.dmSans(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: height * .02),

          /// DATE + BUTTONS IN SAME ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// DATE (Always visible)
              Text(
                date,
                style: GoogleFonts.dmSans(
                  fontSize: width * .030,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),

              /// BUTTONS (only if showButtons = true)
              if (showButtons)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Reject",
                        style: GoogleFonts.dmSans(
                          color: Colors.red,
                          fontSize: width * .033,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: width * .05),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Accept",
                        style: GoogleFonts.dmSans(
                          color: Colors.green,
                          fontSize: width * .033,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
