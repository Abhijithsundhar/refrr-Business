import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';

class TabHelpDesk extends StatefulWidget {
  const TabHelpDesk({super.key});

  @override
  State<TabHelpDesk> createState() => _TabHelpDeskState();
}

class _TabHelpDeskState extends State<TabHelpDesk> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: width * .9,
              height: height * .16,
              padding: EdgeInsets.all(width * .04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * .02),
                border: Border.all(
                  color: Pallet.greyColor.withOpacity(.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADING (Top Left)
                  Text(
                    "Zonal Admin",
                    style: GoogleFonts.dmSans(
                      fontSize: width * .04,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: height*.02,),
                  /// PHONE
                  Padding(
                    padding:  EdgeInsets.only(left: width*.05),
                    child: Row(
                      children: [
                        Text(
                          "Phone : ",
                          style: GoogleFonts.dmSans(
                            fontSize: width * .034,
                            color: Pallet.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "+91 85940 04464",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: width * .034,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: width * .015),

                  /// EMAIL
                  Padding(
                    padding:  EdgeInsets.only(left: width*.05),
                    child: Row(
                      children: [
                        Text(
                          "Email  : ",
                          style: GoogleFonts.dmSans(
                            fontSize: width * .034,
                            color: Pallet.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "zonaladmin@grro.ai",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: width * .034,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: width * .04),

            Container(
              width: width * .9,
              height: height * .16,
              padding: EdgeInsets.all(width * .04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * .02),
                border: Border.all(
                  color: Pallet.greyColor.withOpacity(.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADING (Top Left)
                  Text(
                    "Hiring Consultant",
                    style: GoogleFonts.dmSans(
                      fontSize: width * .04,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: height*.02,),
                  /// PHONE
                  Padding(
                    padding:  EdgeInsets.only(left: width*.05),
                    child: Row(
                      children: [
                        Text(
                          "Phone : ",
                          style: GoogleFonts.dmSans(
                            fontSize: width * .034,
                            color: Pallet.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "+91 85940 04461",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: width * .034,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: width * .015),

                  /// EMAIL
                  Padding(
                    padding:  EdgeInsets.only(left: width*.05),
                    child: Row(
                      children: [
                        Text(
                          "Email  : ",
                          style: GoogleFonts.dmSans(
                            fontSize: width * .034,
                            color: Pallet.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "hiringconsultant@grro.ai",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: width * .034,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: width * .04),

            Container(
              width: width * .9,
              height: height * .16,
              padding: EdgeInsets.all(width * .04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * .02),
                border: Border.all(
                  color: Pallet.greyColor.withOpacity(.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADING (Top Left)
                  Text(
                    "Reward Manager",
                    style: GoogleFonts.dmSans(
                      fontSize: width * .04,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: height*.02,),
                  /// PHONE
                  Padding(
                    padding:  EdgeInsets.only(left: width*.05),
                    child: Row(
                      children: [
                        Text(
                          "Phone : ",
                          style: GoogleFonts.dmSans(
                            fontSize: width * .034,
                            color: Pallet.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "+91 96052 09309",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: width * .034,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: width * .015),

                  /// EMAIL
                  Padding(
                    padding:  EdgeInsets.only(left: width*.05),
                    child: Row(
                      children: [
                        Text(
                          "Email  : ",
                          style: GoogleFonts.dmSans(
                            fontSize: width * .034,
                            color: Pallet.greyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "rewardmanager@grro.ai",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: width * .034,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
