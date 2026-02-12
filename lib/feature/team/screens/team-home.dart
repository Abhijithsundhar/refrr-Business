import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/Login/Screens/connectivity.dart';
import 'package:refrr_admin/Feature/Team/screens/bottomsheets/add-own-team-bottomsheet1.dart';
import 'package:refrr_admin/Feature/Team/screens/functions/card%20funtion.dart';
import 'package:refrr_admin/Feature/Team/screens/hire-page.dart';
import 'package:refrr_admin/Feature/Team/screens/hireBottomSheet.dart';
import 'package:refrr_admin/Feature/Team/screens/profile.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/city-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/scale/country-bottom-sheet.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/country-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class TeamHome extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const TeamHome({super.key, this.currentFirm});

  @override
  ConsumerState<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends ConsumerState<TeamHome> {
  CountryModel? selectedCountry;

  @override
  Widget build(BuildContext context) {
    // 🔹 Watch the team provider with the lead ID
    final teamAsync = ref.watch(teamProvider(widget.currentFirm!.reference!.id));

    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Pallet.backgroundColor,
        appBar: teamAsync.when(
          data: (team) => CustomAppBar(
            title: 'Our team (${team.length.toString().padLeft(2, '0')})',
            showBackButton: false,
          ),
          loading: () => CustomAppBar(
            title: 'Our team',
            showBackButton: false,
          ),
          error: (_, __) => CustomAppBar(
            title: 'Our team (0)',
            showBackButton: false,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: w * 0.02),

              /// 🔹 FILTERS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                child: Row(
                  children: [
                    /// ALL - Fixed width chip
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

                    /// LOCATION - Compact chip
                    chipButtonExpanded(
                      title: selectedLocation ?? 'Location',
                      isSelected: selectedLocation != null && selectedFilter != 'All',
                      showArrow: true,
                      onTap: () {
                        showLocationBottomSheet(
                          context: context,
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

                    /// INDUSTRY - Compact chip
                    chipButtonExpanded(
                      title: selectedIndustry ?? 'Industry',
                      isSelected: selectedIndustry != null && selectedFilter != 'All',
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

              SizedBox(height: w * 0.02),

              /// 🔹 TEAM GRID
              Expanded(
                child: teamAsync.when(
                  data: (team) {
                    debugPrint('📋 team data received: ${team.length} members');

                    // Apply filters
                    List<AffiliateModel> filtered = List.from(team);

                    // Filter by location
                    if (selectedLocation != null && selectedFilter != 'All') {
                      filtered = filtered.where((a) {
                        final zone = a.zone;
                        return zone.toLowerCase() == selectedLocation!.toLowerCase();
                      }).toList();
                    }

                    // Filter by industry
                    if (selectedIndustry != null && selectedFilter != 'All') {
                      filtered = filtered.where((a) {
                        final industry = a.industry.toString().toLowerCase();
                        return industry.contains(selectedIndustry!.toLowerCase());
                      }).toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: w * 0.15,
                              color: Pallet.greyColor,
                            ),
                            SizedBox(height: w * 0.03),
                            Text('No team members found',
                              style: GoogleFonts.dmSans(
                                fontSize: w * 0.04,
                                color: Pallet.greyColor,
                              ),
                            ),
                            SizedBox(height: w * 0.02),
                            Text('Tap "Hire" to add team members',
                              style: GoogleFonts.dmSans(
                                fontSize: w * 0.035,
                                color: Pallet.greyColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.all(w * 0.03),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: w * 0.03,
                        mainAxisSpacing: w * 0.03,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final affiliate = filtered[i];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccountProfileScreen(
                                  affiliate: affiliate,
                                  currentFirm: widget.currentFirm,
                                ),
                              ),
                            );
                          },
                          child: teamCard(affiliate),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CommonLoader()),
                  error: (e, stack) {
                    debugPrint('❌ Error loading team: $e');
                    debugPrint('Stack: $stack');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: w * 0.15,
                            color: Colors.red,
                          ),
                          SizedBox(height: w * 0.03),
                          Text('Error loading team',
                            style: GoogleFonts.dmSans(
                              fontSize: w * 0.04,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: w * 0.02),
                          Text(e.toString(),
                            style: GoogleFonts.dmSans(
                              fontSize: w * 0.03,
                              color: Pallet.greyColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        /// 🔹 HIRE BUTTON
        floatingActionButton: SizedBox(
          height: h * .06,
          width: w * 0.25,
          child: InkWell(
            borderRadius: BorderRadius.circular(w * 0.02),
            onTap: () {
              showHireMarketersDialog(
                context,
                onGrroTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HirePage(currentFirm: widget.currentFirm),
                    ),
                  );
                },
                onOwnTeamTap: () {
                  registrationBottomSheet(context, widget.currentFirm);
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: w * 0.025,
              ),
              decoration: BoxDecoration(
                color: Pallet.primaryColor,
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConstants.add,
                    width: w * 0.055,
                    color: Colors.white,
                  ),
                  SizedBox(width: w * 0.01),
                  Text('Hire',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 LOCATION BOTTOM SHEET - NOW USES CITIES FROM FIREBASE
  void showLocationBottomSheet({
    required BuildContext context,
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
            final searchText = ref.watch(locationSearchProvider);
            final citiesAsyncValue = ref.watch(citiesStreamProvider(widget.currentFirm!.reference!.id));

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
                  // Handle/Drag indicator
                  Container(
                    width: width * 0.12,
                    height: width * 0.012,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(height: width * 0.04),

                  // Header
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

                  SizedBox(height: width * 0.04),

                  // Search and Country Selector Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildCountrySelector(),
                      ),
                      SizedBox(width: width * 0.02),
                      Expanded(
                        child: Container(
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

                  SizedBox(height: width * 0.04),

                  // Cities List
                  Flexible(
                    child: citiesAsyncValue.when(
                      data: (cities) {
                        // Filter out deleted cities and apply search
                        final filteredCities = cities
                            .where((city) => !city.isDeleted)
                            .where((city) {
                          if (searchText.isEmpty) return true;
                          final cityName = city.zone.toLowerCase();
                          final query = searchText.toLowerCase();
                          return cityName.contains(query);
                        }).toList();

                        // Further filter by selected country if any
                        final finalCities = selectedCountry != null
                            ? filteredCities.where((city) {
                          return city.country.toLowerCase() ==
                              selectedCountry!.countryName.toLowerCase();
                        }).toList()
                            : filteredCities;

                        if (finalCities.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(width * 0.1),
                              child: Text(
                                'No cities found',
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.038,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: finalCities.length,
                          separatorBuilder: (_, __) => SizedBox(height: width * 0.02),
                          itemBuilder: (_, index) {
                            final city = finalCities[index];
                            final cityName = city.zone;
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                ref.read(locationSearchProvider.notifier).state = '';
                                Navigator.pop(context);
                                onSelect(cityName);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.04,
                                  vertical: width * 0.035,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    if (city.profile.isNotEmpty) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: city.profile,
                                          width: width * 0.1,
                                          height: width * 0.1,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.location_city,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                          errorWidget: (_, __, ___) => Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.location_city,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cityName,
                                            style: GoogleFonts.dmSans(
                                              fontSize: width * 0.038,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (city.country.isNotEmpty) ...[
                                            SizedBox(height: width * 0.005),
                                            Text(
                                              city.country,
                                              style: GoogleFonts.dmSans(
                                                fontSize: width * 0.03,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade400,
                                      size: width * 0.05,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => Padding(
                        padding: EdgeInsets.all(width * 0.1),
                        child: CommonLoader(),
                      ),
                      error: (error, stack) => Padding(
                        padding: EdgeInsets.all(width * 0.1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: width * 0.1,
                            ),
                            SizedBox(height: width * 0.02),
                            Text(
                              'Error loading cities',
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.035,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: width * 0.01),
                            Text(
                              error.toString(),
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.03,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 COUNTRY SELECTOR - FIXED VERSION
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
            Expanded(
              child: Text(
                selectedCountry?.countryName ?? "Select Country",
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.w500,
                  color: selectedCountry != null
                      ? Colors.black87
                      : Pallet.greyColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
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
