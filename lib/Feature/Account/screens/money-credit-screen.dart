import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';

class MoneyCreditScreen extends StatefulWidget {
  const MoneyCreditScreen({super.key});

  @override
  State<MoneyCreditScreen> createState() => _MoneyCreditScreenState();
}

class _MoneyCreditScreenState extends State<MoneyCreditScreen> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Money Credited'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height*.02 ,),
            /// TOTAL MONEY
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Text(
                "Total Money Credited",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  color: Pallet.greyColor,
                  fontSize: w * 0.035,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Text(
                "AED 1120",
                style: GoogleFonts.dmSans(
                    fontSize: w * 0.06, fontWeight: FontWeight.w500),
              ),
            ),

            SizedBox(height: w * 0.05),

            /// LIST ITEMS
            _transactionItem(w, "AED 250", "Withdrawn"),
            _transactionItem(w, "AED 300", "Credited"),
            _transactionItem(w, "AED 450", "Withdrawn"),
            _transactionItem(w, "AED 120", "Credited"),
          ],
        ),
      ),
    );
  }

  /// TRANSACTION ITEM
  Widget _transactionItem(double w, String amount, String status) {
    return Padding(
      padding: EdgeInsets.only(left: w * 0.04, right: w * 0.04, bottom: w * 0.01),
      child: Container(
        height: height * .1,
        padding: EdgeInsets.symmetric(horizontal: w * 0.03),
        decoration: BoxDecoration(
          color: Pallet.lightGreyColor,
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// AMOUNT TEXT
            Text(
              amount,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: w * 0.05,
              ),
            ),

            SizedBox(height: w * 0.01),

            /// DAYS + STATUS ROW
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
                Text(
                  status,
                  style: GoogleFonts.dmSans(
                    fontSize: w * 0.035,
                    color: status == 'Credited'
                        ? Pallet.greenColor
                        : Pallet.redColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
