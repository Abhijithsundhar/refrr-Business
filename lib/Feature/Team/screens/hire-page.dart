import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Team/screens/addNew-page.dart';
import 'package:refrr_admin/Feature/Team/screens/hire-singlepage.dart';

class HirePage extends ConsumerStatefulWidget {
  final AsyncValue<List<ServiceLeadModel>>? serviceLead;
  final AsyncValue<List<AffiliateModel>>? affiliate;
  final LeadsModel? currentFirm;
  const HirePage({
    super.key,
    required this.serviceLead,
    required this.affiliate,
    required this.currentFirm,
  });

  @override
  ConsumerState<HirePage> createState() => _HirePageState();
}

class _HirePageState extends ConsumerState<HirePage> {
  String selectedFilter = 'All';
  String? selectedLocation;
  Set<String> selectedIndustries = {}; // NEW: multi-industry selection
  bool isSelectionMode = false;
  Set<String> selectedAffiliateIds = {};
  List<AffiliateModel> selectedAffiliates = [];
  bool isUploading = false;
  List<AffiliateModel> existingTeam = [];

  @override
  void initState() {
    super.initState();
    existingTeam = widget.currentFirm?.teamMembers ?? [];
  }

  @override
  void didUpdateWidget(covariant HirePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep local cache aligned with latest firm state
    if (oldWidget.currentFirm != widget.currentFirm) {
      setState(() {
        existingTeam = widget.currentFirm?.teamMembers ?? existingTeam;
      });
    }
  }

  // Build a set of IDs for members already in team (union of local + firm)
  Set<String> _existingIdSet() {
    final a = widget.currentFirm?.teamMembers ?? const <AffiliateModel>[];
    final b = existingTeam;
    return {
      ...a.map(_affId),
      ...b.map(_affId),
    };
  }

  String getSpacedCount(int count) {
    if (count < 10) {
      return '   ${count.toString()}   ';
    } else if (count < 100) {
      return '${count.toString()} ';
    } else {
      return count.toString();
    }
  }

  void _selectLocation(List<AffiliateModel> affiliates) async {
    final zones = affiliates.map((a) => a.zone).toSet().toList();
    zones.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Location'),
        children: zones
            .map((zone) => SimpleDialogOption(
          child: Text(zone),
          onPressed: () => Navigator.pop(ctx, zone),
        ))
            .toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedLocation = selected;
        selectedFilter = 'Location';
      });
    }
  }

  Future<void> _selectIndustry(List<AffiliateModel> affiliates) async {
    // Build a unique, sorted list of all industries present across affiliates
    final allIndustries = affiliates
        .expand((a) => getAffiliateIndustries(a))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) {
        final tempSelected = {...selectedIndustries};
        return AlertDialog(
          title: const Text('Select Industries'),
          content: SizedBox(
            width: width * .7,
            height: height * .5,
            child: StatefulBuilder(
              builder: (context, setSB) {
                return ListView.builder(
                  itemCount: allIndustries.length,
                  itemBuilder: (context, i) {
                    final ind = allIndustries[i];
                    final checked = tempSelected.contains(ind);
                    return CheckboxListTile(
                      value: checked,
                      title: Text(ind),
                      onChanged: (v) {
                        setSB(() {
                          if (v == true) {
                            tempSelected.add(ind);
                          } else {
                            tempSelected.remove(ind);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, <String>{}),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, tempSelected),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedIndustries = result;
        selectedFilter = 'Industry';
      });
    }
  }

  String _industryFilterLabel() {
    if (selectedIndustries.isEmpty) return 'Industry';
    if (selectedIndustries.length == 1) return selectedIndustries.first;
    return 'Industry (${selectedIndustries.length})';
  }



  // Parse multiple industries from a single `industry` string.
  // Supports delimiters: comma, slash, pipe. Example: "Design, Marketing|Sales/Tech"
  List<String> getAffiliateIndustries(AffiliateModel affiliate) {
    final raw = affiliate.industry; // assuming `industry` exists on model
    if (raw == null) return const [];
    final parts = raw
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return parts;
  }

  List<AffiliateModel> applyFilters(
      List<AffiliateModel> allAffiliates,
      List<ServiceLeadModel> allLeads, {
        required Set<String> excludeIds,
      }) {
    // 1) Exclude existing team members first
    List<AffiliateModel> filtered =
    allAffiliates.where((a) => !excludeIds.contains(_affId(a))).toList();

    // 2) Apply filter: Location
    if (selectedFilter == 'Location' && selectedLocation != null) {
      filtered = filtered
          .where((a) => a.zone.toLowerCase() == selectedLocation!.toLowerCase())
          .toList();
    }

    // 3) Apply filter: Performance (example: >=5 leads)
    if (selectedFilter == 'Performance') {
      filtered = filtered.where((affiliate) {
        final leadCount =
            allLeads.where((lead) => lead.marketerId == affiliate.id).length;
        return leadCount >= 5;
      }).toList();
    }

    // 4) Apply filter: Industry (affiliate must match any selected industry)
    if (selectedFilter == 'Industry' && selectedIndustries.isNotEmpty) {
      filtered = filtered.where((a) {
        final inds = getAffiliateIndustries(a);
        return inds.any((i) => selectedIndustries.contains(i));
      }).toList();
    }

    return filtered;
  }

  void _toggleSelectMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedAffiliateIds.clear();
        selectedAffiliates.clear();
      }
    });
  }

  void _toggleAffiliate(AffiliateModel affiliate) {
    final idStr = _affId(affiliate);
    final isChecked = selectedAffiliateIds.contains(idStr);
    setState(() {
      if (isChecked) {
        selectedAffiliateIds.remove(idStr);
        selectedAffiliates.removeWhere((a) => _affId(a) == idStr);
      } else {
        selectedAffiliateIds.add(idStr);
        if (!selectedAffiliates.any((a) => _affId(a) == idStr)) {
          selectedAffiliates.add(affiliate);
        }
      }
    });
  }

  // Unique key for affiliate (falls back if id is null/empty)
  String _affId(AffiliateModel a) {
    final id = a.id?.toString();
    if (id != null && id.isNotEmpty) return id;
    return '${a.name}|${a.zone}|${a.profile}';
  }

  // Merge without duplicates, keeping last occurrence
  List<AffiliateModel> _mergeUnique(
      List<AffiliateModel> a, List<AffiliateModel> b) {
    final map = <String, AffiliateModel>{};
    for (final x in a) map[_affId(x)] = x;
    for (final x in b) map[_affId(x)] = x;
    return map.values.toList();
  }

  Future<void> _confirmAndHire() async {
    if (selectedAffiliates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No marketers selected.')),
      );
      return;
    }

    showCommonAlertBox(
      context,
      'Are you sure add them to your team?',
          () async {
        try {
          setState(() => isUploading = true);

          // Union of everything we might have: firm (possibly refreshed), local cache, and new selections
          final firmTeam =
              widget.currentFirm?.teamMembers ?? <AffiliateModel>[];
          final base = _mergeUnique(firmTeam, existingTeam);
          final merged = _mergeUnique(base, selectedAffiliates);

          final updatedLead =
          widget.currentFirm!.copyWith(teamMembers: merged);

          await ref
              .read(leadControllerProvider.notifier)
              .updateLead(context: context, leadModel: updatedLead);

          setState(() {
            existingTeam = merged; // keep local cache up to date
            isSelectionMode = false;
            selectedAffiliateIds.clear();
            selectedAffiliates.clear();
          });

          final addedCount = merged.length - base.length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                Text('Hiring successful. Added $addedCount marketer(s).')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to hire: $e')),
          );
        } finally {
          if (mounted) setState(() => isUploading = false);
        }
      },
      'Yes',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.black,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              if (isSelectionMode)
                TextButton(
                  onPressed: _toggleSelectMode,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.only(left: width * .04, right: width * .05),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hire text row
                  Row(
                    children: [
                      Text('Hire Marketers',
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: width * .05)),
                      const Spacer(),
                      const Icon(Icons.search)
                    ],
                  ),
                  SizedBox(height: height * .02),

                  // Filters Row with fixed size buttons
                  widget.affiliate!.when(
                    data: (affiliates) {
                      final totalCount = affiliates.length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width * .2,
                            height: 30,
                            child: _buildFilterButton(
                              'All (${getSpacedCount(totalCount)})',
                              selectedFilter == 'All',
                                  () {
                                setState(() {
                                  selectedFilter = 'All';
                                  selectedLocation = null;
                                  selectedIndustries.clear();
                                });
                              },
                              width,height
                            ),
                          ),
                          SizedBox(width: width * .01),
                          SizedBox(
                            width: width * .22,
                            height: 30,
                            child: _buildFilterButton(
                              selectedLocation ?? 'Location',
                              selectedFilter == 'Location',
                                  () => _selectLocation(affiliates),
                                width,height                            ),
                          ),
                          SizedBox(width: width * .01),
                          SizedBox(
                            width: width * .22,
                            height: 30,
                            child: _buildFilterButton(
                              _industryFilterLabel(),
                              selectedFilter == 'Industry',
                                  () => _selectIndustry(affiliates),
                                width,height                            ),
                          ),
                          SizedBox(width: width * .01),
                          SizedBox(
                            width: width * .22,
                            height: 30,
                            child: _buildFilterButton(
                              'Performance',
                              selectedFilter == 'Performance',
                                  () {
                                setState(() {
                                  selectedFilter = 'Performance';
                                });
                              },
                                width,height                            ),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),

                  SizedBox(height: height * .02),

                  // Grid of Affiliates (Add new card only when filter is All)
                  widget.affiliate!.when(
                    data: (affiliates) {
                      return widget.serviceLead!.when(
                        data: (leads) {
                          final excludeIds = _existingIdSet();
                          final filteredAffiliates = applyFilters(
                            affiliates,
                            leads,
                            excludeIds: excludeIds,
                          );
                          final itemCount = filteredAffiliates.length +
                              (selectedFilter == 'All' ? 1 : 0);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio:
                              0.65, // Same aspect ratio for all cards
                            ),
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              if (selectedFilter == 'All' && index == 0) {
                                // Add New card with same dimensions
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const AddNewPage()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                        14), // Same padding as other cards
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 60, // Same size as profile avatar
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black87,
                                                width: 1),
                                          ),
                                          child: Icon(Icons.add,
                                              size: width * .07,
                                              color: Colors.black87),
                                        ),
                                        SizedBox(height: height * 0.006),
                                        // Same spacing
                                        Text(
                                          'Add New',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w500,
                                            fontSize: width * .04, // Same font size as names
                                            color: Colors.black,
                                          ),
                                        ),
                                        // SizedBox(height: height*.02,)
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                final idx = selectedFilter == 'All' ? index - 1 : index;
                                final affiliate = filteredAffiliates[idx];
                                final myLeads = leads
                                    .where((l) => l.marketerId == affiliate.id)
                                    .toList();
                                final totalLeads = myLeads.length;
                                final lqScore = affiliate.leadScore;
                                final industries = getAffiliateIndustries(affiliate);
                                final idStr = _affId(affiliate);
                                final isChecked = selectedAffiliateIds.contains(idStr);

                                return Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (isSelectionMode) {
                                          _toggleAffiliate(affiliate);
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HireSinglePage(
                                                  affiliate: affiliate, currentFirm: widget.currentFirm,),
                                            ),
                                          );
                                        }
                                      },
                                      child: _buildCandidateCard(
                                        model: affiliate,
                                        width: width,
                                        height: height,
                                        totalLeads: totalLeads,
                                        lqScore: lqScore!.round().toString(),
                                        isSelected: isChecked,
                                        industries: industries,
                                      ),
                                    ),

                                    if (isSelectionMode)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _toggleAffiliate(affiliate),
                                          child: _selectionBadge(isChecked),
                                        ),
                                      ),
                                  ],
                                );
                              }
                            },
                          );
                        },
                        loading: () =>
                        const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Center(child: Text('Error loading leads: $e')),
                      );
                    },
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Error loading affiliates: $e')),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Select/Hire button
        Positioned(
          top: height * .91,
          left: width * .66,
          child: GestureDetector(
            onTap: () {
              if (isSelectionMode) {
                _confirmAndHire();
              } else {
                _toggleSelectMode();
              }
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
                  Container(
                    padding: EdgeInsets.all(width * 0.01),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.white, width: width * .001),
                      shape: BoxShape.rectangle,
                    ),
                    child: Icon(
                      isSelectionMode
                          ? Icons.shopping_bag_outlined
                          : Icons.done,
                      color: Colors.white,
                      size: width * 0.03,
                    ),
                  ),
                  SizedBox(width: width * .02),
                  Text(
                    isSelectionMode ? 'Hire' : 'Select',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Busy overlay
        if (isUploading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _selectionBadge(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? Colors.black : Colors.white,
        border: Border.all(
          color: isChecked ? Colors.black : Colors.black54,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child:
      isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  Widget _buildFilterButton(
      String text, bool isSelected, VoidCallback onTap, double width, double height) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.27,
        height: height * 0.043,
        decoration: BoxDecoration(
          // color: isSelected ? Colors.black : const Color(0xFFF3F3F3),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.roboto(
              fontSize: width * 0.03,
              fontWeight: FontWeight.w400,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCandidateCard({
    required AffiliateModel model,
    required List<String> industries,
    required double width,
    required double height,
    required int totalLeads,
    required String lqScore,
    required bool isSelected,
  }) {
    // Prepare compact industry display: show up to 2, then "+N more"
    final displayIndustries = industries.take(2).toList();
    final extraCount = industries.length - displayIndustries.length;

    final industriesText = displayIndustries.isEmpty
        ? 'Not added'
        : displayIndustries.join(', ') +
        (extraCount > 0 ? ' +$extraCount more' : '');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
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
              backgroundImage:
              model.profile.isNotEmpty ? NetworkImage(model.profile) :AssetImage('assets/image.png'),

            ),
          ),
          SizedBox(height: height * 0.006),
          Text(model.name.length > 15
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total leads : ',
                  style: GoogleFonts.roboto(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Text(totalLeads.toString(),
                    style: GoogleFonts.roboto(
                      fontSize: width * .035,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // CHANGED: Industry row with 2-line cap and proper wrap indent
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '     Industry : ',
                  style: GoogleFonts.roboto(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Text(
                    industriesText,
                    style: GoogleFonts.roboto(
                      fontSize: width * .028,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'LQ - $lqScore %',
            style: GoogleFonts.roboto(
              fontSize: width * .05,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
        ],
      ),
    );
  }
}