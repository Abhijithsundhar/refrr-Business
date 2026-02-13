import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/custom_appbar.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/theme/pallet.dart';

class WithdrawelScreen extends StatefulWidget {
  const WithdrawelScreen({super.key});

  @override
  State<WithdrawelScreen> createState() => _WithdrawelScreenState();
}

class _WithdrawelScreenState extends State<WithdrawelScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Withdrawal Requests'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: width * 0.04),

            /// LIST ITEMS
            _transactionItem(width, "INR 10000", "Raju has requested withdrawal of "),
            _transactionItem(width, "INR 10000", "Raju has requested withdrawal of "),
            _transactionItem(width, "INR 10000", "Raju has requested withdrawal of "),
            _transactionItem(width, "INR 10000", "Raju has requested withdrawal of "),
          ],
        ),
      ),
    );
  }

  /// REUSABLE ITEM WIDGET
  Widget _transactionItem(double w, String amount, String status) {
    return Padding(
      padding: EdgeInsets.only(
          left: w * 0.04, right: w * 0.04, bottom: w * 0.02),
      child: Container(
        padding: EdgeInsets.all(w * 0.03),
        decoration: BoxDecoration(
          color: Pallet.lightGreyColor,
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP SECTION
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: w * 0.05,
                  backgroundColor: Pallet.backgroundColor,
                  child: CircleAvatar(
                      radius: w * 0.045,
                      backgroundColor: Colors.white,
                      child: SvgPicture.asset(
                        AssetConstants.image,
                        width: w * 0.07,
                      )),
                ),

                SizedBox(width: w * 0.03),

                /// TEXT INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: GoogleFonts.dmSans(fontSize: w * 0.035),
                      ),
                      SizedBox(height: 4),
                      Text(
                        amount,
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: w * 0.05),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: w * 0.02),

            /// BOTTOM ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "2 days ago",
                  style: GoogleFonts.dmSans(
                    fontSize: w * 0.03,
                    color: Pallet.greyColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Reject',
                      style: GoogleFonts.dmSans(
                        color: Pallet.redColor,
                        fontSize: w * 0.035,
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Text(
                      'Accept',
                      style: GoogleFonts.dmSans(
                        color: Pallet.greenColor,
                        fontSize: w * 0.035,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
