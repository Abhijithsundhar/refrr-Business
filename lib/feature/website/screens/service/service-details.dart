import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/constants/sizedboxes.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/website/screens/firm-person/select-firm.dart';
import 'package:refrr_admin/Feature/website/screens/service/edit-service.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services-model.dart';

class ServiceDetails extends StatefulWidget {
  final ServiceModel? service;
  final LeadsModel? currentFirm;

  const ServiceDetails({super.key, this.service, this.currentFirm});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {

  Future<void> handleDeleteService() async {
    try {
      final serviceRef = widget.service?.reference;

      if (serviceRef == null) {
        showCommonSnackbar(context, 'Invalid service');
        return;
      }
      // Delete the whole Firestore document directly
      await serviceRef.delete();

      if (mounted) {
        Navigator.pop(context); // close alert dialog
        Navigator.pop(context); // pop Edit screen
        showCommonSnackbar(context, 'Service deleted successfully');
      }
    } catch (e) {
      showCommonSnackbar(context, 'Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Service Details'),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: width * 0.25),
        child: Column(
          children: [
            SizedBox(height: width * 0.02),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  Container(
                    height: height * 0.3,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.02),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(width * 0.03),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: service?.image ?? '',
                      ),
                    ),
                  ),

                  AppSpacing.h01,

                  /// TITLE + DESCRIPTION
                  Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service?.name ?? '',
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: width * 0.02),
                        Text(
                          service?.description ?? '',
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.033,
                            color: Pallet.greyColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.h02,

                  /// COMMISSION & RANGE
                  Container(
                    padding: EdgeInsets.all(width * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(width * 0.02),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: width * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Commission",
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.032,
                                  color: Pallet.greyColor,
                                ),
                              ),
                              SizedBox(height: width * 0.02),
                              Text(
                                service?.commission ?? '',
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w700,
                                  color: Pallet.greenColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Range",
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.032,
                                  color: Pallet.greyColor,
                                ),
                              ),
                              SizedBox(height: width * 0.02),
                              Text(
                                (service?.endingPrice == null ||
                                    service!.endingPrice.toString().isNotEmpty)
                                    ? "${widget.currentFirm?.currency ?? ''} ${service?.startingPrice ?? ''}"
                                    : "${widget.currentFirm?.currency ?? ''} ${service.startingPrice ?? ''} - ${widget.currentFirm?.currency ?? ''} ${service.endingPrice}",
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.045,
                                  fontWeight: FontWeight.w700,
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
            ),
          ],
        ),
      ),

      // ---------- FIXED BOTTOM ACTION BAR ----------
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        decoration: BoxDecoration(
          color: Pallet.backgroundColor,
        ),
        child: Row(
          children: [
            // DELETE BUTTON
            GestureDetector(
              onTap: (){
                commonAlert(context, 'Delete Service','Are you sure want to Delete this Service?', 'Yes', (){
                  handleDeleteService();
                });
              },
              child: Container(
                height: height * 0.06,
                width: width * 0.13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallet.borderColor),
                  color: Colors.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/deleteRed.svg',
                    width: width * 0.07,
                  ),
                ),),
            ),
            AppSpacing.w02,

            // EDIT BUTTON
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditServiceScreen(service: service,currentFirm: widget.currentFirm,),));
              },
              child: Container(
                height: height * 0.06,
                width: width * 0.13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallet.borderColor),
                  color: Colors.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AssetConstants.edit,
                    width: width * 0.07,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.04),

            // ADD LEAD BUTTON
            Expanded(
              child: SizedBox(
                height: height * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectFirm(
                          lead: widget.currentFirm,
                          service: widget.service,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AssetConstants.add,
                        width: width * 0.045,
                        color: Colors.white,
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        "Add Lead",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
