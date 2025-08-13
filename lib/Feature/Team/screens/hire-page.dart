import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Model/affiliate-model.dart';
import 'package:refrr_admin/Model/serviceLeadModel.dart';
import '../../../Core/common/alertBox.dart';
import '../../../Core/common/global variables.dart';
import '../../../Model/leads-model.dart';
import 'addNew-page.dart';
import 'hire-singlepage.dart';

class HirePage extends ConsumerStatefulWidget {
  final AsyncValue<List<ServiceLeadModel>> serviceLead;
  final AsyncValue<List<AffiliateModel>> affiliate;
  final LeadsModel currentFirm;
  const HirePage({super.key, required this.serviceLead, required this.affiliate, required this.currentFirm,});

  @override
  ConsumerState<HirePage> createState() => _HirePageState();
}

class _HirePageState extends ConsumerState<HirePage> {

  String selectedFilter = 'All';
  String? selectedLocation;
  String? selectedIndustry;
  bool isSelectionMode = false;
  Set<String> selectedAffiliateIds = {};
  List<AffiliateModel> selectedAffiliates = [];
  bool isUploading = false;
  List<AffiliateModel> existingTeam=[];

@override
  void initState() {
    // TODO: implement initState
    super.initState();
   existingTeam = widget.currentFirm.teamMembers;
  }

  /// Filtering
  List<AffiliateModel> applyFilters(List<AffiliateModel> allAffiliates, List<ServiceLeadModel> allLeads) {
    List<AffiliateModel> filtered = allAffiliates;

    if (selectedFilter == 'Location' && selectedLocation != null) {
      filtered = filtered.where((a) => a.zone.toLowerCase() == selectedLocation!.toLowerCase()).toList();
    }

    if (selectedFilter == 'Performance') {
      filtered = filtered.where((affiliate) {
        final leadCount = allLeads.where((lead) => lead.marketerId == affiliate.id).length;
        return leadCount >= 5;
      }).toList();
    }

    return filtered;
  }

  void showSelectDialog(List<String> options, String title, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Select $title'),
        children: options.map((e) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onSelected(e);
            },
            child: Text(e),
          );
        }).toList(),
      ),
    );
  }

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;

      if (!isSelectionMode) {
        selectedAffiliateIds.clear();
        selectedAffiliates.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ FAB to upload
      floatingActionButton: isSelectionMode && selectedAffiliateIds.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
          if (isUploading) return;

          if (selectedAffiliates.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select at least one member.")),
            );
            return;
          }

          showCommonAlertBox(
            context,
            'Add ${selectedAffiliates.length} member(s) to the team?',
                () async {
              setState(() => isUploading = true);

              try {
                // 👇 Step 1: Merge new members with existing team
                final mergedTeam = [...existingTeam, ...selectedAffiliates];

                // 👇 Step 2: Create updated firm model
                final LeadsModel updatedFirm = widget.currentFirm.copyWith(
                  teamMembers: mergedTeam,
                );

                // 👇 Step 3: Update Firestore via controller
                await ref.read(leadsControllerProvider.notifier).updateLeads(
                  context: context,
                  leadsModel: updatedFirm,
                );

                if (mounted) {
                  Navigator.pop(context); // Close alert
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Team updated successfully!')),
                  );
                }

                // 👇 Step 4: Reset
                setState(() {
                  existingTeam = mergedTeam;
                  selectedAffiliateIds.clear();
                  selectedAffiliates.clear();
                  isSelectionMode = false;
                  isUploading = false;
                });
              } catch (e, s) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
                print("ERROR: $e");
                print("STACK: $s");
                setState(() => isUploading = false);
              }
            },
            "Yes",
          );
        },
        backgroundColor: isUploading ? Colors.grey : Colors.black,
        label: isUploading
            ? Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('Uploading...')
          ],
        )
            : Text("Add (${selectedAffiliateIds.length})"),
        icon: const Icon(Icons.upload),
      )
          : null,
      body: Padding(
        padding: EdgeInsets.only(top: height * .035, left: width * .04, right: width * .05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/refrrTextImage.png', width: width * .2, height: 50),
                  IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                ],
              ),

              /// Top Row (Search + Select)
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
                      child: const TextField(
                        decoration: InputDecoration(
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
                    onTap: toggleSelectionMode,
                    child: Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelectionMode ? Colors.red : Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          isSelectionMode ? 'Cancel' : 'Select',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Filters
              widget.affiliate.when(
                data: (affiliates) {
                  return Row(
                    children: [
                      _buildFilterButton('All (${affiliates.length})', selectedFilter == 'All', () {
                        setState(() {
                          selectedFilter = 'All';
                          selectedLocation = null;
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterButton('Location', selectedFilter == 'Location', () {
                        final locations = affiliates.map((a) => a.zone).toSet().toList();
                        showSelectDialog(locations, 'Location', (value) {
                          setState(() {
                            selectedLocation = value;
                            selectedFilter = 'Location';
                          });
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterButton('Performance', selectedFilter == 'Performance', () {
                        setState(() {
                          selectedFilter = 'Performance';
                          selectedLocation = null;
                        });
                      }),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 10),

              /// Grid
              widget.affiliate.when(
                data: (affiliates) {
                  return widget.serviceLead.when(
                    data: (leads) {
                      final filteredAffiliates = applyFilters(affiliates, leads);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: filteredAffiliates.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewPage()));
                              },
                              child: Container(
                                height: height * 0.32,
                                width: width * 0.9,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black87, width: 1),
                                      ),
                                      child: Icon(Icons.add, size: width * .07, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 10),
                                    Text('Add New', style: TextStyle(fontWeight: FontWeight.w400, fontSize: width * .035)),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            final affiliate = filteredAffiliates[index - 1];
                            final myLeads = leads.where((l) => l.marketerId == affiliate.id).toList();
                            final totalLeads = myLeads.length.toString();
                            final score = totalLeads != '0' ? '75%' : 'N/A';

                            final isChecked = selectedAffiliateIds.contains(affiliate.id);

                            return Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (isSelectionMode) {
                                      setState(() {
                                        if (isChecked) {
                                          selectedAffiliateIds.remove(affiliate.id);
                                          selectedAffiliates.removeWhere((a) => a.id == affiliate.id);
                                        } else {
                                          selectedAffiliateIds.add(affiliate.id.toString());
                                          selectedAffiliates.add(affiliate);
                                        }
                                      });
                                    } else {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => HireSinglePage(affiliate: affiliate)));
                                    }
                                  },
                                  child: _buildCandidateCard(
                                    name: affiliate.name,
                                    location: affiliate.zone,
                                    totalLeads: totalLeads,
                                    industry:  '',
                                    score: score,
                                    avatar: affiliate.profile ?? '',
                                    width: width,
                                  ),
                                ),
                                if (isSelectionMode)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Checkbox(
                                      value: isChecked,
                                      onChanged: (_) {
                                        setState(() {
                                          if (isChecked) {
                                            selectedAffiliateIds.remove(affiliate.id);
                                            selectedAffiliates.removeWhere((a) => a.id == affiliate.id);
                                          } else {
                                            selectedAffiliateIds.add(affiliate.id.toString());
                                            selectedAffiliates.add(affiliate);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            );
                          }
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error loading leads: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading affiliates: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Filter Button
  Widget _buildFilterButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan[100] : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? Colors.cyan : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.cyan[700] : Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isSelected && (text == 'Location' || text == 'Performance'))
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  /// Reusable Card Widget
  Widget _buildCandidateCard({
    required String name,
    required String location,
    required String totalLeads,
    required String industry,
    required String score,
    required String avatar,
    required double width,
  }) {
    return Container(
      height: height * 0.33,
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[400]!, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? Icon(Icons.person, color: Colors.grey[600], size: 30) : null,
            ),
          ),
          SizedBox(height: height * .005),
          Text(name, style: GoogleFonts.roboto(fontSize: width * .04, fontWeight: FontWeight.w500)),
          SizedBox(height: height * .001),
          Text(location, style: GoogleFonts.roboto(fontSize: width * .03, fontWeight: FontWeight.w400, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Total leads : ', style: GoogleFonts.roboto(fontSize: width * .035)),
              Text(totalLeads, style: GoogleFonts.roboto(fontSize: width * .035, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Industry  :', style: GoogleFonts.roboto(fontSize: width * .035)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: industry
                      .split(',')
                      .map((e) => Text(e.trim(), style: GoogleFonts.roboto(fontSize: width * .035)))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('LQ - $score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)),
        ],
      ),
    );
  }
}