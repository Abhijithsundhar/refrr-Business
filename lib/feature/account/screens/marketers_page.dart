import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/custom_appbar.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/theme/pallet.dart';

class MarketersAddedScreen extends StatefulWidget {
  const MarketersAddedScreen({super.key});

  @override
  State<MarketersAddedScreen> createState() => _MarketersAddedScreenState();
}

class _MarketersAddedScreenState extends State<MarketersAddedScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Marketers Added'),
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          width * 0.04,
          width * 0.04,
          width * 0.04,
          width * 0.15,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: width * 0.03,
          mainAxisSpacing: width * 0.03,
        ),
        itemCount: 8,
        itemBuilder: (_, i) {
          return InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(width * 0.03),
                border: Border.all(color: Pallet.borderColor),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: width * 0.061,
                      backgroundColor: Pallet.backgroundColor,
                      child: CircleAvatar(
                        radius: width * 0.06,
                        child: SvgPicture.asset(AssetConstants.image),
                      ),
                    ),

                    SizedBox(height: width * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Aleena kk",
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.045,
                          ),
                        ),
                        SizedBox(width: width * 0.01),
                        SvgPicture.asset(
                          'assets/svg/verify.svg',
                          width: width * 0.05,
                        ),
                      ],
                    ),

                    SizedBox(height: width * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/location.svg',
                          width: width * 0.04,
                        ),
                        SizedBox(width: width * 0.01),
                        Text(
                          "Malappuram, Kerala",
                          style: GoogleFonts.dmSans(
                            color: Pallet.greyColor,
                            fontSize: width * 0.03,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: width * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Total Leads :",
                          style: GoogleFonts.dmSans(
                            color: Pallet.greyColor,
                            fontSize: width * 0.03,
                          ),
                        ),
                        SizedBox(width: width * 0.005),
                        Text(
                          "13",
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: width * 0.02),

                    Container(
                      width: width * 0.2,
                      padding: EdgeInsets.all(width * 0.025),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.05),
                        color: Pallet.backgroundColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "LQ :",
                            style: GoogleFonts.dmSans(
                              color: Pallet.greyColor,
                              fontSize: width * 0.03,
                            ),
                          ),
                          SizedBox(width: width * 0.005),
                          Text(
                            "100%",
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

  }
}
