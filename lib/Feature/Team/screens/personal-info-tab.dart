import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';



class PersonalInfoTab extends StatelessWidget {
  const PersonalInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(width * 0.02),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.03),
          color: Pallet.lightGreyColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- Row 1 ----------
            _infoItem("Name", "Aleena"),
            const Divider(),
            _infoItem("Gender", "Female"),
            const Divider(),
            _infoItem("Country", "India"),
            const Divider(),
            _infoItem("Phone No.", "+91 98987 76765"),
            const Divider(),
            _infoItem("E Mail", "aleena123@gmail.com"),
            const Divider(),
            _infoItem("Age", "23"),
            const Divider(),

            /// ---------- More Info ----------
            Text(
              "More Info",
              style: GoogleFonts.dmSans(
                fontSize: width * 0.03,
                color: Pallet.greyColor,
              ),
            ),
            SizedBox(height: width * 0.005),
            Text(
              "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
              style: GoogleFonts.dmSans(
                fontSize: width * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: width * 0.03,
            color: Pallet.greyColor,
          ),
        ),
        SizedBox(height: width * 0.005),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: width * 0.035,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
