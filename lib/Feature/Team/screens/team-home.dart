import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Funnel/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/Team/screens/hire-page.dart';
import 'package:refrr_admin/Feature/Team/screens/new-profile.dart';
import 'package:refrr_admin/Feature/Team/screens/profileHome.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class TeamHome extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const TeamHome({super.key, this.currentFirm});

  @override
  ConsumerState<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends ConsumerState<TeamHome> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  /// Filters
  String activeFilter = 'All';
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    // Keep providers so Hire page can still receive them as before
    final affiliatesAsync = ref.watch(affiliateStreamProvider(searchQuery));
    final serviceLeadAsync = ref.watch(serviceLeadsStreamProvider);

    // Use team members from the current firm instead of all affiliates
    final List<AffiliateModel> teamMembers =
    List<AffiliateModel>.from(widget.currentFirm?.teamMembers ?? []);

    // Apply filters (only filter by location when activeFilter == 'Location')
    List<AffiliateModel> filteredAffiliates = teamMembers;
    if (activeFilter == 'Location' &&
        selectedLocation != null &&
        selectedLocation!.isNotEmpty) {
      filteredAffiliates = filteredAffiliates
          .where((a) => a.zone.toLowerCase() == selectedLocation!.toLowerCase())
          .toList();
    }
    // Performance is a placeholder in your UI; no filtering applied.

    final totalCount = teamMembers.length;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,

          // NEW: AppBar with lead/firm name and icons
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding:  EdgeInsets.only(left: width*.05),
              child: Text(widget.currentFirm?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.bebasNeue(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: width * .055,
                ),
              ),
            ),
            actions: [
              Icon(Icons.search, color: Colors.black),
              SizedBox(width: width * .02),
              Icon(Icons.menu_outlined, color: Colors.black),
              SizedBox(width: width * .03),
            ],
          ),

          body: Padding(
            // Reduced top padding since AppBar is present
            padding: EdgeInsets.only(
                top: height * .01, left: width * .04, right: width * .05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // REMOVED: old header row that contained the name and icons

                  SizedBox(height: height * .01),

                  /// Filters (UI unchanged), now based on teamMembers
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFilterButton(
                            'All ($totalCount)',
                            activeFilter == 'All',
                                () {
                              setState(() {
                                activeFilter = 'All';
                                selectedLocation =
                                null; // ensure no filtering when All
                              });
                            },
                          ),
                          SizedBox(width: width * .02),
                          _buildFilterButton(
                            selectedLocation ?? 'Location',
                            activeFilter == 'Location',
                                () => _selectLocation(teamMembers),
                          ),
                          SizedBox(width: width * .02),
                          _buildFilterButton(
                            'Performance', activeFilter == 'Performance',
                                () {
                              setState(() {
                                activeFilter = 'Performance';
                                // Placeholder: no filtering applied
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),

                      // DISPLAY GRID after serviceLeads load
                      serviceLeadAsync.when(
                        data: (serviceLeads) {
                          if (filteredAffiliates.isEmpty) {
                            return const Center(
                                child: Text("No team members found"));
                          }
                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 10),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: filteredAffiliates.length,
                            itemBuilder: (context, index) {
                              final affiliate = filteredAffiliates[index];

                              final myLeads = serviceLeads.where((lead) => lead.marketerId == affiliate.id).toList();

                              int completedLeads = myLeads.where((lead) =>
                              getLatestStatus(lead.statusHistory) == 'Completed').length;

                              String lqScore = ''; // Placeholder

                              return InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => NewProfile(affiliate: affiliate),),);
                                },
                                child: _buildCandidateCard(
                                  model: affiliate,
                                  width: width,
                                  completedCount: completedLeads,
                                  lqScore: lqScore,
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Center(child: Text("Error loading leads: $e")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: height * .84,
          left: width * .71,
          child: GestureDetector(
            onTap: () {
              // Keep navigation and params unchanged
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HirePage(
                    serviceLead: serviceLeadAsync,
                    affiliate: affiliatesAsync,
                    currentFirm: widget.currentFirm,
                  ),
                ),
              );
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: width * .04,
                  ),
                  SizedBox(width: width * .02),
                  Text(
                    'Hire',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: width * .035,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // Select location dynamically from current team members
  void _selectLocation(List<AffiliateModel> affiliates) async {
    final zones = affiliates.map((a) => a.zone).toSet().toList();

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Location'),
        children: zones.map((zone) {
          return SimpleDialogOption(
            child: Text(zone),
            onPressed: () => Navigator.pop(context, zone),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedLocation = selected;
        activeFilter = 'Location';
      });
    }
  }

  String getLatestStatus(List<Map<String, dynamic>> statusHistory) {
    if (statusHistory.isEmpty) return '';
    statusHistory.sort((a, b) {
      final DateTime dateA = (a['date'] as Timestamp).toDate();
      final DateTime dateB = (b['date'] as Timestamp).toDate();
      return dateB.compareTo(dateA);
    });
    return statusHistory.first['status']?.toString() ?? '';
  }

  Widget _buildFilterButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.27,   // same width as your card design
        height: height * 0.043, // same height as your card design
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(
              fontSize: width * 0.03,
              fontWeight: FontWeight.w400,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCandidateCard({
    required AffiliateModel model,
    required double width,
    required int completedCount,
    required String lqScore,
  }) {
    return Stack(
      children: [
        Container(
          height: height * 0.311,
          width: width * 0.9,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: model.profile.isNotEmpty
                      ? NetworkImage(model.profile)
                      : AssetImage('assets/image.png'),
                ),
              ),
              SizedBox(height: height * 0.006),

              Text(
                model.name.length > 15
                    ? "${model.name.substring(0, 15)}..."
                    : model.name,
                style: GoogleFonts.roboto(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                model.zone,
                style: GoogleFonts.roboto(
                  fontSize: width * .03,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 10),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total leads: ',
                      style: GoogleFonts.roboto(
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '$completedCount',
                      style: GoogleFonts.roboto(
                        fontSize: width * .035,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),

              RichText(
                text: TextSpan(
                  text: 'Total credited:',
                  style: GoogleFonts.roboto(
                      fontSize: width * .03, color: Colors.black),
                  children: [
                    TextSpan(
                      text: " AED 100",
                      // text: " AED${model.totalCredit}",
                      style: GoogleFonts.roboto(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Total withdrawn:',
                  style: GoogleFonts.roboto(
                      fontSize: width * .03, color: Colors.black),
                  children: [
                    TextSpan(
                      // text: " AED${model.totalWithrew}",
                      text: " AED 20",
                      style: GoogleFonts.roboto(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lqScore.isEmpty ? 'LQ - 60%' : 'LQ - $lqScore %',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
        ),

        // Badge
        model.profile.isNotEmpty ? Positioned(
          top: height * .0182,
          left: width * .25,
          child: Badge.count(
            count: 1,
            backgroundColor: Colors.cyan,
            textColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.all(4),
          ),
        ): Positioned(
          top: height * .0182,
          left: width * .25,
          child: Badge.count(
            count: 1,
            backgroundColor: Colors.transparent,
            textColor: Colors.transparent,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.all(4),
          ),
        ),
      ],
    );
  }
}