import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/alert_box.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/Team/screens/profile.dart';
import 'package:refrr_admin/feature/login/controller/lead_controller.dart';
import 'package:refrr_admin/feature/pipeline/controller/country_controller.dart';
import 'package:refrr_admin/feature/pipeline/screens/scale/suggested_candidates.dart';
import 'package:refrr_admin/feature/team/controller/affiliate_controller.dart' hide teamProvider;
import 'package:refrr_admin/feature/team/screens/non_hired_profile.dart';
import 'package:refrr_admin/models/affiliate_model.dart';
import 'package:refrr_admin/models/city_model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class TeamTab extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  final CityModel? city;
  const TeamTab({super.key, this.currentFirm, this.city});

  @override
  ConsumerState<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends ConsumerState<TeamTab> {
  String countryName = '';

  // Track which affiliates are currently being hired
  final Set<String> hiringInProgress = {};

  @override
  void initState() {
    super.initState();
    _loadCountryName();
  }

  Future<void> _loadCountryName() async {
    if (widget.city?.country == null || widget.city!.country.isEmpty) {
      return;
    }

    try {
      final countries = await ref.read(countryControllerProvider.notifier).fetchCountries();

      final matchingCountry = countries.firstWhere(
            (country) => country.countryName.toLowerCase() == widget.city!.country.toLowerCase() ||
            country.shortName.toUpperCase() == widget.city!.country.toUpperCase() ||
            country.countryCode == widget.city!.country,
      );

      if (mounted) {
        setState(() {
          countryName = matchingCountry.countryName;
        });
        print('✅ Loaded country name: $countryName');
      }
    } catch (e) {
      print('⚠️ Error loading country name: $e');
      if (mounted) {
        setState(() {
          countryName = widget.city?.country ?? '';
        });
      }
    }
  }

  // 👇 Navigate to affiliate profile (for suggested candidates & pending)
  void _navigateToProfile(AffiliateModel affiliate) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NonTeamProfile(affiliate: affiliate,currentFirm: widget.currentFirm,),),);
  }

  // 👇 Navigate to team member profile (for Our team section)
  void _navigateToTeamMemberProfile(AffiliateModel affiliate) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AccountProfileScreen(affiliate: affiliate,currentFirm: widget.currentFirm),),);
  }

  /// 🔹 Hire a single affiliate
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

      // Check if already hiring this affiliate
      if (hiringInProgress.contains(affiliateId)) {
        return;
      }

      setState(() {
        hiringInProgress.add(affiliateId);
      });

      debugPrint('🚀 Starting hire process for: ${affiliate.name}');

      // Use the AffiliateController method
      final result = await ref.read(affiliateControllerProvider.notifier).hireAffiliates(
        leadId: leadId,
        affiliates: [affiliate],
        context: context,
      );

      if (mounted) {
        setState(() {
          hiringInProgress.remove(affiliateId);
        });

        if (result['success'] == true) {
          debugPrint('🎉 Successfully hired ${affiliate.name}');
        } else {
          debugPrint('⚠️ Hire failed for ${affiliate.name}');
        }
      }

    } catch (e, stack) {
      debugPrint('❌ Error hiring affiliate: $e');
      debugPrint('📋 Stack trace: $stack');
      if (mounted) {
        final affiliateId = affiliate.reference?.id ?? '';
        setState(() {
          hiringInProgress.remove(affiliateId);
        });
        showCommonSnackbar(context, 'Failed to hire: $e');
      }
    }
  }

  /// 🔹 Accept application from pending requests
  Future<void> _acceptApplication(AffiliateModel application) async {
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

      final String affiliateId = application.reference?.id ?? '';
      if (affiliateId.isEmpty) {
        showCommonSnackbar(context, 'Invalid affiliate ID');
        return;
      }

      // Check if already hiring this affiliate
      if (hiringInProgress.contains(affiliateId)) {
        return;
      }

      setState(() {
        hiringInProgress.add(affiliateId);
      });

      debugPrint('🚀 Accepting application for: ${application.name}');

      // Use the AffiliateController method
      final result = await ref.read(affiliateControllerProvider.notifier).hireAffiliates(
        leadId: leadId,
        affiliates: [application],
        context: context,
      );

      if (mounted) {
        setState(() {
          hiringInProgress.remove(affiliateId);
        });

        if (result['success'] == true) {
          debugPrint('🎉 Successfully accepted ${application.name}');
        }
      }

    } catch (e, stack) {
      debugPrint('❌ Error accepting application: $e');
      debugPrint('📋 Stack trace: $stack');
      if (mounted) {
        final affiliateId = application.reference?.id ?? '';
        setState(() {
          hiringInProgress.remove(affiliateId);
        });
        showCommonSnackbar(context, 'Failed to accept: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('\n🏙️ TEAM TAB - Current City: ${widget.city?.zone}');
    print('   Country: ${widget.city?.country}');
    print('   Current Firm ID: ${widget.currentFirm?.reference?.id}');

    // Get team members for current firm using teamProvider
    final teamMembersAsync = ref.watch(teamProvider(widget.currentFirm?.reference?.id ?? ''));

    // Get ALL affiliates (not just from current firm)
    final allAffiliatesAsync = ref.watch(affiliateStreamProvider(''));

    final pendingRequests = (widget.currentFirm?.applications ?? []).where((application) {
      return application.zone.toLowerCase().trim() == widget.city?.zone.toLowerCase().trim();
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OUR TEAM SECTION
          Padding(
            padding: EdgeInsets.only(left: width * 0.02),
            child: Text("Our team",
              style: GoogleFonts.dmSans(
                fontSize: width * 0.055,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: height * .005),
          teamMembersAsync.when(
            data: (teamMembers) {
              print('\n👥 OUR TEAM - team Members Loaded:');
              print('   Total team members: ${teamMembers.length}');
              print('   Current city zone: "${widget.city?.zone}"');

              // Filter team members by zone
              final filteredTeam = teamMembers.where((affiliate) {
                final affiliateZone = affiliate.zone.toLowerCase().trim();
                final cityZone = widget.city?.zone.toLowerCase().trim() ?? '';

                bool matches = affiliateZone == cityZone;

                if (matches) {
                  print('   ✅ team member in zone: ${affiliate.name} (zone: $affiliateZone)');
                } else {
                  print('   ❌ team member NOT in zone: ${affiliate.name} (zone: $affiliateZone, needed: $cityZone)');
                }

                return matches;
              }).toList();

              print('   📊 Filtered team members for ${widget.city?.zone}: ${filteredTeam.length}\n');

              // 👇 FIXED: Pass the callback function correctly
              return _teamList(width,
                filteredTeam, (affiliate) => _navigateToTeamMemberProfile(affiliate),);
            },
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.all(width * 0.1),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) {
              print('❌ Error loading team members: $error');
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Text('Error loading team'),
                ),
              );
            },
          ),
          pendingRequests.isNotEmpty ? SizedBox(height: width * 0.04) : SizedBox(),

          // PENDING REQUESTS SECTION
          pendingRequests.isNotEmpty ? _sectionHeader("Pending Requests",
            width, height,
            context, () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => SuggestedCandidats(currentFirm: widget.currentFirm),
              ),
            ),
          )
              : SizedBox(),
          SizedBox(height: width * 0.02),
          pendingRequests.isNotEmpty ? _pendingRequests(width, height, pendingRequests) : SizedBox(),
          pendingRequests.isNotEmpty ? SizedBox(height: width * 0.02) : SizedBox(),

          // SUGGESTED CANDIDATES SECTION
          _sectionHeader("Suggested Candidates", width, height, context, () {}),
          teamMembersAsync.when(
            data: (teamMembers) {
              return allAffiliatesAsync.when(
                data: (allAffiliates) {
                  print('\n🔍 FILTERING ALL AFFILIATES FOR SUGGESTED CANDIDATES:');
                  print('   Total affiliates in system: ${allAffiliates.length}');
                  print('   Current city zone: "${widget.city?.zone}"');

                  final teamMemberIds = teamMembers
                      .map((member) => member.reference?.id ?? '')
                      .where((id) => id.isNotEmpty)
                      .toSet();

                  print('   team member IDs to exclude: $teamMemberIds');

                  final suggestedCandidates = allAffiliates.where((affiliate) {
                    final affiliateZone = affiliate.zone.toLowerCase().trim() ?? '';
                    final cityZone = widget.city?.zone.toLowerCase().trim() ?? '';
                    final affiliateId = affiliate.reference?.id ?? '';

                    bool matchesZone = affiliateZone == cityZone;
                    bool notInTeam = !teamMemberIds.contains(affiliateId);

                    bool shouldShow = matchesZone && notInTeam;

                    if (matchesZone) {
                      if (notInTeam) {
                        print('   ✅ Suggested: ${affiliate.name} (zone: $affiliateZone)');
                      } else {
                        print('   ⏭️ Skipped (already in team): ${affiliate.name}');
                      }
                    }

                    return shouldShow;
                  }).toList();

                  print('   📊 Total suggested candidates: ${suggestedCandidates.length}\n');
                  return _suggestedGrid(width, height, suggestedCandidates);
                },
                loading: () => Center(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.1),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) {
                  print('❌ Error loading all affiliates: $error');
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(width * 0.05),
                      child: Text('Error loading candidates'),
                    ),
                  );
                },
              );
            },
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.all(width * 0.1),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: EdgeInsets.all(width * 0.05),
                child: Text('Error loading team data'),
              ),
            ),
          ),
          SizedBox(height: width * 0.05),
        ],
      ),
    );
  }

  /// ---------------- COMMON SECTION HEADER ----------------
  Widget _sectionHeader(
      String title,
      double width,
      double height,
      BuildContext context,
      VoidCallback onTap,
      ) {
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
          if (title != 'Suggested Candidates')
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

  /// ---------------- TEAM LIST (Updated with proper callback) ----------------
  /// 👇 CHANGED: Function(AffiliateModel) instead of VoidCallback
  Widget _teamList(
      double width,
      List<AffiliateModel> teamMembers,
      Function(AffiliateModel) onTap,
      ) {
    if (teamMembers.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(width * 0.1),
        child: Center(
          child: Text(
            'No team members in this city',
            style: GoogleFonts.dmSans(
              fontSize: width * 0.04,
              color: Pallet.greyColor,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.99,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: teamMembers.length,
      itemBuilder: (_, index) {
        final member = teamMembers[index];
        return GestureDetector(
          // 👇 FIXED: Pass the member to the callback
          onTap: () => onTap(member),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: width * 0.09,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: member.profile.isNotEmpty ? NetworkImage(member.profile) : null,
                child: member.profile.isEmpty ? SvgPicture.asset(AssetConstants.image) : null,
              ),
              SizedBox(height: width * 0.01),
              Text(
                member.name,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.031,
                  fontWeight: FontWeight.w600,
                  color: Pallet.greyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  /// ---------------- PENDING REQUESTS ----------------
  Widget _pendingRequests(double width, double height, List<AffiliateModel> pendingList) {
    if (pendingList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Center(
          child: Text(
            'No pending requests in this city',
            style: GoogleFonts.dmSans(
              fontSize: width * 0.035,
              color: Pallet.greyColor,
            ),
          ),
        ),
      );
    }

    final displayList = pendingList.take(2).toList();

    return Row(
      children: displayList.map((application) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: displayList.indexOf(application) == 0 ? width * 0.02 : width * 0.01,
              right: displayList.indexOf(application) == displayList.length - 1
                  ? width * 0.02
                  : width * 0.01,
            ),
            child: _pendingCard(application, width, height),
          ),
        );
      }).toList(),
    );
  }

  /// ---------------- PENDING CARD ----------------
  Widget _pendingCard(dynamic application, double width, double height) {
    final affiliateId = application.reference?.id ?? '';
    final isHiring = hiringInProgress.contains(affiliateId);

    return GestureDetector(
      onTap: () => _navigateToProfile(application),
      child: Container(
        decoration: BoxDecoration(
          color: Pallet.lightGreyColor,
          borderRadius: BorderRadius.circular(width * 0.03),
          border: Border.all(color: Pallet.borderColor),
        ),
        padding: EdgeInsets.symmetric(vertical: width * 0.03),
        child: Column(
          children: [
            CircleAvatar(
              radius: width * 0.08,
              backgroundImage: application.profile != null && application.profile!.isNotEmpty
                  ? NetworkImage(application.profile!)
                  : const AssetImage('assets/image.png') as ImageProvider,
            ),
            SizedBox(height: width * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              child: Text(
                application.name ?? 'Unknown',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.04,
                ),
              ),
            ),
            SizedBox(height: width * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/location.svg',
                  width: width * 0.035,
                ),
                SizedBox(width: width * 0.01),
                Flexible(
                  child: Text(
                     application.zone ?? 'Unknown',
                    style: GoogleFonts.dmSans(
                      color: Pallet.greyColor,
                      fontSize: width * 0.03,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.01),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                vertical: width * 0.012,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.05),
                color: Pallet.backgroundColor,
              ),
              child: Text(
                'LQ : ${application.leadScore?? 0}%',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.03,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: width * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: !isHiring
                      ? () {
                    // Handle reject
                  }
                      : null,
                  child: Container(
                    height: height * .04,
                    width: width * .17,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.02),
                      border: Border.all(
                        color: Pallet.darkGreyColor.withOpacity(.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Reject',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.03,
                          color: Pallet.greyColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.02),
                GestureDetector(
                  onTap: !isHiring ? () => _acceptApplication(application) : null,
                  child: Container(
                    height: height * .04,
                    width: width * .17,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.02),
                      color: isHiring ? Colors.grey : Colors.black,
                    ),
                    child: Center(
                      child: isHiring
                          ? SizedBox(
                        width: width * 0.04,
                        height: width * 0.04,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        'Accept',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.03,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- SUGGESTED GRID ----------------
  Widget _suggestedGrid(double width, double height, List<AffiliateModel> candidates) {
    if (candidates.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(width * 0.1),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.person_search,
                size: width * 0.15,
                color: Pallet.greyColor.withOpacity(0.5),
              ),
              SizedBox(height: width * 0.03),
              Text(
                'No suggested candidates in ${widget.city?.zone ?? "this city"}',
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.04,
                  color: Pallet.greyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: candidates.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: width * 0.02,
          mainAxisSpacing: width * 0.02,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (_, index) {
          final candidate = candidates[index];
          final affiliateId = candidate.reference?.id ?? '';
          final isHiring = hiringInProgress.contains(affiliateId);

          return GestureDetector(
            onTap: () => _navigateToProfile(candidate),
            child: Container(
              decoration: BoxDecoration(
                color: Pallet.lightGreyColor,
                borderRadius: BorderRadius.circular(width * 0.03),
                border: Border.all(color: Pallet.borderColor),
              ),
              padding: EdgeInsets.symmetric(vertical: width * 0.03),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: width * 0.08,
                    backgroundImage: candidate.profile.isNotEmpty
                        ? NetworkImage(candidate.profile)
                        : const AssetImage('assets/image.png') as ImageProvider,
                  ),
                  SizedBox(height: width * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                    child: Text(
                      candidate.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/location.svg',
                        width: width * 0.035,
                      ),
                      SizedBox(width: width * 0.01),
                      Flexible(
                        child: Text(
                          candidate.zone,
                          style: GoogleFonts.dmSans(
                            color: Pallet.greyColor,
                            fontSize: width * 0.03,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.02,
                      vertical: width * 0.012,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.05),
                      color: Pallet.backgroundColor,
                    ),
                    child: Text(
                      'LQ : ${candidate.leadScore ?? 0}%',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.03,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.016),
                  GestureDetector(
                    onTap: !isHiring
                        ? () {
                      showCommonAlertBox(
                        context,
                        "Do you want add ${candidate.name} to your's team?",
                            () {
                          _hireSingleAffiliate(candidate);
                        },
                        'Yes',
                      );
                    }
                        : null,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: height * .045,
                      width: width * .32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.02),
                        color: isHiring ? Colors.grey : Colors.black,
                      ),
                      child: Center(
                        child: isHiring
                            ? SizedBox(
                          width: width * 0.05,
                          height: width * 0.05,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          'Hire',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: width * 0.035,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
