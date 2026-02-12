import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Account/screens/lead-granded-page.dart';
import 'package:refrr_admin/Feature/Account/screens/marketers-page.dart';
import 'package:refrr_admin/Feature/Account/screens/money-credit-screen.dart';
import 'package:refrr_admin/Feature/Account/screens/withdrewal-page.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class AccountScreen extends StatefulWidget {
  final LeadsModel? currentFirm;
  final AffiliateModel? affiliate;
  const AccountScreen({super.key,this.currentFirm,
    this.affiliate});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String selectedValue = "Month";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'account',showBackButton: true,),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: height*.02,),

            /// Wallet Balance Card
        Padding(
          padding: EdgeInsets.only(
            left: width * 0.04,
            right: width * 0.04,
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MoneyCreditScreen()),
              );
            },
            child: Container(
              height: height * 0.116,
              width: width,
              decoration: BoxDecoration(
                color: Pallet.lightBlue,
                border: Border(
                  left: BorderSide(
                    color: Pallet.primaryColor,
                    width: width * 0.01,
                  ),
                  top: BorderSide(
                    color: Pallet.primaryColor,
                    width: width * 0.01,
                  ),
                ),
                borderRadius: BorderRadius.circular(width * 0.04),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// LEFT TEXTS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AED 1120",
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.005),
                          Text(
                            "Money Credited",
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.03,
                              color: Pallet.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// TOP RIGHT ICON
                    CircleSvgButton(
                      size: width*.115,
                      borderColor: Pallet.primaryColor,
                      bgColor: Pallet.primaryColor.withOpacity(.1),
                      child: SvgPicture.asset(
                        'assets/svg/save-money.svg',
                        width: width * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// Stats Cards
            Padding(
              padding: EdgeInsets.only(top: height*.02,left:  width * 0.04,right:  width * 0.04,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawelScreen(),));
                      },
                      child: _statCard(
                          "4",
                          "Withdrawal Request Pending",
                          CircleSvgButton(
                            size: width*.09,
                            borderColor: Pallet.primaryColor,
                            bgColor: Pallet.primaryColor.withOpacity(.1),
                            child: SvgPicture.asset('assets/svg/withdrawal.svg',
                              width: width * 0.05,
                            ),
                          ),
                          width,
                          height)),
                  InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MarketersAddedScreen(),));
                      },
                      child: _statCard(
                          "23",
                          "Marketers\nAdded",
                          CircleSvgButton(
                            size: width*.09,
                            borderColor: Pallet.primaryColor,
                            bgColor: Pallet.primaryColor.withOpacity(.1),
                            child: SvgPicture.asset('assets/svg/account-group-outline.svg',
                              width: width * 0.05,
                            ),
                          ),
                          width, height)),
                  InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LeadGrandedScreen(),));
                      },
                      child: _statCard(
                          "56",
                          "Leads\nGenerated",
                          CircleSvgButton(
                            size: width*.09,
                            borderColor: Pallet.primaryColor,
                            bgColor: Pallet.primaryColor.withOpacity(.1),
                            child: SvgPicture.asset('assets/svg/account-multiple-check-outline.svg',
                              width: width * 0.05,
                            ),
                          ),
                          width,
                          height)),
                ],
              ),
            ),

            SizedBox(height: width * 0.08),

            /// Plan Section
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(
                    color:Color(0xFF1AE0ED).withOpacity(.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: width * 0.09,
                    width: double.infinity,
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("  Basic Plan",
                            style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.036)),
                        Padding(
                          padding:  EdgeInsets.only(left: width*.03),
                          child: Container(
                            width: width * 0.18,
                            height: width * 0.06,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(width * 0.08),
                            ),
                            child: Center(
                              child: Text(
                                'Upgrade',
                                style: GoogleFonts.dmSans(
                                    fontSize: width * 0.03,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Plan features
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05,
                        bottom: width * 0.005,
                        top: width * 0.02),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/svg/blueTick.svg',
                            width: width * 0.04),
                        SizedBox(width: width*.01,),
                        Text(
                          "Maximum 10 Marketers can be added",
                          style: GoogleFonts.dmSans(
                              fontSize: width * 0.035, color: Pallet.greyColor),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, bottom: width * 0.02),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/svg/globe.svg',
                            width: width * 0.055),
                        SizedBox(width: width*.01,),
                        Text("Country : ",
                            style: GoogleFonts.dmSans(
                                fontSize: width * 0.035,
                                color: Pallet.greyColor)),
                        Text("Dubai",
                            style: GoogleFonts.dmSans(
                                fontSize: width * 0.035,
                                color: Pallet.greyColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: width * 0.05),

            /// Graph Section
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Container(
                padding: EdgeInsets.all(width * 0.03),
                width: width,
                height: height * 0.45,
                decoration: BoxDecoration(
                  border: Border.all(color: Pallet.borderColor),
                  borderRadius: BorderRadius.circular(width * 0.05),
                  color: Pallet.lightGreyColor,
                ),

                /// Graph + Filter + Labels
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Filter (Month / Week / Day)
                    Container(
                      height: height*.05,
                      width: width * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Radio<String>(
                            value: "Month",
                            groupValue: selectedValue,
                            fillColor:
                            WidgetStatePropertyAll(Pallet.primaryColor),
                            onChanged: (value) =>
                                setState(() => selectedValue = value!),
                          ),
                          Text("Month",
                              style:
                              GoogleFonts.dmSans(fontSize: width * 0.03)),
                          SizedBox(width: width * 0.001),

                          Radio<String>(
                            value: "Week",
                            groupValue: selectedValue,
                            fillColor:
                            WidgetStatePropertyAll(Pallet.primaryColor),
                            onChanged: (value) =>
                                setState(() => selectedValue = value!),
                          ),
                          Text("Week",
                              style:
                              GoogleFonts.dmSans(fontSize: width * 0.03)),
                          SizedBox(width: width * 0.001),

                          Radio<String>(
                            value: "Day",
                            groupValue: selectedValue,
                            fillColor:
                            WidgetStatePropertyAll(Pallet.primaryColor),
                            onChanged: (value) =>
                                setState(() => selectedValue = value!),
                          ),
                          Text("Day", style:
                              GoogleFonts.dmSans(fontSize: width * 0.03)),
                        ],
                      ),
                    ),

                    SizedBox(height: width * 0.1),

                    /// Bar Chart
                    SizedBox(
                      height: height * 0.3,
                      child: BarChart(
                        BarChartData(
                          maxY: 30,
                          minY: 0,
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: BorderSide(
                                  color: Colors.black, width: width * 0.005),
                              bottom: BorderSide(
                                  color: Colors.black, width: width * 0.005),
                            ),
                          ),
                          gridData: FlGridData(show: false),

                          /// Axis labels
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) {
                                    return Text("0",
                                        style: GoogleFonts.dmSans(
                                            fontSize: width * 0.03));
                                  }
                                  if (value == 10) {
                                    return Text("10 k",
                                        style: GoogleFonts.dmSans(
                                            fontSize: width * 0.03));
                                  }
                                  if (value == 20) {
                                    return Text("20 k",
                                        style: GoogleFonts.dmSans(
                                            fontSize: width * 0.03));
                                  }
                                  if (value == 30) {
                                    return Text("30 k",
                                        style: GoogleFonts.dmSans(
                                            fontSize: width * 0.03));
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const labels = [
                                    "JAN",
                                    "FEB",
                                    "MAR",
                                    "APR",
                                    "MAY",
                                    "JUN",
                                    "JUL"
                                  ];
                                  if (value.toInt() < labels.length) {
                                    return Text(labels[value.toInt()],
                                        style: GoogleFonts.dmSans(
                                            fontSize: width * 0.03));
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),

                          /// Bars
                          barGroups: List.generate(7, (i) {
                            final heights = [10, 25, 17, 8, 12, 25, 1];
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: heights[i].toDouble(),
                                  color: Pallet.primaryColor,
                                  width: width * 0.05,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(width * 0.002),
                                    topRight: Radius.circular(width * 0.002),
                                  ),
                                )
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stat Card
  Widget _statCard(
      String value, String title, Widget icon, double width, double height) {
    return Container(
      height: height * 0.11,
      width: width * 0.3,
      padding: EdgeInsets.all(width * 0.02),
      decoration: BoxDecoration(
        color: Pallet.lightBlue,
        border: Border(
          left: BorderSide(color: Pallet.primaryColor, width: width * 0.008),
          top: BorderSide(color: Pallet.primaryColor, width: width * 0.008),
        ),
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: GoogleFonts.dmSans(
                      fontSize: width * 0.06, fontWeight: FontWeight.bold)),
              icon,
            ],
          ),
          Expanded(
            child: SizedBox(
              width: width * 0.24,
              child: Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: width * 0.028, color: Pallet.greyColor)),
            ),
          ),
        ],
      ),
    );
  }
}
