import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/models/affiliate-model.dart';

class CareerTab extends StatelessWidget {
  final AffiliateModel affiliate;
  const CareerTab({super.key, required this.affiliate});

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
            _infoItem("Im an", affiliate.amAn.isNotEmpty?affiliate.amAn:'NIL'),
            Divider(color: Color(0XffE5E9EB)),
          _infoItem("Preferred Industry", affiliate.industry.isNotEmpty?affiliate.industry.join(' | '):'NIL',),
            Divider(color: Color(0XffE5E9EB)),
            _infoItem("Current Job Type", affiliate.preferenceJobType.isNotEmpty?affiliate.preferenceJobType:'NIL'),
            Divider(color: Color(0XffE5E9EB)),
            _infoItem("Previous Industry", affiliate.previousIndustry.isNotEmpty?affiliate.previousIndustry:'NIL'),
          ],
        ),
      ),
    );
  }

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
