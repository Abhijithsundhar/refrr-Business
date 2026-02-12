import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/promote/controller/offers-controller.dart';
import 'package:refrr_admin/Feature/promote/screens/offer/add-offer.dart';
import 'package:refrr_admin/Feature/promote/screens/offer/offer-details.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:intl/intl.dart';


class OfferScreen extends StatefulWidget {
  final LeadsModel? currentFirm;
  const OfferScreen({super.key, required this.currentFirm});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {

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
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: Column(
        children: [
          SizedBox(height: width * 0.02),

          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
              final offers =   ref.watch(offerStreamProvider(''));
              return offers.when(
                  data: (data) {
                    final firmId = widget.currentFirm?.reference?.id;
                    final filteredOffers = data.where((offer) {
                      return firmId != null && offer.addedBy == firmId;
                    }).toList();
                    if (filteredOffers.isEmpty) {
                      return const Center(
                        child: Text('No offer added'),
                      );
                    }
                    return  ListView.builder(
                      padding: EdgeInsets.all(width * 0.01),
                      itemCount: filteredOffers.length,
                      itemBuilder: (_, i) {
                        final offer = filteredOffers[i];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OfferDetailsScreen( offer:offer),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.02),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Pallet.greyColor.withOpacity(.1)),
                                borderRadius: BorderRadius.circular(width * 0.03),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(width * 0.03),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(offer.name??'',
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: width * 0.04,
                                          ),
                                        ),
                                        Text(
                                          "${offer.currency} ${offer.amount}",
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: width * 0.05,
                                            color: Pallet.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: width * 0.02),

                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(width * 0.03),
                                      child: CachedNetworkImage(
                                        height: height * 0.2,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        imageUrl: offer.image??'',
                                      ),
                                    ),

                                    SizedBox(height: width * 0.02),

                                    Text(offer.description??'',
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w500,
                                        fontSize: width * 0.03,
                                        color: Pallet.greyColor,
                                      ),
                                    ),

                                    SizedBox(height: width * 0.02),

                                    GestureDetector(
                                      // onTap: () => pickDate(context),
                                      child: Container(
                                        width: width * 0.5,
                                        height: width * 0.1,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(width * 0.05),
                                          border:
                                          Border.all(color: Pallet.borderColor),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/svg/calendarOff.svg',
                                              width: width * 0.04,
                                            ),
                                            SizedBox(width: width * 0.02),
                                            Text(
                                              "Valid Unit : ",
                                              style: GoogleFonts.dmSans(
                                                fontSize: width * 0.035,
                                                color: Pallet.greyColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(offer.endDate),
                                              style: GoogleFonts.dmSans(
                                                fontSize: width * 0.035,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.all(width * 0.02),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () => showAddOffersBottomSheet(context,widget.currentFirm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallet.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: width * 0.01,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AssetConstants.add,
                      width: width * 0.04,
                    ),
                    SizedBox(width: width * 0.008),
                    Text(
                      "Add New Offers",
                      style: GoogleFonts.dmSans(
                        color: Pallet.backgroundColor,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
