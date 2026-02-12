import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/industry-controler.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/models/leads_model.dart';

class SuggestedCandidats extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const SuggestedCandidats({super.key, required this.currentFirm});

  @override
  ConsumerState<SuggestedCandidats> createState() => _SuggestedCandidatsState();
}

class _SuggestedCandidatsState extends ConsumerState<SuggestedCandidats> {
  String? selectedFilter = 'All';
  String? selectedLocation;
  String? selectedIndustry;
  bool isSelectionMode = false;
  bool isUploading = false;
  bool isHiring = false;


  final Set<String> selectedIds = {};
  final List<AffiliateModel> selectedAffiliates = [];

  String _affId(AffiliateModel a) =>
      a.id ?? '${a.name}_${a.zone ?? ''}_${a.profile ?? ''}';

  @override
  Widget build(BuildContext context) {
    double w = width;
    double h = height;

    // 👇 Watch providers directly in HirePage
    final affiliateAsync = ref.watch(affiliateStreamProvider(''));
    // 👇 Debug: Print the affiliate state
    debugPrint('Affiliate State: $affiliateAsync');
    debugPrint('Affiliate isLoading: ${affiliateAsync.isLoading}');
    debugPrint('Affiliate hasValue: ${affiliateAsync.hasValue}');
    debugPrint('Affiliate hasError: ${affiliateAsync.hasError}');

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Pallet.backgroundColor,
          appBar: SuggestAppBar(
            title: 'Suggested Candidates',
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
                    SvgPicture.asset(
                      AssetConstants.close,
                      width: w * 0.07,
                    ),
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
                /// 🔹 GRID
                Expanded(
                  child: affiliateAsync.when(
                    data: (affiliates) {
                      List<AffiliateModel> filtered = affiliates;

                      // Filter by location
                      if (selectedLocation != null) {
                        filtered = filtered.where((a) {
                          final zone = a.zone ?? '';
                          return zone.toLowerCase() ==
                              selectedLocation!.toLowerCase();
                        }).toList();
                      }

                      // Filter by industry
                      if (selectedIndustry != null) {
                        filtered = filtered.where((a) {
                          final industry =
                          (a.industry ?? '').toString().toLowerCase();
                          return industry.contains(
                            selectedIndustry!.toLowerCase(),
                          );
                        }).toList();
                      }

                      /// 🔹 NO DATA FOUND
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

                      /// 🔹 GRID
                      return GridView.builder(
                        padding: EdgeInsets.all(w * 0.03),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.98,
                          crossAxisSpacing: w * 0.03,
                          mainAxisSpacing: w * 0.03,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final affiliate = filtered[i];
                          final id = _affId(affiliate);
                          final checked = selectedIds.contains(id);

                          return GestureDetector(
                            onTap: () {
                              if (isSelectionMode) {
                                setState(() {
                                  if (checked) {
                                    selectedIds.remove(id);
                                    selectedAffiliates.removeWhere(
                                          (e) => _affId(e) == id,
                                    );
                                  } else {
                                    selectedIds.add(id);
                                    selectedAffiliates.add(affiliate);
                                  }
                                });
                              }
                            },
                            child: _affiliateCard(affiliate, checked),
                          );
                        },
                      );
                    },
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (e, stack) {
                      debugPrint('Error loading affiliates: $e');
                      debugPrint('Stack trace: $stack');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading data',
                              style: GoogleFonts.dmSans(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: w * 0.02),
                            Text(
                              e.toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: w * 0.035,
                                color: Colors.red,
                              ),
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
        ),

        /// 🔹 HIRE BUTTON
        /// 🔹 HIRE BUTTON - WITH CIRCLE AVATAR STYLE LOADING
        Positioned(
          bottom: h * 0.02,
          left: w * 0.07,
          right: w * 0.07,
          child: ElevatedButton(
            onPressed: isSelectionMode && selectedIds.isNotEmpty && !isHiring
                ? _confirmAndHire
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isSelectionMode && selectedIds.isNotEmpty && !isHiring
                  ? Pallet.secondaryColor
                  : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(w * 0.03),
              ),
              padding: EdgeInsets.symmetric(
                vertical: w * 0.04,
              ),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 👇 CircleAvatar style loading
                if (isHiring)
                  Container(
                    width: w * 0.06,
                    height: w * 0.06,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: w * 0.04,
                        height: w * 0.04,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
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
                  isHiring ? 'Hiring...' : 'Hire',
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

        /// 🔹 UPLOADING OVERLAY
        if (isUploading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 🔹 CARD UI
  Widget _affiliateCard(AffiliateModel a, bool checked) {
    final profile = a.profile ?? '';
    final name = a.name ?? 'Unknown';
    final zone = a.zone ?? 'N/A';
    final leadScore = a.leadScore ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Pallet.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: Pallet.borderColor),
      ),
      padding: EdgeInsets.only(
        top: height * 0.02,
      ),
      child: Column(
        children: [
          if (isSelectionMode)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: width * .03),
                child: Container(
                  height: width * 0.06,
                  width: width * 0.06,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checked ? Colors.black : Colors.transparent,
                    border: Border.all(
                      color: checked ? Colors.black : Pallet.borderColor,
                      width: 2,
                    ),
                  ),
                  child: checked
                      ? Icon(
                    Icons.check,
                    size: width * 0.03,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),
            ),
          CircleAvatar(
            radius: width * 0.06,
            backgroundImage: profile.isNotEmpty
                ? NetworkImage(profile)
                : const AssetImage('assets/image.png') as ImageProvider,
            onBackgroundImageError: profile.isNotEmpty
                ? (exception, stackTrace) {
              debugPrint('Error loading image: $exception');
            }
                : null,
          ),
          SizedBox(height: width * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.04,
              ),
            ),
          ),
          SizedBox(height: width * 0.01),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/location.svg',
                width: width * 0.035,
              ),
              SizedBox(width: width * 0.01),
              Text(
                zone,
                style: GoogleFonts.dmSans(
                  color: Pallet.greyColor,
                  fontSize: width * 0.03,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.02),
          Container(
            padding: EdgeInsets.all(width * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.05),
              color: Pallet.backgroundColor,
            ),
            child: Text(
              'LQ : ${leadScore.round()}%',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 CHIP BUTTON (FIXED SIZE - FOR "ALL" BUTTON)
  Widget _chipButton({
    required String title,
    required bool isSelected,
    bool showArrow = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: width * 0.08,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.05),
          color: isSelected ? Pallet.lightBlue : Colors.transparent,
          border: Border.all(
            color: isSelected ? Pallet.primaryColor : Pallet.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6E7C87),
              ),
            ),
            if (showArrow) ...[
              SizedBox(width: width * 0.01),
              Icon(
                Icons.keyboard_arrow_down,
                size: width * 0.05,
                color: const Color(0xFF49454F),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🔹 CHIP BUTTON COMPACT (REDUCED WIDTH - FOR LOCATION & INDUSTRY)
  Widget _chipButtonExpanded({
    required String title,
    required bool isSelected,
    bool showArrow = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: width * 0.08,
        constraints: BoxConstraints(
          maxWidth: width * 0.28,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.025,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.05),
          color: isSelected ? Pallet.lightBlue : Colors.transparent,
          border: Border.all(
            color: isSelected ? Pallet.primaryColor : Pallet.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.03,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6E7C87),
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.keyboard_arrow_down,
                size: width * 0.04,
                color: const Color(0xFF49454F),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔹 HIRE ACTION
  Future<void> _confirmAndHire() async {
    final leadId = widget.currentFirm?.reference?.id;

    if (leadId == null || leadId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid firm/lead ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedAffiliates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No marketers selected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Use the hire function
    await ref.read(leadControllerProvider.notifier).hireAffiliates(
      context: context,
      leadId: leadId,
      affiliates: selectedAffiliates,
    );

    // Reset selection after successful hire
    if (mounted) {
      setState(() {
        isSelectionMode = false;
        selectedIds.clear();
        selectedAffiliates.clear();
      });
    }
  }

  /// 🔹 LOCATION BOTTOM SHEET
  void showLocationBottomSheet({
    required BuildContext context,
    required List<String> items,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width * 0.06),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: width * 0.04,
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
                    onTap: () => Navigator.pop(context),
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
              ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: width * 0.02),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
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
                          Text(
                            item,
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: width * 0.02),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 INDUSTRY BOTTOM SHEET (WITH DATABASE)
  void showIndustryBottomSheet({
    required BuildContext context,
    required ValueChanged<String> onSelect,
  }) {
    final w = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(w * 0.06),
        ),
      ),
      builder: (_) {
        return Consumer(
          builder: (context, ref, child) {
            final industryAsyncValue = ref.watch(industryStreamProvider(''));

            return Padding(
              padding: EdgeInsets.only(
                left: w * 0.05,
                right: w * 0.05,
                top: w * 0.04,
                bottom: MediaQuery.of(context).viewInsets.bottom + w * 0.04,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: w * 0.12,
                    height: w * 0.012,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(height: w * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Industry',
                        style: GoogleFonts.dmSans(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(w * 0.015),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: w * 0.045,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: w * 0.04),
                  Flexible(
                    child: industryAsyncValue.when(
                      data: (industries) {
                        if (industries.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(w * 0.1),
                              child: Text(
                                'No industries found',
                                style: GoogleFonts.dmSans(
                                  fontSize: w * 0.038,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: industries.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (_, __) =>
                              SizedBox(height: w * 0.02),
                          itemBuilder: (_, index) {
                            final industry = industries[index];
                            final industryName = industry.name ?? '';
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(context);
                                onSelect(industryName);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.04,
                                  vertical: w * 0.035,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  industryName,
                                  style: GoogleFonts.dmSans(
                                    fontSize: w * 0.035,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => Padding(
                        padding: EdgeInsets.all(w * 0.1),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) {
                        debugPrint('Industry error: $error');
                        return Padding(
                          padding: EdgeInsets.all(w * 0.1),
                          child: Center(
                            child: Text(
                              'Error: $error',
                              style: GoogleFonts.dmSans(
                                fontSize: w * 0.035,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: w * 0.02),
                ],
              ),
            );
          },
        );
      },
    );
  }
}