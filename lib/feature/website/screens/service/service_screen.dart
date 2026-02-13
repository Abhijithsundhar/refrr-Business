import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/website/screens/firm_person/select_firm.dart';
import 'package:refrr_admin/feature/website/screens/service/service_details.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:refrr_admin/models/services_model.dart';

class ServicesSection extends StatelessWidget {
  final LeadsModel? currentFirm;
  final List<ServiceModel> services;
  const ServicesSection(
      {required this.currentFirm, required this.services, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final s = services[i];
        return GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ServiceDetails(service: s, currentFirm: currentFirm),
              ),
            );
          },
          child:Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Pallet.greyColor.withOpacity(0.1),
              border: BoxBorder.all(color: Pallet.greyColor.withOpacity(.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: s.image,
                    height: height * 0.18,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.045)),
                      Text(s.description,
                          style: GoogleFonts.dmSans(
                              color: Pallet.greyColor, fontSize: width * 0.032)),
                      const SizedBox(height: 4),
                      Text("Commission: ${s.commission}",
                          style: GoogleFonts.dmSans(
                              color: Pallet.greenColor,
                              fontWeight: FontWeight.w500,
                              fontSize: width * 0.03)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              minWidth: height * 0.2,
                              minHeight: height * 0.045,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.005,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.05),
                              border: Border.all(color: Pallet.borderColor),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              // 👇 If endingPrice exists and isn't empty/null, show both; otherwise only start
                              (s.endingPrice.toString().isEmpty)
                                  ? "${currentFirm?.currency ?? ''} ${s.startingPrice} - ${currentFirm?.currency ?? ''} ${s.endingPrice}"
                                  : "${currentFirm?.currency ?? ''} ${s.startingPrice}",
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.035,
                                color: const Color(0xff151515),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SelectFirm(lead: currentFirm, service: s),
                              ),
                            ),
                            child: Container(
                              height: height * .04,
                              width: width * .28,
                              decoration: BoxDecoration(
                                color: Pallet.secondaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AssetConstants.add,
                                      width: width * 0.04),
                                  const SizedBox(width: 4),
                                  Text("Add Lead",
                                      style: GoogleFonts.dmSans(
                                          color: Pallet.backgroundColor,
                                          fontSize: width * 0.03,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );
  }
}
