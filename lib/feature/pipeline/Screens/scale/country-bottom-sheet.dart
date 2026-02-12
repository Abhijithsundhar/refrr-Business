// lib/feature/pipeline/Screens/scale/country-bottom-sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/country-controllor.dart';
import 'package:refrr_admin/core/constants/color-constnats.dart';
import 'package:refrr_admin/models/country-model.dart';

// Fallback emoji flags based on shortName (2-letter ISO code)
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

void showCountryBottomSheet(
    BuildContext context, {
      CountryModel? selectedCountry,
      required Function(CountryModel) onSelect,
    }) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return _CountryBottomSheetContent(
        selectedCountry: selectedCountry,
        onSelect: onSelect,
      );
    },
  );
}

class _CountryBottomSheetContent extends ConsumerWidget {
  final CountryModel? selectedCountry;
  final Function(CountryModel) onSelect;

  const _CountryBottomSheetContent({
    this.selectedCountry,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesFutureProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Country",
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xffF3F3F3),
                  child: Icon(Icons.close, size: 18, color: Colors.black54),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Country List with AsyncValue handling
          Flexible(
            child: countriesAsync.when(
              data: (countries) {
                if (countries.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildCountryList(context, countries);
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) {
                debugPrint('❌ Country fetch error: $error');
                debugPrint('Stack trace: $stack');
                return _buildErrorState(error.toString(), context, ref);
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildCountryList(BuildContext context, List<CountryModel> countries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        final bool isSelected =
            selectedCountry?.shortName == country.shortName;

        debugPrint(
            '🌍 Country: ${country.countryName}, ShortName: ${country.shortName}, Flag: ${country.flag}');

        return InkWell(
          onTap: () {
            Navigator.pop(context);
            onSelect(country);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorConstants.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Country Flag - Image or Emoji
                _buildCountryFlag(country),
                const SizedBox(width: 12),

                // Country Name
                Expanded(
                  child: Text(
                    country.countryName,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? ColorConstants.primaryColor
                          : Colors.black87,
                    ),
                  ),
                ),

                // Check Icon if Selected
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: ColorConstants.primaryColor,
                    size: 22,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountryFlag(CountryModel country) {
    // If flag URL exists, show image with curved style
    if (country.flag.isNotEmpty) {
      return Container(
        width: 48,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            country.flag,
            width: 48,
            height: 32,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ Flag image error for ${country.countryName}: $error');
              // Fallback to emoji if image fails
              return Container(
                width: 48,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  getEmojiFlag(country.shortName),
                  style: const TextStyle(fontSize: 24),
                ),
              );
            },
          ),
        ),
      );
    }

    // If no flag URL, show emoji based on shortName with curved container
    return Container(
      width: 48,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Text(
        getEmojiFlag(country.shortName),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: ColorConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading countries...",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.public_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No countries available",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please add countries in settings",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "Error loading countries",
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: Colors.red.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              error,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(countriesFutureProvider);
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}