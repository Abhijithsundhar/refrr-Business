import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/pipeline/controller/industry_controller.dart';
import 'package:refrr_admin/models/affiliate_model.dart';
import 'package:shimmer/shimmer.dart';

/// 🔹 TEAM CARD
Widget teamCard(AffiliateModel model) {
  return Container(
    decoration: BoxDecoration(
      color: Pallet.lightGreyColor,
      borderRadius: BorderRadius.circular(width * 0.03),
      border: Border.all(color: Pallet.borderColor),
    ),
    padding: EdgeInsets.all(width * 0.02),
    child: Column(
      children: [
        SizedBox(height: height * .01),
        CircleAvatar(
          radius: width * 0.08,
          backgroundColor: Pallet.greyColor.withOpacity(0.3),
          backgroundImage: model.profile.isNotEmpty
              ? CachedNetworkImageProvider(model.profile)
              : null,
          child: model.profile.isEmpty
              ? Icon(
            Icons.person,
            size: width * 0.08,
            color: Pallet.greyColor,
          )
              : null,
        ),
        SizedBox(height: width * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                model.name,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: width * 0.04,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: width * 0.01),
          ],
        ),
        SizedBox(height: width * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svg/location.svg', width: width * 0.04),
            SizedBox(width: width * 0.01),
            Flexible(
              child: Text(
                model.zone,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.03,
                  color: Pallet.greyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: width * 0.015),
        Text(
          'Total Leads : ${model.totalLeads}',
          style: GoogleFonts.dmSans(fontSize: width * 0.03),
        ),
        SizedBox(height: width * 0.015),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: width * 0.01,
          ),
          decoration: BoxDecoration(
            color: Pallet.backgroundColor,
            borderRadius: BorderRadius.circular(width * 0.05),
          ),
          child: Text(
            'LQ : ${(model.leadScore ?? 0).toInt()}%',
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
Widget chipButton({
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
Widget chipButtonExpanded({
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

/// 🔹 INDUSTRY BOTTOM SHEET
void showIndustryBottomSheet({
  required BuildContext context,
  required ValueChanged<String> onSelect,
}) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;
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
          final searchText = ref.watch(industrySearchProvider);
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
                      onTap: () {
                        ref.read(industrySearchProvider.notifier).state = '';
                        Navigator.pop(context);
                      },
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
                Container(
                  width: w * 0.9,
                  height: h * 0.055,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCED4DA)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      ref.read(industrySearchProvider.notifier).state = value;
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
                        vertical: h * 0.017,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: w * 0.04),
                Flexible(
                  child: industryAsyncValue.when(
                    data: (industries) {
                      final filteredIndustries = searchText.isEmpty
                          ? industries
                          : industries.where((industry) {
                        final name = industry.name.toLowerCase();
                        final query = searchText.toLowerCase();
                        return name.contains(query);
                      }).toList();

                      if (filteredIndustries.isEmpty) {
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
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredIndustries.length,
                        separatorBuilder: (_, __) => SizedBox(height: w * 0.02),
                        itemBuilder: (_, index) {
                          final industry = filteredIndustries[index];
                          final industryName = industry.name ?? '';
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ref.read(industrySearchProvider.notifier).state = '';
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
                      child: const CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Padding(
                      padding: EdgeInsets.all(w * 0.1),
                      child: Text(
                        'Error: $error',
                        style: GoogleFonts.dmSans(
                          fontSize: w * 0.035,
                          color: Colors.red,
                        ),
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

/// 🔹 CARD UI
Widget affiliateCard(AffiliateModel a, bool checked) {
  final profile = a.profile;
  final name = a.name;
  final zone = a.zone;
  final industry = a.industry;
  final leadScore = a.leadScore ?? 0;

  return Container(
    decoration: BoxDecoration(
      color: Pallet.lightGreyColor,
      borderRadius: BorderRadius.circular(width * 0.03),
      border: Border.all(color: Pallet.borderColor),
    ),
    padding: EdgeInsets.symmetric(
      vertical: height * 0.009,
      horizontal: width * 0.02,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            SizedBox(
              height: width * 0.06,
              child: isSelectionMode
                  ? Align(
                alignment: Alignment.topRight,
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
              )
                  : const SizedBox(),
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
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.04,
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
                Flexible(
                  child: Text(
                    zone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: Pallet.greyColor,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(
              height: width * 0.09,
              child: Center(
                child: Text(
                  industry.isNotEmpty ? industry.first : '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: Pallet.greyColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ),
            ),
            SizedBox(height: width * 0.015),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: width * 0.015,
              ),
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
      ],
    ),
  );
}

Widget buildShimmerGrid(double w) {
  return GridView.builder(
    padding: EdgeInsets.all(w * 0.03),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.85,
      crossAxisSpacing: w * 0.03,
      mainAxisSpacing: w * 0.03,
    ),
    itemCount: 6,
    itemBuilder: (_, i) => Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(w * 0.02),
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget buildError(Object e, StackTrace stack, double w) {
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
}
