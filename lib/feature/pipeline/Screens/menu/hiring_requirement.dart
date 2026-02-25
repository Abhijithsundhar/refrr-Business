import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/alert_dailogs/hire_confirmation_alert.dart';
import 'package:refrr_admin/core/common/custom_appBar.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/loader.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/login/Controller/lead_controller.dart';
import 'package:refrr_admin/feature/pipeline/Controller/city_controller.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/city_model.dart';

class HiringRequirement extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const HiringRequirement({super.key, required this.currentFirm});

  @override
  ConsumerState<HiringRequirement> createState() => _HiringRequirementState();
}

class _HiringRequirementState extends ConsumerState<HiringRequirement> {
  // ── State ────────────────────────────────────────────────────────────────
  final Set<dynamic> _selectedLocations = {};
  final Set<dynamic> _selectedJobTypes = {};

  // ✅ Add this for view more/less functionality
  bool _isLocationExpanded = false;
  static const int _maxVisibleLocations = 4;

  // ✅ Add maximum job type selection limit
  static const int _maxJobTypeSelection = 3;

  final List<String> _jobTypes = [
    'Full Time',
    'Part Time',
    'Freelance',
    'Field-Staff',
    'Distributor',
    'Commission Based'
  ];

  @override
  void initState() {
    super.initState();
    _initializeSelectedLocations();
    _initializeSelectedJobType();
  }

  void _initializeSelectedLocations() {
    if (widget.currentFirm?.lookingAt != null) {
      _selectedLocations.addAll(widget.currentFirm!.lookingAt);
    }
  }

  void _initializeSelectedJobType() {
    if (widget.currentFirm?.jobType != null) {
      _selectedJobTypes.addAll(widget.currentFirm!.jobType);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _tealCheck(bool selected) => selected
      ? const Icon(Icons.check_circle, color: Pallet.primaryColor, size: 22)
      : Icon(Icons.circle_outlined,
      color: Pallet.primaryColor.withOpacity(0.6), size: 22);

  // ✅ Show snackbar when max limit reached
  void _showMaxLimitSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can select maximum $_maxJobTypeSelection job types',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ── Sections ─────────────────────────────────────────────────────────────
  Widget _sectionHeader(String text, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700, fontSize: width * .045),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w400,
              fontSize: width * .03,
              color: Pallet.greyColor,
            ),
          ),
      ],
    ),
  );

  Widget _locationTile(CityModel city) {
    final name = city.zone ?? '';
    final selected = _selectedLocations.contains(name);
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => selected
              ? _selectedLocations.remove(name)
              : _selectedLocations.add(name)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: city.profile,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CommonLoader(),
                      ),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: width * .04,
                        ),
                      ),
                    ],
                  ),
                ),
                _tealCheck(selected),
              ],
            ),
          ),
        ),
        const Divider(height: 2, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  // ✅ Updated Job Type Tile with max selection logic
  Widget _jobTypeTile(String type) {
    final selected = _selectedJobTypes.contains(type);
    final isMaxReached = _selectedJobTypes.length >= _maxJobTypeSelection;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            // Always allow deselection
            _selectedJobTypes.remove(type);
          } else {
            // Check if max limit reached before adding
            if (_selectedJobTypes.length < _maxJobTypeSelection) {
              _selectedJobTypes.add(type);
            } else {
              // Show snackbar when trying to select more than max
              _showMaxLimitSnackbar();
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          // ✅ Optional: Add border or opacity for disabled state
          border: Border.all(
            color: Pallet.greyColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                type,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  // ✅ Optional: Dim text when max reached and not selected
                  color:  Colors.black,
                ),
              ),
            ),
            // ✅ Show different icon state when max reached
            selected
                ? const Icon(Icons.check_circle, color: Pallet.primaryColor, size: 22)
                : Icon(
              Icons.circle_outlined,
              color: (isMaxReached && !selected)
                  ? Pallet.primaryColor
                  : Pallet.primaryColor.withOpacity(0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Updated View More/Less Button
  Widget _viewMoreLessButton({
    required int totalCount,
    required bool isExpanded,
    required VoidCallback onPressed,
  }) {
    if (totalCount <= _maxVisibleLocations) {
      return const SizedBox.shrink();
    }

    final remainingCount = totalCount - _maxVisibleLocations;

    return Padding(
      padding: EdgeInsets.only(left: width * .6),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExpanded ? 'View Less' : 'View More ($remainingCount)',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: Pallet.greyColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Pallet.greyColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Build Location List with View More/Less
  Widget _buildLocationList(List<CityModel> cities) {
    if (cities.isEmpty) {
      return _buildEmptyLocations();
    }

    final List<CityModel> visibleCities = _isLocationExpanded
        ? cities
        : cities.take(_maxVisibleLocations).toList();

    return Column(
      children: [
        ...visibleCities.map((city) => _locationTile(city)),
        AppSpacing.h002,
        _viewMoreLessButton(
          totalCount: cities.length,
          isExpanded: _isLocationExpanded,
          onPressed: () {
            setState(() {
              _isLocationExpanded = !_isLocationExpanded;
            });
          },
        ),
      ],
    );
  }

  // ── Loading Widget ───────────────────────────────────────────────────────
  Widget _buildLoadingLocations() {
    return Column(
      children: List.generate(
        4,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error Widget ─────────────────────────────────────────────────────────
  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load locations: $error',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.invalidate(citiesStreamProvider(
                  widget.currentFirm?.reference?.id ?? ''));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Empty Widget ─────────────────────────────────────────────────────────
  Widget _buildEmptyLocations() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No locations available',
            style: GoogleFonts.dmSans(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final leadId = widget.currentFirm?.reference?.id ?? '';
    final citiesAsync = ref.watch(citiesStreamProvider(leadId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Hiring Requirements'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Looking at ──────────────────────────────────────────
                  _sectionHeader('Looking at'),

                  citiesAsync.when(
                    data: (cities) => _buildLocationList(cities),
                    loading: () => _buildLoadingLocations(),
                    error: (error, stack) =>
                        _buildErrorWidget(error.toString()),
                  ),
                  AppSpacing.h01,

                  // ── Job Type ────────────────────────────────────────────
                  // ✅ Updated: Added subtitle showing selection count
                  _sectionHeader(
                    'Job Type',
                    // subtitle: 'Select up to $_maxJobTypeSelection types (${_selectedJobTypes.length}/$_maxJobTypeSelection selected)',
                  ),
                  ..._jobTypes.map(_jobTypeTile),
                ],
              ),
            ),
          ),

          // ── Update Button ───────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: InkWell(
                  onTap: _onUpdatePressed,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text('Update',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onUpdatePressed() {
    showHireConfirmation(
      context,
      'Do you want to update your requirements?',
          () {
        final updateLead = widget.currentFirm?.copyWith(
          lookingAt: _selectedLocations.toList(),
          jobType: _selectedJobTypes.toList(),
        );
        ref
            .watch(leadControllerProvider.notifier)
            .updateLead(leadModel: updateLead!, context: context);
        debugPrint('Selected Locations: $_selectedLocations');
        debugPrint('Selected Job Types: $_selectedJobTypes');
      },
    );
  }
}