import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/call-function.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/whatsapp-function.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/Team/screens/career-tab.dart';
import 'package:refrr_admin/Feature/Team/screens/personal-info-tab.dart';
import 'package:refrr_admin/Feature/Team/screens/prefssonal-tab.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class NonTeamProfile extends ConsumerStatefulWidget {
  final AffiliateModel affiliate;
  final LeadsModel? currentFirm;

  const NonTeamProfile({
    super.key,
    required this.affiliate,
    this.currentFirm,
  });

  @override
  ConsumerState<NonTeamProfile> createState() => _NonTeamProfileState();
}

class _NonTeamProfileState extends ConsumerState<NonTeamProfile> {
  int selectedTab = 0;
  bool isHiring = false;
  /// 🔹 Get Affiliate ID
  String get affiliateId => widget.affiliate.id ?? widget.affiliate.reference?.id ?? '';
  /// 🔹 Hire Single Affiliate
  Future<void> _hireSingleAffiliate(AffiliateModel affiliate) async {
    try {
      if (widget.currentFirm == null) {
        showCommonSnackbar(context, 'Current firm not found');
        return;
      }

      final String? leadId = widget.currentFirm?.reference?.id;

      if (leadId == null || leadId.isEmpty) {
        showCommonSnackbar(context, 'Invalid firm/lead ID');
        return;
      }

      final String affiliateId = affiliate.reference?.id ?? '';
      if (affiliateId.isEmpty) {
        showCommonSnackbar(context, 'Invalid affiliate ID');
        return;
      }

      if (isHiring) return;

      // ✅ CHECK TEAM LIMIT BEFORE HIRING
      final data = widget.currentFirm;
      if (data == null) {
        showCommonSnackbar(context, 'Firm data not found');
        return;
      }

      final currentCount = data.teamMembers.length;
      final teamLimit = int.tryParse(data.teamLimit.toString()) ?? 0;
      final newCount = currentCount + 1;

      debugPrint('📊 Team check: currentCount=$currentCount, teamLimit=$teamLimit, newCount=$newCount');

      if (newCount > teamLimit) {
        showTeamLimitAlert(context, teamLimit);
        return;
      }

      setState(() {
        isHiring = true;
      });

      debugPrint('🚀 Starting hire process for: ${affiliate.name}');

      final result = await ref.read(affiliateControllerProvider.notifier).hireAffiliates(
        leadId: leadId,
        affiliates: [affiliate],
        context: context,
      );

      if (mounted) {
        setState(() {
          isHiring = false;
        });

        if (result['success'] == true) {
          debugPrint('🎉 Successfully hired ${affiliate.name}');
          showCommonSnackbar(context, '${affiliate.name} hired successfully!');
          Navigator.pop(context, true);
        } else {
          debugPrint('⚠️ Hire failed for ${affiliate.name}');
          showCommonSnackbar(context, 'Failed to hire ${affiliate.name}');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error hiring affiliate: $e');
      debugPrint('📋 Stack trace: $stack');
      if (mounted) {
        setState(() {
          isHiring = false;
        });
        showCommonSnackbar(context, 'Failed to hire: $e');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    double w = width;
    double h = height;

    final affiliateStream = ref.watch(affiliateByIdStreamProvider(affiliateId));

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,

      // 👇 FIXED BUTTON AT BOTTOM - Always stays in same position
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.02,
        ),
        decoration: BoxDecoration(
          color: Pallet.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: height * .06,
            child: ElevatedButton(
              onPressed: isHiring
                  ? null
                  : () {
                // ✅ CHECK TEAM LIMIT BEFORE SHOWING CONFIRMATION
                final data = widget.currentFirm;
                if (data == null) {
                  showCommonSnackbar(context, 'Firm data not found');
                  return;
                }

                final currentCount = data.teamMembers.length;
                final teamLimit = int.tryParse(data.teamLimit.toString()) ?? 0;
                final newCount = currentCount + 1;

                debugPrint('📊 Button check: currentCount=$currentCount, teamLimit=$teamLimit, newCount=$newCount');

                if (newCount > teamLimit) {
                  showTeamLimitAlert(context, teamLimit);
                  return;
                }

                // Only show confirmation if we have space
                showCommonAlertBox(
                  context,
                  'Do you want to add this member to your team?',
                      () async {
                    await _hireSingleAffiliate(widget.affiliate);
                  },
                  'Yes',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isHiring ? Colors.grey : Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isHiring
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Hiring...',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: width * .045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : Text(
                'Hire',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: width * .045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),

      // 👇 BODY CONTENT
      body: Stack(
        children: [
          affiliateStream.when(
            data: (affiliate) {
              final currentAffiliate = affiliate ?? widget.affiliate;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER =====
                    _buildHeader(currentAffiliate, w, h),

                    SizedBox(height: w * 0.02),

                    // ===== STAT CARDS =====
                    Padding(
                      padding: EdgeInsets.only(top: w * 0.03, left: width * .04),
                      child: Row(
                        children: [
                          _statBox("Total Leads", "${currentAffiliate.totalLeads}"),
                          SizedBox(width: width * .005),
                          _statBox("LQ", "${currentAffiliate.leadScore?.toInt()} %"),
                          SizedBox(width: width * .005),
                          _statBox("Total Agents", "0"),
                          SizedBox(width: width * .02),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.02),

                    // ===== TAB BAR =====
                    Padding(
                      padding: EdgeInsets.only(
                        left: w * 0.045,
                        right: w * 0.01,
                        top: w * 0.01,
                        bottom: w * 0.01,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          height: w * 0.1,
                          width: h * 0.457,
                          decoration: BoxDecoration(
                            color: Pallet.lightBlue,
                            borderRadius: BorderRadius.circular(w * 0.05),
                          ),
                          child: Row(
                            children: [
                              _tabItem("Personal Info", 0),
                              _tabItem("Professional Info", 1),
                              _tabItem("Career Preference", 2),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // ===== TAB CONTENT =====
                    _buildTabContent(currentAffiliate),

                    // 👇 Bottom padding for scrolling
                    SizedBox(height: h * 0.02),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              debugPrint('❌ Stream Error: $error');
              return _buildMainContent(widget.affiliate);
            },
          ),

          // 👇 Loading overlay when hiring
          if (isHiring)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.2),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  /// 🔹 Build Main Content (Fallback)
  Widget _buildMainContent(AffiliateModel affiliate) {
    double w = width;
    double h = height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(affiliate, w, h),
          SizedBox(height: w * 0.02),
          Padding(
            padding: EdgeInsets.only(top: w * 0.03, left: width * .04),
            child: Row(
              children: [
                _statBox("Total Leads", "${affiliate.totalLeads}"),
                SizedBox(width: width * .005),
                _statBox("LQ", "${affiliate.leadScore?.toInt()} %"),
                SizedBox(width: width * .005),
                _statBox("Total Agents", "0"),
                SizedBox(width: width * .02),
              ],
            ),
          ),
          SizedBox(height: h * 0.02),
          Padding(
            padding: EdgeInsets.only(
              left: w * 0.04,
              right: w * 0.01,
              top: w * 0.01,
              bottom: w * 0.01,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: w * 0.1,
                width: h * 0.457,
                decoration: BoxDecoration(
                  color: Pallet.lightBlue,
                  borderRadius: BorderRadius.circular(w * 0.05),
                ),
                child: Row(
                  children: [
                    _tabItem("Personal Info", 0),
                    _tabItem("Professional Info", 1),
                    _tabItem("Career Preference", 2),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: h * 0.02),
          _buildTabContent(affiliate),
          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }
  /// 🔹 Build Header
  Widget _buildHeader(AffiliateModel affiliate, double w, double h) {
    return SizedBox(
      height: h * 0.23,
      child: Stack(
        children: [
          Container(
            height: h * 0.15,
            decoration: BoxDecoration(
              color: const Color(0xFFE9FCFE),
              border: Border.all(
                color: const Color(0xFFE5E9EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: width * .05),
                CircleIconButton(
                  size: width * .08,
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => openDialer(affiliate.phone ?? ''),
                  child: CircleSvgButton(
                    size: width * .08,
                    child: SvgPicture.asset(
                      'assets/svg/blackphone.svg',
                      width: w * 0.04,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.025),
                GestureDetector(
                  onTap: () => openWhatsAppChat(affiliate.phone),
                  child: CircleSvgButton(
                    size: width * .08,
                    child: SvgPicture.asset(
                      'assets/svg/whatsappBlaack.svg',
                      width: w * 0.05,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.025),
                // GestureDetector(
                //   child: CircleSvgButton(
                //     size: width * .08,
                //     child: SvgPicture.asset(
                //       'assets/svg/more.svg',
                //       width: w * 0.04,
                //     ),
                //   ),
                // ),
                // SizedBox(width: width * .06),
              ],
            ),
          ),
          Positioned(
            left: w * 0.07,
            top: w * 0.21,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: h * 0.061,
                  backgroundColor: Pallet.backgroundColor,
                  child: CircleAvatar(
                    radius: h * 0.055,
                    backgroundImage: NetworkImage(affiliate.profile ?? ''),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: w * 0.06),
                    Text(
                      affiliate.name,
                      style: GoogleFonts.dmSans(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AssetConstants.location,
                          width: width * .03,
                        ),
                        SizedBox(width: w * 0.005),
                        Text(
                          "${affiliate.zone} ${affiliate.country}",
                          style: GoogleFonts.dmSans(
                            fontSize: w * 0.025,
                            color: Pallet.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// 🔹 Build Tab Content
  Widget _buildTabContent(AffiliateModel affiliate) {
    switch (selectedTab) {
      case 0:
        return PersonalInfoTab(affiliate: affiliate);
      case 1:
        return ProfessionalInfoTab(affiliate: affiliate);
      case 2:
        return CareerTab(affiliate: affiliate);
      default:
        return PersonalInfoTab(affiliate: affiliate);
    }
  }
  // ===== HELPER WIDGETS =====
  Widget _statBox(String title, String value) {
    return Container(
      width: width * 0.3,
      height: height * 0.09,
      margin: EdgeInsets.only(right: width * 0.01),
      decoration: BoxDecoration(
        color: Pallet.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: const Color(0xFFE5E9EB), width: 1),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: height * .015),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w400,
                color: Pallet.greyColor,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.045,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool active = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        width: width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.05),
          border: active
              ? Border.all(color: Pallet.primaryColor, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
              color: active ? Pallet.secondaryColor : Pallet.greyColor,
            ),
          ),
        ),
      ),
    );
  }
}
