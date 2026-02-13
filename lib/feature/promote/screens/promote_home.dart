import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/custom_appBar.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/Login/screens/connectivity.dart';
import 'package:refrr_admin/feature/promote/screens/creatives/creative_screen.dart';
import 'package:refrr_admin/feature/promote/screens/offer/offer_screen.dart';
import 'package:refrr_admin/models/leads_model.dart';

class PromoteScreen extends StatefulWidget {
  final LeadsModel? currentFirm;
  const PromoteScreen({super.key, this.currentFirm});

  @override
  State<PromoteScreen> createState() => _PromoteScreenState();
}

class _PromoteScreenState extends State<PromoteScreen> {
     // show loader until images ready

  @override
  void initState() {
    super.initState();
    creatives = true;

    // Wait for first frame; then precache images using safe context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImagesAndShow();
    });
  }

  Future<void> _preloadImagesAndShow() async {
    final images = [
      // const AssetImage('assets/images/sample1.png'),
      // const AssetImage('assets/images/sample2.png'),
      // const AssetImage('assets/images/sample3.png'),
    ];

    try {
      for (final img in images) {
        await precacheImage(img, context);
      }
    } catch (e) {
      debugPrint('⚠️  Image preload failed: $e');
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;

    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Pallet.backgroundColor,
        appBar: const CustomAppBar(
          title: 'Promote',
          showBackButton: false,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: isLoading
              ? Center(
            key: const ValueKey('loader'),
            child: CircularProgressIndicator(color: Pallet.primaryColor),
          )
              : Column(
            key: const ValueKey('content'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: w * 0.03),
              _buildToggleButtons(w),
              SizedBox(height: w * 0.03),
              Expanded(
                child: creatives
                    ? CreativeScreen(currentFirm: widget.currentFirm)
                    : OfferScreen(currentFirm: widget.currentFirm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Buttons switching between Creatives & Offers ---
  Widget _buildToggleButtons(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .04),
      child: Container(
        height: width * .1,
        decoration: BoxDecoration(
          color: Pallet.lightBlue,
          borderRadius: BorderRadius.circular(width * .07),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(width * .07),
                onTap: () => setState(() => creatives = true),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: creatives ? Pallet.lightBlue : Colors.transparent,
                    border: Border.all(
                      color: creatives
                          ? Pallet.primaryColor
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(width * .07),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/creatives.svg',
                        color: Colors.black,
                      ),
                      SizedBox(width: width * .005),
                      Text(
                        'Creatives',
                        style: GoogleFonts.dmSans(
                          color: creatives
                              ? Pallet.secondaryColor
                              : Pallet.greyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: width * .035,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(width * .07),
                onTap: () => setState(() => creatives = false),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !creatives ? Pallet.lightBlue : Colors.transparent,
                    border: Border.all(
                      color: !creatives
                          ? Pallet.primaryColor
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(width * .07),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svg/offers.svg',
                          color: Colors.black),
                      SizedBox(width: width * .005),
                      Text('Offers',
                        style: GoogleFonts.dmSans(
                          color: !creatives
                              ? Pallet.secondaryColor
                              : Pallet.greyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: width * .035,
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
