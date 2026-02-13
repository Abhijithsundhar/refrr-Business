import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Wallet",
          style: GoogleFonts.dmSans(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(w * 0.02),
              child: Row(
                children: [
                  Expanded(
                    child: _amountCard(
                      w,
                      "Amount Credited",
                      "120 AED",
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  Expanded(
                    child: _amountCard(
                      w,
                      "Amount Withdrawn",
                      "120 AED",
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(w * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Money Requests",
                    style: GoogleFonts.dmSans(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      width: w * 0.2,
                      height: w * 0.07,
                      decoration: BoxDecoration(
                        border: Border.all(color: Pallet.borderColor),
                        borderRadius: BorderRadius.circular(w * 0.05),
                      ),
                      child: Center(
                        child: Text(
                          "View All",
                          style: GoogleFonts.dmSans(
                            fontSize: w * 0.03,
                            color: Pallet.greyColor,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            _moneyRequestItem(w, "INR 10000", "2 Days Ago"),
            _moneyRequestItem(w, "INR 7500", "12/11/2025"),
            _moneyRequestItem(w, "INR 7500", "12/11/2025"),
            _moneyRequestItem(w, "INR 7500", "12/11/2025"),
            _moneyRequestItem(w, "INR 4300", "2 Days Ago"),
          ],
        ),
      ),
    );
  }
  Widget _amountCard(double w,String title, String value, Color color) {
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

  Widget _moneyRequestItem(double w,String amount, String date) {
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

