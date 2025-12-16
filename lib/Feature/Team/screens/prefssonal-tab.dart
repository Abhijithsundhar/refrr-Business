import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';

class ProfessionalInfoTab extends StatelessWidget {
  const ProfessionalInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(width * 0.02),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(width * 0.03),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.03),
              color: Pallet.lightGreyColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoItem("Highest Qualification", "M COM"),
                Divider(),
                _infoItem("Current Job Title", "Marketer"),
                Divider(),
                _infoItem("Current Job Type", "Sales"),
                Divider(),
                _infoItem("Years of Experience", "3"),
              ],
            ),
          ),

          SizedBox(height: width * 0.02),

          Container(
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

                SizedBox(
                  width: width,
                  height: width * 0.5,
                  child: ListView.builder(
                    itemCount: 5,
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
                ),
              ],
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
