import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Team/screens/career-tab.dart';
import 'package:refrr_admin/Feature/Team/screens/personal-info-tab.dart';
import 'package:refrr_admin/Feature/Team/screens/pipleLine-tab.dart';
import 'package:refrr_admin/Feature/Team/screens/prefssonal-tab.dart';
import 'package:refrr_admin/models/affiliate-model.dart';


class AccountProfileScreen extends StatefulWidget {
  final AffiliateModel affiliate;
  const AccountProfileScreen({super.key, required this.affiliate});

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}
class _AccountProfileScreenState extends State<AccountProfileScreen> {

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    double  w = width;double  h = height;
    final affiliate = widget.affiliate;
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            SizedBox(
              height: h*0.23,
              child: Stack(
                children: [
                  Container(
                    height: h*0.15,
                    color:Color(0xFFE9FCFE),
                    child: Row(
                      children: [
                        SizedBox(width: width*.05,),
                        CircleIconButton(size: width*.08,icon: Icons.arrow_back_ios_new, onTap: () { Navigator.pop(context); },),
                        const Spacer(),
                        CircleSvgButton(size: width*.08,child: SvgPicture.asset('assets/svg/blackphone.svg',width: w*0.04,), ),
                        SizedBox(width: w*0.025,),
                        CircleSvgButton(size: width*.08,child: SvgPicture.asset('assets/svg/whatsappBlaack.svg',width: w*0.05,), ),
                        SizedBox(width: w*0.025,),
                        CircleSvgButton(size: width*.08,child: SvgPicture.asset('assets/svg/more.svg',width: w*0.04,), ),
                        SizedBox(width: width*.06,),
                      ],
                    ),
                  ),
                  Positioned(
                    left: w*0.07,top: w*0.21,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: h*0.061,
                          backgroundColor: Pallet.backgroundColor,
                          child: CircleAvatar(
                            radius: h*0.6,
                            backgroundImage: NetworkImage(affiliate.profile??''),
                          ),
                        ),
                        SizedBox(width: w*0.025),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: w*0.04),

                            Text(affiliate.name,
                                style: GoogleFonts.dmSans(
                                    fontSize: w*0.04, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                SvgPicture.asset(AssetConstants.location,width: width*.03,),
                                SizedBox(width: w*0.005),
                                Text("${affiliate.zone} ${affiliate.country}",
                                    style: GoogleFonts.dmSans(
                                        fontSize: w*0.025, color: Pallet.greyColor)),
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

            SizedBox(height: w*0.02),

            // ===== STAT CARDS =====
            Padding(
              padding: EdgeInsets.all(w*0.02),
              child: Row(
                children: [
                  _statBox("Total Leads", "15"),
                  _statBox("LQ", "100 %"),
                  _statBox("Total Agents", "10"),
                ],
              ),
            ),

            // ===== TAB BAR =====
            Padding(
              padding: EdgeInsets.only(left: w*0.02,top: w*0.01,bottom: w*0.01),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: Container(
                  height: w*0.1,
                  width: h*0.68,
                  decoration: BoxDecoration(
                    color: Pallet.lightBlue,
                    borderRadius: BorderRadius.circular(w*0.05),
                  ),
                  child: Row(
                    children: [
                      _tabItem("Account", 0),
                      _tabItem("Pipeline", 1),
                      _tabItem("Personal Info", 2),
                      _tabItem("Professional Info", 3),
                      _tabItem("Career Preference", 4),
                    ],
                  ),
                ),
              ),
            ),



            // ===== AMOUNT CARDS =====
            selectedTab==0? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(w*0.02),
                    child: Row(
                      children: [
                        Expanded(child: _amountCard("Amount Credited", "120 AED", Colors.green)),
                        SizedBox(width: w*0.02),
                        Expanded(child: _amountCard("Amount Withdrawn", "120 AED", Colors.red)),
                      ],
                    ),
                  ),


                  // ===== MONEY REQUESTS =====
                  Padding(
                    padding: EdgeInsets.all(w*0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Money Requests",
                            style: GoogleFonts.dmSans(
                                fontSize: w*0.045, fontWeight: FontWeight.bold)),
                        InkWell(
                            onTap: () {}, child: Container(
                            width: w*0.2,
                            height: w*0.07,
                            decoration: BoxDecoration(border: Border.all(color: Pallet.borderColor),borderRadius: BorderRadius.circular(w*0.05)),
                            child: Center(child: Text("View All",style: GoogleFonts.dmSans(fontSize: w*0.03,color: Pallet.greyColor),))))
                      ],
                    ),
                  ),

                  _moneyRequestItem("INR 10000", "2 Days Ago"),
                  _moneyRequestItem("INR 7500", "12/11/2025"),
                  _moneyRequestItem("INR 7500", "12/11/2025"),
                  _moneyRequestItem("INR 7500", "12/11/2025"),
                  _moneyRequestItem("INR 4300", "2 Days Ago"),

                ])
                :selectedTab==1?PipelineTab()
                :selectedTab==2?PersonalInfoTab()
                :selectedTab==3?ProfessionalInfoTab()
                :CareerTab(),
          ],
        ),
      ),
    );
  }

  // ===== Widgets =====

  Widget _statBox(String title, String value) {
    return Container(
      width: width * 0.15,
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
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.03,
              color: Pallet.greyColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool active = selectedTab == index;
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
              color: active
                  ? Pallet.secondaryColor
                  : Pallet.greyColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _amountCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.only(
        left: width * 0.02,
        top: width * 0.02,
      ),
      decoration: BoxDecoration(
        color: Pallet.backgroundColor,
        borderRadius: BorderRadius.circular(width * 0.02),
        border: Border.all(color: Pallet.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.03,
              color: Pallet.greyColor,
            ),
          ),
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
              Align(
                alignment: Alignment.bottomRight,
                child: SvgPicture.asset(AssetConstants.cashImg),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moneyRequestItem(String amount, String date) {
    return Padding(
      padding: EdgeInsets.only(
        left: width * 0.02,
        right: width * 0.02,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: width * 0.02),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.02,
          vertical: width * 0.04,
        ),
        decoration: BoxDecoration(
          color: Pallet.lightGreyColor,
          borderRadius: BorderRadius.circular(width * 0.02),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Pallet.greyColor,
                  ),
                ),
                SizedBox(height: width * 0.02),
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.03,
                    color: Pallet.greyColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              "Reject",
              style: GoogleFonts.dmSans(
                color: Pallet.redColor,
                fontSize: width * 0.03,
              ),
            ),
            SizedBox(width: width * 0.02),
            Text(
              "Accept",
              style: GoogleFonts.dmSans(
                color: Pallet.greenColor,
                fontSize: width * 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }

}