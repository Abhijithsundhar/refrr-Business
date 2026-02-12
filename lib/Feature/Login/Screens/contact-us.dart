import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/call-function.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/email-function.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/location-funtion.dart';
import 'package:refrr_admin/Core/common/website-function.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Contact Us'),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Container(
          width: double.infinity,
          height: height*.49,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.025),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                title: "Phone No",
                value: "+91 85940 04461",
                url: 'assets/svg/blackphone.svg',
                onTap: () {
                  openDialer('+91 85940 04461');
                },
              ),
              Divider(color: Colors.grey.shade300, height: height * 0.05),
              _InfoRow(
                title: "Mail ID",
                value: "info@grro.ai",
                url: 'assets/svg/Mail-logo.svg',
                onTap: () {
                  openEmail(emailAddress: 'info@grro.ai');
                },
              ),
              Divider(color: Colors.grey.shade300, height: height * 0.05),
              _InfoRow(
                title: "Website",
                value: "www.grro.ai",
                url: 'assets/svg/globeBig.svg',
                onTap: () {
                  openGrroWebsite();
                },
              ),
              Divider(color: Colors.grey.shade300, height: height * 0.05),
              _InfoRow(
                title: "Address",
                value: "2219, 2nd Floor, Phase 2, \nHiLITE Business Park, Calicut, \nKerala – 673014",
                url: 'assets/svg/location.svg',
                onTap: () {
                  openMapLocation(
                  "2219, 2nd Floor, Phase 2, HiLITE Business Park, Calicut, Kerala 673014",
                ); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///-------------------- Reusable Info Row --------------------

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final String url;
  final Function() onTap;

  const _InfoRow({
    required this.title,
    required this.value,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TEXT SECTION
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.035,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * 0.004),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.037,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        /// ICON SECTION
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: width * .1,
            height: width * .1,
            decoration: BoxDecoration(
              color: const Color(0xFFE5FBFF),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFF00E0FF)),
            ),
            child: Center(
              child: SvgPicture.asset(
                url,
                width: width * .05,
                height: width * .05,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}