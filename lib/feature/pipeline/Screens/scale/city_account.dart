import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/custom_round_button.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/models/city_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';
import 'package:refrr_admin/feature/login/controller/lead_controller.dart';

class TabAccount extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  final CityModel? city;
  final List<ServiceLeadModel>? serviceLeads;
  const TabAccount({super.key, this.currentFirm, this.city, this.serviceLeads});
  @override
  ConsumerState<TabAccount> createState() => _TabAccountState();
}

class _TabAccountState extends ConsumerState<TabAccount> {  // ✅ Changed to ConsumerState

  /// ✅ Get filtered leads count (leads matching firm name AND city zone)
  int get totalLeadsCount {
    if (widget.serviceLeads == null || widget.city == null || widget.currentFirm == null) return 0;

    return widget.serviceLeads!.where((lead) {
      final firmName = widget.currentFirm?.name.toLowerCase().trim() ?? '';
      final leadName = lead.leadName.toLowerCase().trim();
      final cityZone = widget.city?.zone.toLowerCase().trim() ?? '';
      final marketerLocation = lead.marketerLocation.toLowerCase().trim();

      return leadName == firmName && marketerLocation == cityZone;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Watch the team provider
    final teamMembersAsync = ref.watch(teamProvider(widget.currentFirm?.reference?.id ?? ''));

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// STATS ROW 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ TEAM MEMBERS CARD - Using AsyncValue
                  teamMembersAsync.when(
                    data: (teamMembers) {
                      // ✅ Filter team members by zone
                      final filteredTeamCount = teamMembers.where((affiliate) {
                        final affiliateZone = affiliate.zone.toLowerCase().trim();
                        final cityZone = widget.city?.zone.toLowerCase().trim() ?? '';
                        return affiliateZone == cityZone;
                      }).length;

                      return _buildStatCard(
                        value: filteredTeamCount.toString(),
                        title: "Team Members",
                        iconPath: 'assets/svg/account-group-outline.svg',
                      );
                    },
                    loading: () => _buildStatCard(
                      value: "...",
                      title: "Team Members",
                      iconPath: 'assets/svg/account-group-outline.svg',
                      isLoading: true,
                    ),
                    error: (error, stack) => _buildStatCard(
                      value: "0",
                      title: "Team Members",
                      iconPath: 'assets/svg/account-group-outline.svg',
                    ),
                  ),

                  // ✅ TOTAL LEADS CARD
                  _buildStatCard(
                    value: totalLeadsCount.toString(),
                    title: "Total Leads",
                    iconPath: 'assets/svg/account-multiple-check-outline.svg',
                  ),
                ],
              ),

              SizedBox(height: width * 0.02),

              // /// STATS ROW 2
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Stack(
              //       children: [
              //         Container(
              //           height: height * 0.12,
              //           width: width * 0.45,
              //           padding: EdgeInsets.all(width * 0.025),
              //           decoration: BoxDecoration(
              //             color: Pallet.lightGreyColor,
              //             border: Border.all(color: Pallet.borderColor),
              //             borderRadius: BorderRadius.circular(width * 0.035),
              //           ),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Text(
              //                 "INR",
              //                 style: GoogleFonts.dmSans(
              //                   fontSize: width * 0.032,
              //                   color: Pallet.greyColor,
              //                 ),
              //               ),
              //               Text(
              //                 "1500",
              //                 maxLines: 1,
              //                 overflow: TextOverflow.ellipsis,
              //                 style: GoogleFonts.dmSans(
              //                   fontSize: width * 0.065,
              //                   fontWeight: FontWeight.bold,
              //                   color: Colors.black,
              //                 ),
              //               ),
              //               Text(
              //                 "Money Added",
              //                 maxLines: 1,
              //                 overflow: TextOverflow.ellipsis,
              //                 style: GoogleFonts.dmSans(
              //                   fontSize: width * 0.032,
              //                   color: Pallet.greyColor,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         Positioned(
              //           top: width * 0.028,
              //           right: width * 0.028,
              //           child: CircleSvgButton(
              //             child: SvgPicture.asset(
              //               'assets/svg/money.svg',
              //               width: width * 0.045,
              //               height: width * 0.045,
              //               fit: BoxFit.contain,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     Stack(
              //       children: [
              //         Container(
              //           height: height * 0.12,
              //           width: width * 0.45,
              //           padding: EdgeInsets.all(width * 0.025),
              //           decoration: BoxDecoration(
              //             color: Pallet.lightGreyColor,
              //             border: Border.all(color: Pallet.borderColor),
              //             borderRadius: BorderRadius.circular(width * 0.035),
              //           ),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Text(
              //                 "INR",
              //                 style: GoogleFonts.dmSans(
              //                   fontSize: width * 0.032,
              //                   color: Pallet.greyColor,
              //                 ),
              //               ),
              //               Text(
              //                 "800",
              //                 maxLines: 1,
              //                 overflow: TextOverflow.ellipsis,
              //                 style: GoogleFonts.dmSans(
              //                   fontSize: width * 0.065,
              //                   fontWeight: FontWeight.bold,
              //                   color: Colors.black,
              //                 ),
              //               ),
              //               Text(
              //                 "Money Withdrawn",
              //                 maxLines: 1,
              //                 overflow: TextOverflow.ellipsis,
              //                 style: GoogleFonts.dmSans(
              //                   fontSize: width * 0.032,
              //                   color: Pallet.greyColor,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         Positioned(
              //           top: width * 0.028,
              //           right: width * 0.028,
              //           child: CircleSvgButton(
              //             child: SvgPicture.asset(
              //               'assets/svg/money.svg',
              //               width: width * 0.045,
              //               height: width * 0.045,
              //               fit: BoxFit.contain,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),

              // SizedBox(height: width * 0.02),
              //
              // /// WITHDRAWAL HEADER
              // _sectionHeader("Pending Requests", width, () {}),
              // SizedBox(height: width * 0.02),
              //
              // _transactionItem(width, "INR 10000", "Raju has requested to withdrawal of "),
              // _transactionItem(width, "INR 10000", "Raju has requested to withdrawal of "),
              // _transactionItem(width, "INR 10000", "Raju has requested to withdrawal of "),
              // _transactionItem(width, "INR 10000", "Raju has requested to withdrawal of "),
              //
              // SizedBox(height: width * 0.02),
              //
              // /// TRANSACTION HISTORY
              // Container(
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Pallet.borderColor),
              //     borderRadius: BorderRadius.circular(width * 0.04),
              //   ),
              //   child: Column(
              //     children: [
              //       _sectionHeader("Transaction History", width, () {}),
              //       SizedBox(
              //         width: width,
              //         height: height * 0.5,
              //         child: ListView.builder(
              //           itemCount: 5,
              //           itemBuilder: (context, index) {
              //             return Padding(
              //               padding: EdgeInsets.all(width * 0.02),
              //               child: Column(
              //                 children: [
              //                   Row(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       CircleAvatar(
              //                         radius: width * 0.07,
              //                         backgroundColor: Pallet.backgroundColor,
              //                         child: CircleAvatar(
              //                           radius: width * 0.048,
              //                           child: SvgPicture.asset(AssetConstants.image),
              //                         ),
              //                       ),
              //                       SizedBox(width: width * 0.02),
              //                       Column(
              //                         crossAxisAlignment: CrossAxisAlignment.start,
              //                         children: [
              //                           SizedBox(
              //                             width: width * 0.48,
              //                             child: Text(
              //                               'Money Withdrawn by Raju',
              //                               style: GoogleFonts.dmSans(
              //                                 fontSize: width * 0.035,
              //                                 fontWeight: FontWeight.w500,
              //                               ),
              //                             ),
              //                           ),
              //                           Text(
              //                             '2 Days Ago',
              //                             style: GoogleFonts.dmSans(
              //                               fontSize: width * 0.03,
              //                               color: Pallet.greyColor,
              //                             ),
              //                           ),
              //                         ],
              //                       ),
              //                       Spacer(),
              //                       Text(
              //                         'INR 10000',
              //                         style: GoogleFonts.dmSans(
              //                           fontSize: width * 0.045,
              //                           fontWeight: FontWeight.w700,
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   Divider(),
              //                 ],
              //               ),
              //             );
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ REUSABLE STAT CARD WIDGET
  Widget _buildStatCard({
    required String value,
    required String title,
    required String iconPath,
    bool isLoading = false,
  }) {
    return Container(
      height: height * 0.12,
      width: width * 0.45,
      padding: EdgeInsets.all(width * 0.025),
      decoration: BoxDecoration(
        color: Pallet.lightGreyColor,
        border: Border.all(color: Pallet.borderColor),
        borderRadius: BorderRadius.circular(width * 0.035),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW → VALUE + ICON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? SizedBox(
                width: width * 0.05,
                height: width * 0.05,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
                  : Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              CircleSvgButton(
                child: SvgPicture.asset(iconPath),
              ),
            ],
          ),
          const Spacer(),
          /// TITLE (bottom-left)
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.032,
              color: Pallet.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION HEADER
  Widget _sectionHeader(String title, double width, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.all(width * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.055,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: width * .2,
              height: height * .04,
              decoration: BoxDecoration(
                border: Border.all(color: Pallet.borderColor),
                borderRadius: BorderRadius.circular(width * 0.05),
              ),
              child: Center(
                child: Text(
                  "View All",
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.03,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TRANSACTION ITEM
  Widget _transactionItem(double w, String amount, String status) {
    return Padding(
      padding: EdgeInsets.only(left: w * 0.01, right: w * 0.01, bottom: w * 0.02),
      child: Container(
        padding: EdgeInsets.all(w * 0.03),
        decoration: BoxDecoration(
          color: Pallet.lightGreyColor,
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: w * 0.05,
                  backgroundColor: Pallet.backgroundColor,
                  child: CircleAvatar(
                    radius: w * 0.045,
                    backgroundColor: Colors.white,
                    child: SvgPicture.asset(
                      AssetConstants.image,
                      width: w * 0.07,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: GoogleFonts.dmSans(fontSize: w * 0.035),
                      ),
                      SizedBox(height: 4),
                      Text(
                        amount,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: w * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "2 days ago",
                  style: GoogleFonts.dmSans(
                    fontSize: w * 0.03,
                    color: Pallet.greyColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Reject',
                      style: GoogleFonts.dmSans(
                        color: Pallet.redColor,
                        fontSize: w * 0.035,
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Text(
                      'Accept',
                      style: GoogleFonts.dmSans(
                        color: Pallet.greenColor,
                        fontSize: w * 0.035,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}