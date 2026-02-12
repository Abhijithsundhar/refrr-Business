import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/chat-screen-support-%20functions.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/city-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/zone-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/scale/country-bottom-sheet.dart';
import 'package:refrr_admin/models/city-model.dart';
import 'package:refrr_admin/models/country-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';

class Scale extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  final List<ServiceLeadModel>? serviceLeads;
  const Scale({super.key, this.currentFirm, this.serviceLeads});

  @override
  ConsumerState<Scale> createState() => _ScaleState();
}

class _ScaleState extends ConsumerState<Scale> {
  CountryModel? selectedCountry;
  String searchQuery = '';

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
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(
        citiesStreamProvider(widget.currentFirm?.reference?.id ?? ''));
    final zonalCitiesAsync = ref.watch(uniqueCitiesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Scale',
        showBackButton: true,
        // actionWidget: Padding(
        //   padding: EdgeInsets.only(right: width * 0.03),
        //   child: GestureDetector(
        //     onTap: () {
        //       _showSearchDialog();
        //     },
        //     child: CircleSvgButton(
        //       size: width * 0.08,
        //       child: SvgPicture.asset('assets/svg/search.svg'),
        //     ),
        //   ),
        // ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          // Padding(
          //   padding: EdgeInsets.only(
          //     left: width * 0.03,
          //     right: width * 0.03,
          //     top: height * 0.02,
          //   ),
          //   child: _buildCountrySelector(),
          // ),
          SizedBox(height: width * 0.05),
          citiesAsync.when(
            data: (addedCities) {
              return zonalCitiesAsync.when(
                data: (zonalCities) {
                  print('🎯 SCALE SCREEN: Received ${zonalCities.length} zonal cities');

                  // Debug: Print all zone data with images
                  for (var zone in zonalCities) {
                    print('   📍 ${zone['cityName']} | Image: ${zone['image']}');
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

  // ================== SEARCH DIALOG ==================
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search City',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter city name...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width * 0.02),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ================== COUNTRY SELECTOR ==================
  // Widget _buildCountrySelector() {
  //   return GestureDetector(
  //     onTap: () {
  //       showCountryBottomSheet(
  //         context,
  //         selectedCountry: selectedCountry,
  //         onSelect: (country) {
  //           setState(() {
  //             selectedCountry = country;
  //             marketerCountryController.text = country.countryName;
  //           });
  //         },
  //       );
  //     },
  //     child: Container(
  //       height: width * 0.13,
  //       padding: EdgeInsets.symmetric(horizontal: width * 0.04),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         border: Border.all(color: Pallet.borderColor),
  //         borderRadius: BorderRadius.circular(width * 0.02),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: Row(
  //               children: [
  //                 if (selectedCountry != null) ...[
  //                   _buildSelectedCountryFlag(),
  //                   SizedBox(width: width * 0.03),
  //                 ],
  //                 Expanded(
  //                   child: Text(
  //                     selectedCountry?.countryName ?? "Select Country",
  //                     style: GoogleFonts.dmSans(
  //                       fontSize: width * 0.038,
  //                       fontWeight: FontWeight.w500,
  //                       color: selectedCountry != null
  //                           ? Colors.black87
  //                           : Pallet.greyColor,
  //                     ),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Icon(
  //             Icons.keyboard_arrow_down_rounded,
  //             color: Colors.black54,
  //             size: width * 0.06,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
    // Create a set of added city names for quick lookup
    final Set<String> addedCityNames =
    addedCities.map((city) => city.zone.toLowerCase().trim()).toSet();

    // Filter cities
    List<Map<String, dynamic>> filteredCities = [];

    for (var city in zonalCities) {
      final cityName = (city['cityName'] ?? '').toString().toLowerCase().trim();
      final cityCountryId = (city['countryId'] ?? '').toString().trim();

      bool matchesCountry = selectedCountry == null ||
          cityCountryId.toUpperCase() == selectedCountry!.shortName.toUpperCase();

      bool matchesSearch = searchQuery.isEmpty ||
          cityName.contains(searchQuery.trim());

      if (matchesCountry && matchesSearch) {
        filteredCities.add(city);
      }
    }

    // Sort alphabetically
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
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          if (searchQuery.isNotEmpty || selectedCountry != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.01,
              ),
              child: Row(
                children: [
                  Text(
                    '${filteredCities.length} ${filteredCities.length == 1 ? 'city' : 'cities'} found',
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.035,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        searchQuery = '';
                        selectedCountry = null;
                      });
                    },
                    child: Text(
                      'Clear filters',
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.035,
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.w600,
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

  // ================== PLACE INFO - Shows Zone Image & Name ==================
  Widget _buildPlaceInfo({
    required String zoneName,
    required String zoneImage,
  }) {
    return Flexible(
      child: Row(
        children: [
          // Zone Image from ZoneManagers Collection
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
          // Zone Name ONLY
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
    final String zoneImage = (zoneData['image'] ?? '').toString(); // ✅ Image from zonemanagers
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

            // ✅ Create CityModel with Zone Image from ZoneManagers Collection
            final city = CityModel(
              zone: zoneName,
              country: countryName,
              profile: zoneImage,  // ✅ Using image from zonemanagers collection
              marketerCount: 0,
              totalBusinessCount: 0,
              isZone: true,
            );

            print('═══════════════════════════════════════════════');
            print('📝 ADDING CITY WITH ZONEMANAGER DATA:');
            print('   Zone ID: $zoneId');
            print('   Zone Name: $zoneName');
            print('   Zone Image: $zoneImage');  // ✅ This image is from zonemanagers
            print('   Country: $countryName');
            print('   Business ID: $businessId');
            print('═══════════════════════════════════════════════');

            // Step 1: Add city to business with zonemanager image
            await ref.read(cityControllerProvider.notifier).addCity(
              leadId: businessId,
              city: city,
              context: context,
            );

            // Step 2: Add business ID to zone collection
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