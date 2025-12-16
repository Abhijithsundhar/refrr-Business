import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/models/affiliate-model.dart';

class ProfilePage extends StatefulWidget {
  final AffiliateModel affiliate;
  const ProfilePage({super.key, required this.affiliate});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ===== HEADER =====
            SizedBox(
              height: height * 0.2,
              child: Stack(
                children: [
                  Container(
                    height: height * 0.15,
                    color: Pallet.lightBlueColor,
                    padding: EdgeInsets.all(width * 0.01),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            AssetConstants.back,
                            width: width * 0.08,
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset(AssetConstants.call, width: width * 0.08),
                        SizedBox(width: width * 0.01),
                        SvgPicture.asset(AssetConstants.whatsapp, width: width * 0.08),
                        SizedBox(width: width * 0.01),
                        SvgPicture.asset(AssetConstants.dott, width: width * 0.08),
                      ],
                    ),
                  ),

                  Positioned(
                    right: width * 0.45,
                    top: width * 0.2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: height * 0.051,
                          backgroundColor: Pallet.backgroundColor,
                          child: CircleAvatar(
                            radius: height * 0.05,
                            backgroundImage: widget.affiliate.profile.isEmpty
                                ? const AssetImage("assets/profile.jpg")
                                : NetworkImage(widget.affiliate.profile)
                            as ImageProvider,
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.affiliate.name,
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(AssetConstants.location),
                                SizedBox(width: width * 0.005),
                                Text(
                                  widget.affiliate.zone,
                                  style: GoogleFonts.dmSans(
                                    fontSize: width * 0.025,
                                    color: Pallet.greyColor,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: width * 0.02),

            /// ===== STAT CARDS =====
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Row(
                children: [
                  _statBox("Total Leads", "${widget.affiliate.totalLeads ?? 0}", width, height),
                  _statBox("LQ", "${widget.affiliate.leadScore?.round() ?? 0}%", width, height),
                  _statBox("Balance", "AED ${widget.affiliate.balance}", width, height),
                ],
              ),
            ),

            /// ===== TAB BAR =====
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.02,
                top: width * 0.01,
                bottom: width * 0.01,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  height: width * 0.1,
                  width: height * 0.68,
                  decoration: BoxDecoration(
                    color: Pallet.lightBlue,
                    borderRadius: BorderRadius.circular(width * 0.05),
                  ),
                  child: Row(
                    children: [
                      _tabItem("Account", 0, width),
                      _tabItem("Pipeline", 1, width),
                      _tabItem("Personal Info", 2, width),
                      _tabItem("Professional Info", 3, width),
                      _tabItem("Career Preference", 4, width),
                    ],
                  ),
                ),
              ),
            ),

            /// ===== TAB CONTENT =====
            if (selectedTab == 0) _accountTab(width),
            if (selectedTab != 0) _placeholder(width),
          ],
        ),
      ),
    );
  }

  /// ===== STAT BOX =====
  Widget _statBox(String title, String value, double width, double height) {
    return Container(
      width: height * 0.139,
      height: height * 0.075,
      margin: EdgeInsets.only(right: width * 0.01),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: Pallet.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.dmSans(
                  fontSize: width * 0.03, color: Pallet.greyColor)),
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: width * 0.04, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// ===== TAB ITEM =====
  Widget _tabItem(String title, int index, double width) {
    final active = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        width: width * 0.3,
        padding: EdgeInsets.symmetric(
          vertical: width * 0.03,
          horizontal: width * 0.01,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.05),
          border: active
              ? Border.all(color: Pallet.primaryColor, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.03,
              fontWeight: FontWeight.w500,
              color: active ? Pallet.secondaryColor : Pallet.greyColor,
            ),
          ),
        ),
      ),
    );
  }

  /// ===== ACCOUNT TAB =====
  Widget _accountTab(double width) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Row(
            children: [
              Expanded(
                child: _amountCard(
                  "Amount Credited",
                  "AED ${widget.affiliate.totalCredit}",
                  Colors.green,
                  width,
                ),
              ),
              SizedBox(width: width * 0.02),
              Expanded(
                child: _amountCard(
                  "Amount Withdrawn",
                  "AED ${widget.affiliate.totalWithrew}",
                  Colors.red,
                  width,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ===== AMOUNT CARD =====
  Widget _amountCard(
      String title, String value, Color color, double width) {
    return Container(
      padding: EdgeInsets.only(left: width * 0.02, top: width * 0.02),
      decoration: BoxDecoration(
        color: Pallet.backgroundColor,
        borderRadius: BorderRadius.circular(width * 0.02),
        border: Border.all(color: Pallet.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.dmSans(
                  fontSize: width * 0.03, color: Pallet.greyColor)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: width * 0.05,
                  color: color,
                ),
              ),
              SvgPicture.asset(AssetConstants.cashImg),
            ],
          ),
        ],
      ),
    );
  }

  /// ===== PLACEHOLDER FOR OTHER TABS =====
  Widget _placeholder(double width) {
    return Padding(
      padding: EdgeInsets.all(width * 0.05),
      child: Text(
        "Tab Content",
        style: GoogleFonts.dmSans(fontSize: width * 0.04),
      ),
    );
  }
}
