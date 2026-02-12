import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/constants/location-list.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Team/screens/functions/card%20funtion.dart';
import 'package:refrr_admin/Feature/Team/screens/non-hired-profile.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/scale/country-bottom-sheet.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/country-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';

class HirePage extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;

  const HirePage({super.key, required this.currentFirm,});

  @override
  ConsumerState<HirePage> createState() => _HirePageState();
}

class _HirePageState extends ConsumerState<HirePage> {
  CountryModel? selectedCountry;

  @override
  Widget build(BuildContext context) {
    final bool showHireButton = isSelectionMode && selectedIds.isNotEmpty;

    final affiliateAsync = ref.watch(affiliateStreamProvider(''));

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Pallet.backgroundColor,
          appBar: CustomAppBar(
            title: 'Hire Marketers',
            actionWidget: GestureDetector(
              onTap: () {
                setState(() {
                  isSelectionMode = !isSelectionMode;
                  selectedIds.clear();
                  selectedAffiliates.clear();
                });
              },
              child: Row(
                children: [
                  if (isSelectionMode)
                    SvgPicture.asset(AssetConstants.close, width: w * 0.07),
                  SizedBox(width: w * 0.02),
                  Container(
                    width: w * 0.2,
                    height: w * 0.08,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w * 0.08),
                      border: Border.all(color: Pallet.borderColor),
                    ),
                    child: Center(
                      child: Text(
                        isSelectionMode
                            ? 'Select (${selectedIds.length})'
                            : 'Select',
                        style: GoogleFonts.dmSans(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.w500,
                          color: Pallet.greyColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 🔸 FILTERS
                Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Row(
                    children: [
                      chipButton(
                        title: 'All',
                        isSelected: selectedFilter == 'All',
                        onTap: () {
                          setState(() {
                            selectedFilter = 'All';
                            selectedLocation = null;
                            selectedIndustry = null;
                          });
                        },
                      ),
                      SizedBox(width: w * 0.02),
                      chipButtonExpanded(
                        title: selectedLocation ?? 'Location',
                        isSelected:
                        selectedLocation != null && selectedFilter != 'All',
                        showArrow: true,
                        onTap: () {
                          showLocationBottomSheet(
                            context: context,
                            items: allCities,
                            onSelect: (value) {
                              setState(() {
                                selectedLocation = value;
                                selectedFilter = null;
                              });
                            },
                          );
                        },
                      ),
                      SizedBox(width: w * 0.02),
                      chipButtonExpanded(
                        title: selectedIndustry ?? 'Industry',
                        isSelected:
                        selectedIndustry != null && selectedFilter != 'All',
                        showArrow: true,
                        onTap: () {
                          showIndustryBottomSheet(
                            context: context,
                            onSelect: (value) {
                              setState(() {
                                selectedIndustry = value;
                                selectedFilter = null;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 🔸 GRID / LOADER / ERROR
                Expanded(
                  child: affiliateAsync.when(
                    loading: () => Center(child: CommonLoader()),
                    error: (e, stack) => buildError(e, stack, w),
                    data: (affiliates) {
                      List<AffiliateModel> filtered = affiliates
                          .where((a) => a.addedBy != widget.currentFirm?.reference?.id).toList();

                      if (selectedLocation != null) {
                        filtered = filtered.where((a) =>
                        (a.zone ?? '').toLowerCase() == selectedLocation!.toLowerCase()).toList();
                      }

                      if (selectedIndustry != null) {
                        filtered = filtered.where((a) => ((a.industry as String?) ?? '')
                                .toLowerCase().contains(selectedIndustry!.toLowerCase())).toList();
                      }

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'No data found',
                            style: GoogleFonts.dmSans(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Pallet.greyColor,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.all(w * 0.03),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: w * 0.03,
                          mainAxisSpacing: w * 0.03,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final affiliate = filtered[i];
                          final id = affId(affiliate);
                          final checked = selectedIds.contains(id);

                          return GestureDetector(
                            onLongPress: () {
                              if (!isSelectionMode) {
                                setState(() {
                                  isSelectionMode = true;
                                  selectedIds.add(id);
                                  selectedAffiliates.add(affiliate);
                                });
                              }
                            },
                            onTap: () {
                              if (isSelectionMode) {
                                setState(() {
                                  if (checked) {
                                    selectedIds.remove(id);
                                    selectedAffiliates.removeWhere(
                                            (e) => affId(e) == id);
                                  } else {
                                    selectedIds.add(id);
                                    selectedAffiliates.add(affiliate);
                                  }
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NonTeamProfile(
                                      affiliate: affiliate,
                                      currentFirm: widget.currentFirm,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: affiliateCard(affiliate, checked),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🔹 HIRE BUTTON
        if (showHireButton)
          Positioned(
            bottom: h * 0.02,
            left: w * 0.07,
            right: w * 0.07,
            child: ElevatedButton(
              onPressed: !isHiring ? _confirmAndHire : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: !isHiring
                    ? Pallet.secondaryColor
                    : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.03),
                ),
                padding: EdgeInsets.symmetric(vertical: w * 0.04),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isHiring)
                    SizedBox(
                      width: w * 0.06,
                      height: w * 0.06,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    SvgPicture.asset(
                      AssetConstants.hire,
                      width: w * 0.06,
                      color: Colors.white,
                    ),
                  SizedBox(width: w * 0.02),
                  Text(
                    isHiring
                        ? 'Hiring...'
                        : 'Hire (${selectedIds.length})',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: w * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 🔹 UPLOADING OVERLAY
        if (isUploading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.5),
              child: const Center(
                child: CommonLoader(),
              ),
            ),
          ),
      ],
    );
  }
  Future<void> _confirmAndHire() async {
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

      if (selectedAffiliates.isEmpty) {
        showCommonSnackbar(context, 'No affiliates selected');
        return;
      }


      final data = widget.currentFirm;
      if (data == null) {
        showCommonSnackbar(context, 'Firm data not found');
        return;
      }

      final List<String> teamMembers = data.teamMembers;
      final int teamLimit = data.teamLimit;

      final int currentCount = teamMembers.length;
      final int newCount = currentCount + selectedAffiliates.length;

      if (newCount > teamLimit) {
        showTeamLimitAlert(context,data.teamLimit);
        return;
      }

      setState(() => isHiring = true);

      debugPrint('🚀 Starting hire process for ${selectedAffiliates.length} affiliates');

      final result = await ref.read(affiliateControllerProvider.notifier)
          .hireAffiliates(leadId: leadId, affiliates: selectedAffiliates,
        context: context,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        debugPrint('🎉 Successfully hired ${result['added']} affiliates');
        setState(() {
          isHiring = false;
          isSelectionMode = false;
          selectedIds.clear();
          selectedAffiliates.clear();
        });
      } else {
        debugPrint('⚠️ Hire failed or all already hired');
        setState(() => isHiring = false);
      }
    } catch (e, stack) {
      debugPrint('❌ Error hiring affiliates: $e');
      debugPrint('📋 Stack trace: $stack');
      if (mounted) {
        showCommonSnackbar(context, 'Failed to hire: $e');
        setState(() => isHiring = false);
      }
    }
  }
  void showLocationBottomSheet({
    required BuildContext context,
    required List<String> items,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width * 0.06),
        ),
      ),
      builder: (_) {
        return Consumer(
          builder: (context, ref, child) {
            final selectedCountry = ref.watch(selectedCountryProvider);
            final searchText = ref.watch(locationSearchProvider);

            List<String> filteredItems = items;

            if (selectedCountry.isNotEmpty) {
              filteredItems = filteredItems.where((item) {
                return item.toLowerCase().contains(selectedCountry.toLowerCase());
              }).toList();
            }

            if (searchText.isNotEmpty) {
              filteredItems = filteredItems.where((item) {
                return item.toLowerCase().contains(searchText.toLowerCase());
              }).toList();
            }

            return Padding(
              padding: EdgeInsets.only(
                left: width * 0.05,
                right: width * 0.05,
                top: width * 0.04,
                bottom: MediaQuery.of(context).viewInsets.bottom + width * 0.04,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: width * 0.12,
                    height: width * 0.012,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: width * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Location',
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(selectedCountryProvider.notifier).state = '';
                          ref.read(locationSearchProvider.notifier).state = '';
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(width * 0.015),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: width * 0.045,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.03),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCountrySelector(),
                      ),
                      SizedBox(width: width * 0.02),
                      Expanded(
                        child: Container(
                          width: width * 0.9,
                          height: height * 0.055,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCED4DA)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              ref.read(locationSearchProvider.notifier).state = value;
                            },
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: const TextStyle(
                                color: Color(0xFFADB5BD),
                                fontSize: 14,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 12, right: 6),
                                child: Icon(
                                  Icons.search,
                                  color: Color(0xFFADB5BD),
                                  size: 20,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: height * 0.017,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.03),
                  Flexible(
                    child: filteredItems.isEmpty
                        ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.1),
                        child: Text(
                          'No locations found',
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.038,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                        : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: width * 0.02),
                      itemBuilder: (_, index) {
                        final item = filteredItems[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            ref.read(selectedCountryProvider.notifier).state = '';
                            ref.read(locationSearchProvider.notifier).state = '';
                            Navigator.pop(context);
                            onSelect(item);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.02,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: width * 0.05,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.black54,
                                    size: width * 0.045,
                                  ),
                                ),
                                SizedBox(width: width * 0.04),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * 0.038,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: width * 0.02),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildCountrySelector() {
    return GestureDetector(
      onTap: () {
        showCountryBottomSheet(
          context,
          selectedCountry: selectedCountry,
          onSelect: (country) {
            setState(() {
              selectedCountry = country;
              marketerCountryController.text = country.countryName;
            });
          },
        );
      },
      child: Container(
        height: width * 0.13,
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Pallet.borderColor),
          borderRadius: BorderRadius.circular(width * 0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (selectedCountry != null) ...[
                  SizedBox(width: width * 0.03),
                ],
                Text(
                  selectedCountry?.countryName ?? "Select Country",
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.038,
                    fontWeight: FontWeight.w500,
                    color: selectedCountry != null
                        ? Colors.black87
                        : Pallet.greyColor,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black54,
              size: width * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}