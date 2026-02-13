import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/models/affiliate_model.dart';

class PersonalInfoTab extends StatelessWidget {
  final AffiliateModel affiliate;
  const PersonalInfoTab({super.key, required this.affiliate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left:width * 0.04,right:width * 0.04),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.03),
          color: Pallet.lightGreyColor.withOpacity(.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- Row 1 ----------
            _infoItem("Name", affiliate.name),
             Divider(color: Color(0XffE5E9EB)),
            _infoItem("Gender", affiliate.gender),
            Divider(color: Color(0XffE5E9EB)),
            _infoItem("Country", affiliate.country),
            Divider(color: Color(0XffE5E9EB)),
            _infoItem("Phone No.", "+91 ${affiliate.phone}"),
            Divider(color: Color(0XffE5E9EB)),
            _infoItem("E Mail", affiliate.mailId.isNotEmpty ?affiliate.mailId:'NIL'),
            Divider(color: Color(0XffE5E9EB)),
            _infoItem("Age", affiliate.age != 0 ? affiliate.age.toString():'NIL'),
            Divider(color: Color(0XffE5E9EB)),

            /// ---------- More Info ----------
            Text("More Info",
              style: GoogleFonts.dmSans(
                fontSize: width * 0.03,
                color: Pallet.greyColor,
              ),
            ),
            SizedBox(height: width * 0.005),
            Text(affiliate.moreInfo.isNotEmpty? affiliate.moreInfo :'NIL' ,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: width * 0.01),
          ],
        ),
      ),
    );
  }

  /// Small text widget
  Widget _infoItem(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height*.01,),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: width * 0.033,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6E7C87),
          ),
        ),
        SizedBox(height: width * 0.005),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
