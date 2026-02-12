import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/models/offer-model.dart';



class OfferDetailsScreen extends StatefulWidget {
  final OfferModel? offer;
  const OfferDetailsScreen({super.key, this.offer});

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {

  Future<void> pickDate(BuildContext context) async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (newDate != null) {
      print("Selected Date: $newDate");
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Offers'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP BAR
          SizedBox(height: width * 0.02),

          Padding(
            padding: EdgeInsets.all(width * 0.03),
            child: Container(
              height: height * 0.3,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.02),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.05),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: offer?.image??'',
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + Edit icon
                Row(
                  children: [
                    Text(offer?.name??'',
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(width: width * 0.005),
                    // InkWell(
                    //   child: SvgPicture.asset(
                    //     AssetConstants.edit,
                    //     width: width * 0.05,
                    //   ),
                    // ),
                  ],
                ),

                SizedBox(height: width * 0.01),

                Text(
                  "${offer?.currency} ${offer?.amount}",
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Pallet.primaryColor,
                  ),
                ),

                SizedBox(height: width * 0.02),

                Text(offer?.description??'',
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                    color: Pallet.greyColor,
                  ),
                ),

                SizedBox(height: width * 0.03),

                Container(
                    width: width * 0.6,
                    height: width * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.05),
                      border: Border.all(color: Pallet.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AssetConstants.calendar,
                          width: width * 0.05,
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          "Valid Unit : ",
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: width * 0.003),
                        Text(DateFormat('dd/MM/yyyy').format(offer!.endDate),
                          style: TextStyle(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.005),
      child: Row(
        children: [
          SvgPicture.asset(
            AssetConstants.star,
            width: width * 0.013,
          ),
          SizedBox(width: width * 0.01),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: width * 0.01),
            ),
          ),
        ],
      ),
    );
  }
}
