import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/alert_dailogs/hire_confirmation_alert.dart';
import 'package:refrr_admin/core/common/chat_screen_support_functions.dart';
import 'package:refrr_admin/core/common/custom_appBar.dart';
import 'package:refrr_admin/core/common/custom_round_button.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/text_editing_controllers.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/constants/colorconstnats.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/pipeline/Controller/city_controller.dart';
import 'package:refrr_admin/feature/pipeline/Controller/zone_controller.dart';
import 'package:refrr_admin/feature/pipeline/screens/scale/country_bottom_sheet.dart';
import 'package:refrr_admin/models/city_model.dart';
import 'package:refrr_admin/models/country_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';

class Scale extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  final List<ServiceLeadModel>? serviceLeads;
  const Scale({super.key, this.currentFirm, this.serviceLeads});

  @override
  ConsumerState<Scale> createState() => _ScaleState();
}

class _ScaleState extends ConsumerState<Scale> with SingleTickerProviderStateMixin {
  CountryModel? selectedCountry;
  String searchQuery = '';

  // Search bar animation
  bool _isSearchExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  TextStyle get _itemNameStyle => GoogleFonts.dmSans(
    fontSize: width * 0.04,
    fontWeight: FontWeight.w600,
  );

  TextStyle get _buttonTextStyle => GoogleFonts.dmSans(
    fontSize: width * 0.032,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (_isSearchExpanded) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _searchFocusNode.requestFocus();
      });
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
      setState(() {
        searchQuery = '';
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
    });
  }

  // ================== CHECK IF CITY MATCHES COUNTRY ==================
  bool _doesCityMatchCountry(Map<String, dynamic> city, CountryModel? country) {
    if (country == null) return true; // No filter, show all

    // Get all possible country identifiers from the city data
    final cityCountryId = (city['countryId'] ?? '').toString().trim().toUpperCase();
    final cityCountryName = (city['countryName'] ?? '').toString().trim().toUpperCase();
    final cityCountry = (city['country'] ?? '').toString().trim().toUpperCase();
    final cityCountryCode = (city['countryCode'] ?? '').toString().trim().toUpperCase();

    // Get all possible identifiers from the selected country
    final selectedShortName = country.shortName.toUpperCase();
    final selectedCountryName = country.countryName.toUpperCase();
    final selectedId = (country.documentId ?? '').toUpperCase();

    // Match against any combination
    return cityCountryId == selectedShortName ||
        cityCountryId == selectedCountryName ||
        cityCountryId == selectedId ||
        cityCountryName == selectedShortName ||
        cityCountryName == selectedCountryName ||
        cityCountry == selectedShortName ||
        cityCountry == selectedCountryName ||
        cityCountryCode == selectedShortName;
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(
        citiesStreamProvider(widget.currentFirm?.reference?.id ?? ''));
    final zonalCitiesAsync = ref.watch(uniqueCitiesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Scale',
        showBackButton: true,
        actionWidget: Padding(
          padding: EdgeInsets.only(right: width * 0.03),
          child: GestureDetector(
            onTap: _toggleSearch,
            child: CircleSvgButton(
              size: width * 0.08,
              child: _isSearchExpanded
                  ? Icon(
                Icons.close,
                size: width * 0.045,
                color: Colors.black,
              )
                  : SvgPicture.asset('assets/svg/search.svg'),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Search Bar
          _buildAnimatedSearchBar(),

          Padding(
            padding: EdgeInsets.only(left: width * 0.03, top: height * 0.02),
            child: Text(
              'Add Any City to Expand Your Business',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: width * 0.04,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: width * 0.03,
              right: width * 0.03,
              top: height * 0.02,
            ),
            child: _buildCountrySelector(),
          ),
          SizedBox(height: width * 0.05),
          citiesAsync.when(
            data: (addedCities) {
              return zonalCitiesAsync.when(
                data: (zonalCities) {
                  print('🎯 SCALE SCREEN: Received ${zonalCities.length} zonal cities');

                  for (var zone in zonalCities) {
                    print('   📍 ${zone['cityName']} | CountryId: ${zone['countryId']} | Country: ${zone['country']} | Image: ${zone['image']}');
                  }

                  return _buildPlaceList(addedCities, zonalCities);
                },
                loading: () => _buildLoading(),
                error: (error, stack) {
                  print('❌ SCALE SCREEN ERROR: $error');
                  return _buildError('Error loading cities: $error');
                },
              );
            },
            loading: () => _buildLoading(),
            error: (error, stack) {
              print('❌ ADDED CITIES ERROR: $error');
              return _buildError('Error loading added cities');
            },
          ),
          SizedBox(height: width * 0.01),
        ],
      ),
    );
  }

  // ================== ANIMATED SEARCH BAR ==================
  Widget _buildAnimatedSearchBar() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _heightAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.015,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Input Field
                  Container(
                    height: width * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(width * 0.02),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: width * 0.03),
                        Icon(
                          Icons.search,
                          color: Colors.black,
                          size: width * 0.055,
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.04,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search city...',
                              hintStyle: GoogleFonts.dmSans(
                                fontSize: width * 0.04,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Container(
                              padding: EdgeInsets.all(width * 0.02),
                              margin: EdgeInsets.only(right: width * 0.01),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                                size: width * 0.04,
                              ),
                            ),
                          ),
                        SizedBox(width: width * 0.02),
                      ],
                    ),
                  ),

                  // Search info
                  if (searchQuery.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.01),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: width * 0.04,
                            color: ColorConstants.primaryColor,
                          ),
                          SizedBox(width: width * 0.02),
                          Text(
                            'Searching for: "$searchQuery"',
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.032,
                              color: ColorConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================== COUNTRY SELECTOR ==================
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

            // Debug: Print selected country details
            print('═══════════════════════════════════════════════');
            print('🌍 SELECTED COUNTRY:');
            print('   Country Name: ${country.countryName}');
            print('   Short Name: ${country.shortName}');
            print('   ID: ${country.documentId}');
            print('═══════════════════════════════════════════════');
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
              child: Row(
                children: [
                  if (selectedCountry != null) ...[
                    _buildSelectedCountryFlag(),
                    SizedBox(width: width * 0.03),
                  ],
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
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedCountry != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCountry = null;
                        marketerCountryController.clear();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(width * 0.01),
                      margin: EdgeInsets.only(right: width * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: width * 0.035,
                      ),
                    ),
                  ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                  size: width * 0.06,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCountryFlag() {
    if (selectedCountry == null) return const SizedBox.shrink();
    if (selectedCountry!.flag.isNotEmpty) {
      return Container(
        width: 40,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Image.network(
            selectedCountry!.flag,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                alignment: Alignment.center,
                color: Colors.grey.shade50,
                child: Text(
                  getEmojiFlag(selectedCountry!.shortName),
                  style: TextStyle(fontSize: width * 0.04),
                ),
              );
            },
          ),
        ),
      );
    }
    return Container(
      width: 40,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Text(
        getEmojiFlag(selectedCountry!.shortName),
        style: TextStyle(fontSize: width * 0.05),
      ),
    );
  }

  String getEmojiFlag(String shortName) {
    if (shortName.isEmpty || shortName.length != 2) return '🏳️';
    final cleanCode = shortName.trim().toUpperCase();
    try {
      final firstLetter = cleanCode.codeUnitAt(0);
      final secondLetter = cleanCode.codeUnitAt(1);
      if (firstLetter >= 65 && firstLetter <= 90 &&
          secondLetter >= 65 && secondLetter <= 90) {
        return String.fromCharCode(firstLetter + 127397) +
            String.fromCharCode(secondLetter + 127397);
      }
    } catch (e) {
      debugPrint('Error generating emoji flag: $e');
    }
    return '🏳️';
  }

  // ================== LOADING WIDGET ==================
  Widget _buildLoading() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(
          color: ColorConstants.primaryColor,
        ),
      ),
    );
  }

  // ================== ERROR WIDGET ==================
  Widget _buildError(String message) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            message,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.04,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ================== PLACE LIST ==================
  Widget _buildPlaceList(
      List<CityModel> addedCities,
      List<Map<String, dynamic>> zonalCities,
      ) {
    final Set<String> addedCityNames =
    addedCities.map((city) => city.zone.toLowerCase().trim()).toSet();

    // 🔍 DEBUG: Print filtering info
    if (selectedCountry != null) {
      print('═══════════════════════════════════════════════');
      print('🔍 FILTERING BY COUNTRY:');
      print('   Selected: ${selectedCountry!.countryName} (${selectedCountry!.shortName})');
      print('───────────────────────────────────────────────');
    }

    List<Map<String, dynamic>> filteredCities = [];

    for (var city in zonalCities) {
      final cityName = (city['cityName'] ?? '').toString().toLowerCase().trim();

      // Use the helper method for country matching
      bool matchesCountry = _doesCityMatchCountry(city, selectedCountry);

      bool matchesSearch = searchQuery.isEmpty ||
          cityName.contains(searchQuery.trim());

      // Debug each city's match status when filtering
      if (selectedCountry != null) {
        print('   City: $cityName | CountryId: ${city['countryId']} | Matches: $matchesCountry');
      }

      if (matchesCountry && matchesSearch) {
        filteredCities.add(city);
      }
    }

    if (selectedCountry != null) {
      print('   ✅ Filtered cities count: ${filteredCities.length}');
      print('═══════════════════════════════════════════════');
    }

    filteredCities.sort((a, b) {
      final nameA = (a['cityName'] ?? '').toString().toLowerCase();
      final nameB = (b['cityName'] ?? '').toString().toLowerCase();
      return nameA.compareTo(nameB);
    });

    if (filteredCities.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: width * 0.15, color: Colors.grey),
              SizedBox(height: height * 0.02),
              Text(
                searchQuery.isNotEmpty
                    ? 'No cities found matching "$searchQuery"'
                    : selectedCountry != null
                    ? 'No cities available for ${selectedCountry!.countryName}'
                    : 'No cities available',
                style: GoogleFonts.dmSans(fontSize: width * 0.04, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (searchQuery.isNotEmpty || selectedCountry != null)
                Padding(
                  padding: EdgeInsets.only(top: height * 0.02),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        selectedCountry = null;
                        _searchController.clear();
                        if (_isSearchExpanded) {
                          _toggleSearch();
                        }
                      });
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: ColorConstants.primaryColor,
                      size: width * 0.05,
                    ),
                    label: Text(
                      'Clear all filters',
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.038,
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          if (searchQuery.isNotEmpty || selectedCountry != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.01,
              ),
              margin: EdgeInsets.only(bottom: height * 0.01),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.03,
                      vertical: width * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(width * 0.04),
                    ),
                    child: Text(
                      '${filteredCities.length} ${filteredCities.length == 1 ? 'city' : 'cities'} found',
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.032,
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        searchQuery = '';
                        selectedCountry = null;
                        _searchController.clear();
                        if (_isSearchExpanded) {
                          _toggleSearch();
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: width * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(width * 0.04),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear_all,
                            size: width * 0.04,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(width: width * 0.01),
                          Text(
                            'Clear filters',
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.032,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(
                right: width * 0.03,
                left: width * 0.03,
                bottom: height * 0.02,
              ),
              itemCount: filteredCities.length,
              separatorBuilder: (_, __) => Divider(
                color: Pallet.darkGreyColor.withOpacity(.1),
                thickness: 1,
                height: 15,
              ),
              itemBuilder: (context, index) {
                final zoneData = filteredCities[index];
                return _buildPlaceItem(zoneData, addedCityNames);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================== PLACE ITEM ==================
  Widget _buildPlaceItem(
      Map<String, dynamic> zoneData,
      Set<String> addedCityNames,
      ) {
    final String zoneName = (zoneData['cityName'] ?? '').toString().toLowerCase().trim();
    final String zoneImage = (zoneData['image'] ?? '').toString();
    final bool isAdded = addedCityNames.contains(zoneName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPlaceInfo(
          zoneName: zoneData['cityName']?.toString() ?? '',
          zoneImage: zoneImage,
        ),
        _buildActionButton(
          context: context,
          zoneData: zoneData,
          isAdded: isAdded,
        ),
      ],
    );
  }

  // ================== PLACE INFO ==================
  Widget _buildPlaceInfo({
    required String zoneName,
    required String zoneImage,
  }) {
    return Flexible(
      child: Row(
        children: [
          Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ClipOval(
              child: _buildZoneImage(zoneImage, zoneName),
            ),
          ),
          SizedBox(width: width * 0.03),
          Flexible(
            child: Text(
              zoneName,
              style: _itemNameStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ================== ZONE IMAGE WIDGET ==================
  Widget _buildZoneImage(String imageUrl, String zoneName) {
    if (imageUrl.isEmpty) {
      print('⚠️ No image URL for zone: $zoneName');
      return _buildDefaultCityImage();
    }

    print('🖼️ Loading image for $zoneName: $imageUrl');

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: width * 0.12,
      height: width * 0.12,
      placeholder: (context, url) => _buildLoadingImage(),
      errorWidget: (context, url, error) {
        print('❌ Failed to load image for $zoneName: $error');
        return _buildDefaultCityImage();
      },
    );
  }

  // ================== LOADING IMAGE PLACEHOLDER ==================
  Widget _buildLoadingImage() {
    return Container(
      width: width * 0.12,
      height: width * 0.12,
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: width * 0.04,
          height: width * 0.04,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  // ================== DEFAULT IMAGE ==================
  Widget _buildDefaultCityImage() {
    return Container(
      width: width * 0.12,
      height: width * 0.12,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.location_city,
        color: Colors.grey.shade500,
        size: width * 0.06,
      ),
    );
  }

  // ================== ACTION BUTTON ==================
  Widget _buildActionButton({
    required BuildContext context,
    required Map<String, dynamic> zoneData,
    required bool isAdded,
  }) {
    final String zoneName = (zoneData['cityName'] ?? '').toString();
    final String zoneId = (zoneData['cityId'] ?? '').toString();
    final String zoneImage = (zoneData['image'] ?? '').toString();
    final String countryId = (zoneData['countryId'] ?? '').toString();
    final String countryName = (zoneData['countryName'] ?? countryId).toString();

    return GestureDetector(
      onTap: isAdded
          ? null
          : () {
        showHireConfirmation(
          context,
          'Are you sure you want to scale to $zoneName?',
              () async {
            final businessId = widget.currentFirm?.reference?.id ?? '';

            if (businessId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Invalid business ID'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final city = CityModel(
              zone: zoneName,
              country: countryName,
              profile: zoneImage,
              marketerCount: 0,
              totalBusinessCount: 0,
              isZone: true,
            );

            print('═══════════════════════════════════════════════');
            print('📝 ADDING CITY WITH ZONEMANAGER DATA:');
            print('   Zone ID: $zoneId');
            print('   Zone Name: $zoneName');
            print('   Zone Image: $zoneImage');
            print('   Country: $countryName');
            print('   Business ID: $businessId');
            print('═══════════════════════════════════════════════');

            await ref.read(cityControllerProvider.notifier).addCity(
              leadId: businessId,
              city: city,
              context: context,
            );

            if (zoneId.isNotEmpty) {
              await ref
                  .read(zonalManagerControllerProvider.notifier)
                  .addBusinessToZone(
                cityId: zoneId,
                businessId: businessId,
                context: context,
              );
              print('✅ Business $businessId added to zone $zoneId');
            }
          },
        );
      },
      child: Container(
        width: width * 0.2,
        height: width * 0.085,
        decoration: BoxDecoration(
          color: isAdded ? Pallet.greenColor : ColorConstants.primaryColor,
          borderRadius: BorderRadius.circular(width * 0.01),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAdded)
              Icon(Icons.check_circle, color: Colors.white, size: width * 0.05)
            else
              SvgPicture.asset(
                AssetConstants.add,
                width: width * 0.05,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            SizedBox(width: width * 0.005),
            Text(
              isAdded ? "Added" : "Add",
              style: _buttonTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}