import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/constants/sizedboxes.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/menu/edit-profile.dart';
import 'package:refrr_admin/models/leads_model.dart';

class ViewProfile extends StatelessWidget {
  final LeadsModel? currentFirm;
  const ViewProfile({super.key, this.currentFirm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SuggestAppBar(title: 'View Profile',
      // Padding(
      //   padding:  EdgeInsets.only(right: width*.03),
      //   child: GestureDetector(
      //     // onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(currentFirm: currentFirm,))),
      //     child: Container(
      //       width: width*.2,
      //       height: height*.045,
      //       decoration:  BoxDecoration(
      //         borderRadius: BorderRadiusGeometry.circular(30),
      //           border: Border.all( color: Pallet.borderColor)),
      //       child: Center(
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text('Edit',style: GoogleFonts.dmSans(fontWeight: FontWeight.w500,fontSize: width*.037,color: Pallet.greyColor),),
      //           AppSpacing.w01,
      //           SvgPicture.asset('assets/svg/account-edit-outline.svg',width:width*.05,),
      //         ],
      //                 ),
      //       ),),
      //   ),
      // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TOP CARD ----------
            Padding(
              padding:  EdgeInsets.only(left: width*.002,top: height*.02),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Padding(
                    padding:  EdgeInsets.only(left: width*.03),
                    child: SizedBox(
                      width: width * 0.35,
                      height: width * 0.25,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: currentFirm?.logo ?? '',
                          fit: BoxFit.cover, // use cover for natural scaling
                          placeholder: (context, url) => Center(child: CommonLoader()),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                   AppSpacing.w02,
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         currentFirm?.name??'',
                         style: GoogleFonts.dmSans(
                           fontSize: width * 0.05,
                           fontWeight: FontWeight.w700,
                           color: Colors.black,
                         ),
                       ),
                       Text(currentFirm?.zone??'',
                         style: GoogleFonts.dmSans(
                           fontSize: width * 0.037,
                           color: Colors.grey.shade600,
                         ),
                       ),
                       Text(currentFirm?.industry??'',
                         style: GoogleFonts.dmSans(
                           fontSize: width * 0.04,
                           color: Colors.grey.shade700,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ],
                   ),

                ],
              ),
            ),
            // ---------- DETAILS CARD ----------
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.025,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowItem('Country', 'Zone', currentFirm?.country??'', currentFirm?.zone??''),
                    const SizedBox(height: 14),
                    _rowItem(
                      'Currency Type',
                      'Website',
                      currentFirm?.currency??'',
                      currentFirm?.website??'',
                    ),
                    const SizedBox(height: 14),
                    _rowItem(
                      'Phone',
                      'Mail ID',
                      currentFirm?.contactNo??'',
                      currentFirm?.mail??'',
                    ),
                    const SizedBox(height: 18),
                    _singleItem(
                      title: 'Address',
                      value: currentFirm?.address??''
                    ),
                    const SizedBox(height: 18),
                    currentFirm!.aboutFirm.isEmpty? SizedBox():
                    _singleItem(
                      title: 'About',
                      value:currentFirm?.aboutFirm??'NIL'
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helper: two-column row ----------
  Widget _rowItem(
      String title1, String title2, String value1, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _singleItem(title: title1, value: value1)),
        SizedBox(width: width * 0.06),
        Expanded(child: _singleItem(title: title2, value: value2)),
      ],
    );
  }

  // ---------- Helper: single text block ----------
  Widget _singleItem({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: width * 0.033,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: height * 0.004),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: width * 0.037,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}