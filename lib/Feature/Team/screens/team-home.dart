import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';

import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';

import 'package:refrr_admin/Feature/Team/screens/hire-page.dart';
import 'package:refrr_admin/Feature/Team/screens/profile-home.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/Team/screens/profile.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';

import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class TeamHome extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const TeamHome({super.key, this.currentFirm});

  @override
  ConsumerState<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends ConsumerState<TeamHome> {
  String activeFilter = 'All';
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final teamAsync =
    ref.watch(teamProvider(widget.currentFirm!.reference!.id));
    final serviceLeadAsync = ref.watch(serviceLeadsStreamProvider);

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
            appBar: CustomAppBar(
              title: 'Our Team (02)',
              showBackButton: false,
              actionWidget: Padding(
                padding: EdgeInsets.only(right: width * 0.04),
                child: Container(
                  height: height*.045,
                  width: width*.36,
                  decoration: BoxDecoration(
                    color: Pallet.lightGreyColor,
                    borderRadius: BorderRadius.circular(width * 0.025),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AssetConstants.addStaff,
                          width: width * 0.05,
                        ),
                        SizedBox(width: width * 0.015),
                        Text(
                          'Add Own Staff',
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w400,
                            color: Pallet.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

        body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: width * 0.02),
            /// 🔹 TEAM GRID
            Expanded(
              child: teamAsync.when(
                data: (team) {
                  List<AffiliateModel> filtered = List.from(team);

                  if (activeFilter == 'Location' &&
                      selectedLocation != null) {
                    filtered = filtered
                        .where((e) =>
                    e.zone.toLowerCase() ==
                        selectedLocation!.toLowerCase())
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No team members found'));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(width * 0.03),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: width * 0.03,
                      mainAxisSpacing: width * 0.03,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final affiliate = filtered[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AccountProfileScreen(affiliate: affiliate),),);
                        },
                        child: _teamCard(affiliate),
                      );
                    },
                  );
                },
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),

      /// 🔹 HIRE BUTTON (NEW UI)
      floatingActionButton: SizedBox(
        height: height*.06,
        width: width * 0.3,
        child: InkWell(
          borderRadius: BorderRadius.circular(width * 0.02),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HirePage(
                  serviceLead: serviceLeadAsync,
                  affiliate: ref.watch(affiliateStreamProvider('')),
                  currentFirm: widget.currentFirm,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: width * 0.025,
            ),
            decoration: BoxDecoration(
              color: Pallet.primaryColor,
              borderRadius: BorderRadius.circular(width * 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AssetConstants.add,
                  width: width * 0.055,
                  color: Colors.white,
                ),
                SizedBox(width: width * 0.01),
                Text('Hire',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: width * 0.042,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 TEAM CARD
  Widget _teamCard(AffiliateModel model) {
    return Container(
      decoration: BoxDecoration(
        color: Pallet.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: Pallet.borderColor),
      ),
      padding: EdgeInsets.all(width * 0.02),
      child: Column(
        children: [
          SizedBox(height: height*.01,),
          CircleAvatar(
            radius: width * 0.08,
            backgroundColor: Pallet.backgroundColor,
            child: SvgPicture.asset(AssetConstants.image),
          ),
          SizedBox(height: width * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                model.name,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: width * 0.04,
                ),
              ),
              SizedBox(width: width * 0.01),
              SvgPicture.asset('assets/svg/verify.svg', width: width * 0.045),
            ],
          ),
          SizedBox(height: width * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/location.svg', width: width * 0.04),
              SizedBox(width: width * 0.01),
              Text(
                model.zone,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.03,
                  color: Pallet.greyColor,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.015),
          Text(
            'Total Leads : ${model.totalLeads}',
            style: GoogleFonts.dmSans(fontSize: width * 0.03),
          ),
          SizedBox(height: width * 0.015),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.03,
              vertical: width * 0.01,
            ),
            decoration: BoxDecoration(
              color: Pallet.backgroundColor,
              borderRadius: BorderRadius.circular(width * 0.05),
            ),
            child: Text(
              'LQ : ${model.leadScore!.toInt()}%',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
