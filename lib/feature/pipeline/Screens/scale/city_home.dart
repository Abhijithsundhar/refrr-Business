import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/alert_box.dart';
import 'package:refrr_admin/core/common/custom_round_button.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/pipeline/Controller/city_controller.dart';
import 'package:refrr_admin/feature/pipeline/Screens/scale/city_account.dart';
import 'package:refrr_admin/feature/pipeline/Screens/scale/city_helpdesk.dart';
import 'package:refrr_admin/feature/pipeline/Screens/scale/city_pipeline.dart';
import 'package:refrr_admin/feature/pipeline/Screens/scale/city_team.dart';
import 'package:refrr_admin/models/city_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';

class CityScreen extends StatefulWidget {
  final LeadsModel? currentFirm;
  final List<ServiceLeadModel>? serviceLeads;
  final CityModel? city;
  const CityScreen({super.key, this.currentFirm,  this.serviceLeads, this.city});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ========== FIXED HEADER ==========
          SizedBox(
            height: height * 0.2,
            width: width,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.city?.profile ?? '',
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Image.asset(
                    'assets/dubai.jpeg',
                    fit: BoxFit.fill,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/dubai.jpeg',
                    fit: BoxFit.fill,
                  ),
                ),

                /// 🔥 THREE DOT ICON (RIGHT SIDE)
                Positioned(
                  top: width * 0.2,
                  right: width * 0.05,
                  child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      return GestureDetector(
                        onTapDown: (details) {
                          showDeleteMenu(
                            context,
                            details.globalPosition,
                                () {
                              ref.read(cityControllerProvider.notifier).deleteCity(
                                leadId: widget.currentFirm?.reference?.id ?? '',
                                cityId: widget.city?.id ?? '',
                                context: context,
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: width * 0.1,
                    left: width * 0.05,
                    bottom: width * 0.02,
                  ),
                  child: Row(
                    children: [
                      CircleIconButton(
                        borderColor: Colors.white,
                        iconColor: Colors.white,
                        icon: Icons.arrow_back_ios_new_outlined,
                        onTap: () => Navigator.pop(context),
                      ),
                      SizedBox(width: width * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.city?.zone ?? '',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: width * 0.06,
                              color: Pallet.backgroundColor,
                            ),
                          ),
                          // Text(
                          //   widget.city?.country ?? '',
                          //   style: GoogleFonts.dmSans(
                          //     fontSize: width * 0.04,
                          //     fontWeight: FontWeight.w500,
                          //     color: Pallet.backgroundColor,
                          //   ),
                          // ),
                          Text('India',
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w500,
                              color: Pallet.backgroundColor,
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

          SizedBox(height: width * 0.02),

          /// ========== FIXED TABS ==========
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.02,
              vertical: width * 0.01,
            ),
            child: SizedBox(
              height: width * 0.1,
              child: Row(
                children: [
                  _tabItem("team", 0, width),
                  _tabItem("Pipeline", 1, width),
                  // _tabItem("Account", 2, width),
                  _tabItem("Help Desk", 3, width),
                ],
              ),
            ),
          ),

          SizedBox(height: width * 0.02),

          /// ========== SCROLLABLE CONTENT ==========
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: _buildTabContent(width, height),
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab content based on selected tab
  Widget _buildTabContent(double width, double height) {
    switch (tab) {
      case 0:
        return TeamTab(currentFirm:widget.currentFirm ,city:widget.city);
      case 1:
        return CityPipeline(currentFirm:widget.currentFirm,serviceLeads:widget.serviceLeads,city:widget.city);
      case 2:
        return TabAccount(currentFirm:widget.currentFirm,serviceLeads:widget.serviceLeads,city:widget.city);
      case 3:
        return const TabHelpDesk();
      default:
        return TeamTab(currentFirm:widget.currentFirm,city:widget.city);
    }
  }

  /// ---------------- TOP TABS ----------------
  Widget _tabItem(String title, int index, double width) {
    final bool active = tab == index;
    return GestureDetector(
      onTap: () => setState(() => tab = index),
      child: Container(
        width: width * 0.24,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? Pallet.primaryColor : Pallet.borderColor,
              width: width * 0.004,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w500,
              color: active ? Pallet.secondaryColor : Pallet.greyColor,
            ),
          ),
        ),
      ),
    );
  }
}
