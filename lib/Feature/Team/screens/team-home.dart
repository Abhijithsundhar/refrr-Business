import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Core/common/global variables.dart';
import '../../../Model/affiliate-model.dart';
import '../../../Model/leads-model.dart';
import '../../Funnel/Controller/serviceLead-controllor.dart';
import '../controller/affiliate-controller.dart';
import '../screens/hire-page.dart';
import '../screens/profileHome.dart';

class TeamHome extends ConsumerStatefulWidget {
  final LeadsModel currentFirm;
  const TeamHome( {super.key,required this.currentFirm,});

  @override
  ConsumerState<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends ConsumerState<TeamHome> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  /// Filters
  String activeFilter = 'All';
  String? selectedLocation;
  String getSpacedCount(int count) {
    if (count < 10) {
      return '   ${count.toString()}   '; // space before and after
    } else if (count < 100) {
      return '${count.toString()} '; // space after
    } else {
      return count.toString(); // no space
    }
  }  @override
  Widget build(BuildContext context) {
    final affiliatesAsync = ref.watch(affiliateStreamProvider(searchQuery));
    final serviceLeadAsync = ref.watch(serviceLeadsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
            top: height * .035, left: width * .04, right: width * .05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/refrrTextLogo.png',
                  width: width * .2,
                  height: 50,
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
              ],
            ),

            // Search + Hire Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setState(() => searchQuery = val.trim().toLowerCase());
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.black45),
                        suffixIcon: Icon(Icons.search, color: Colors.black45),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>  HirePage(currentFirm:widget.currentFirm,affiliate:affiliatesAsync,serviceLead:serviceLeadAsync)));
                  },
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text('Hire',
                          style: TextStyle(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.03),

            // Filters
            affiliatesAsync.when(
              data: (affiliates) {
                final totalCount = affiliates.length;

                /// Filter by location if selected
                List<AffiliateModel> filteredAffiliates = affiliates;
                if (selectedLocation != null) {
                  filteredAffiliates = filteredAffiliates
                      .where((a) => a.zone.toLowerCase() == selectedLocation!.toLowerCase())
                      .toList();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        _buildFilterButton('All  (${getSpacedCount(totalCount)})', activeFilter == 'All', () {
                          setState(() {
                            activeFilter = 'All';
                            selectedLocation = null;
                          });
                        }),
                        SizedBox(width: width * .055),
                        _buildFilterButton(
                          selectedLocation ?? 'Location',
                          activeFilter == 'Location',
                              () => _selectLocation(affiliates),
                        ),
                        SizedBox(width: width * .055),
                        _buildFilterButton('Performance', activeFilter == 'Performance',
                                () {
                              setState(() {
                                activeFilter = 'Performance';
                                // Placeholder: You can implement your logic
                              });
                            }),
                      ],
                    ),
                    SizedBox(height: height * 0.03),

                    // DISPLAY GRID after serviceLeads load
                    serviceLeadAsync.when(
                      data: (serviceLeads) {
                        if (filteredAffiliates.isEmpty) {
                          return const Center(child: Text("No affiliates found"));
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: filteredAffiliates.length,
                          itemBuilder: (context, index) {
                            final affiliate = filteredAffiliates[index];

                            final myLeads = serviceLeads
                                .where((lead) => lead.marketerId == affiliate.id)
                                .toList();

                            int completedLeads = myLeads.where((lead) =>
                            getLatestStatus(lead.statusHistory) ==
                                'Completed').length;

                            String lqScore = ''; // Placeholder

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfilePage(affiliate: affiliate),
                                  ),
                                );
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
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text("Error loading leads: $e")),
                    )
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ],
        ),
      ),
    );
  }

  // Select location dynamically from available zones
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan[100] : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.cyan : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.cyan[700] : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (!isSelected && text == 'Location')
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey[600], size: 14),
              ),
          ],
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
                  backgroundImage: model.profile != null && model.profile!.isNotEmpty
                      ? NetworkImage(model.profile!)
                      : null,
                  child: model.profile == null || model.profile!.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[600], size: 30)
                      : null,
                ),
              ),
              SizedBox(height: height * 0.006),

              Text(
                model.name,
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

              const SizedBox(height: 8),

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
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),

              RichText(
                text: TextSpan(
                  text: 'C/R Amount:',
                  style: GoogleFonts.roboto(fontSize: width * .0345, color: Colors.black),
                  children: [
                    TextSpan(
                      text: " AED${model.totalCredit}",
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'W/D Amount:',
                  style: GoogleFonts.roboto(fontSize: width * .0345, color: Colors.black),
                  children: [
                    TextSpan(
                      text: " AED${model.totalWithrew}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'LQ - $lqScore %',
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
        Positioned(
          top: height*.0182,
          left: width*.25,
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
        ),
      ],
    );
  }
}