import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/models/affiliate_model.dart';

class ProfessionalInfoTab extends StatelessWidget {
  final AffiliateModel affiliate;
  const ProfessionalInfoTab({super.key, required this.affiliate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(width * 0.02),
      child: Column(
        children: [
          Padding(
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
                  _infoItem("Highest Qualification", affiliate.qualification.isNotEmpty?affiliate.qualification:'NIL'),
                  Divider(color: Color(0XffE5E9EB)),
                  _infoItem("Current Job Title", affiliate.currentJobTitle.isNotEmpty?affiliate.currentJobTitle:'NIL'),
                  Divider(color: Color(0XffE5E9EB)),
                  _infoItem("Current Job Type", affiliate.currentJobType.isNotEmpty?affiliate.currentJobType:'NIL'),
                  Divider(color: Color(0XffE5E9EB)),
                  _infoItem("Years of Experience",affiliate.experience.isNotEmpty?affiliate.experience:'NIL'),
                ],
              ),
            ),
          ),
          SizedBox(height: width * 0.03),
          Padding(
            padding: EdgeInsets.only(left:width * 0.04,right:width * 0.04),
            child: Container(
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.03),
                color: Pallet.lightGreyColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Job History",
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.04,
                      color: Pallet.greyColor,
                    ),
                  ),

                  SizedBox(height: width * 0.02),
                  ListView.builder(
                    itemCount: affiliate.jobHistory.length,
                    shrinkWrap: true, // ✅ KEY
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: width * 0.02),
                        child: Container(
                          padding: EdgeInsets.all(width * 0.01),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * 0.02),
                            border: Border.all(color: Pallet.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marketers',
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: width * 0.02),
                              Row(
                                children: [
                                  Text(
                                    'Years of Experience : ',
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * 0.03,
                                      color: Pallet.greyColor,
                                    ),
                                  ),
                                  Text(
                                    '2',
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * 0.03,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: width * 0.02),
                              Row(
                                children: [
                                  Text(
                                    'Industry : ',
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * 0.03,
                                      color: Pallet.greyColor,
                                    ),
                                  ),
                                  Text(
                                    'Sales',
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * 0.03,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
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
