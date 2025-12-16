import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';


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
  String selectedLocation = 'Location';
  String selectedIndustry = 'Industry';

  bool isSelectionMode = false;
  bool isUploading = false;

  final Set<String> selectedIds = {};
  final List<AffiliateModel> selectedAffiliates = [];

  String _affId(AffiliateModel a) =>
      a.id ?? '${a.name}_${a.zone}_${a.profile}';

  @override
  Widget build(BuildContext context) {
    double w = width;double h = height;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Pallet.backgroundColor,
          appBar: CustomAppBar(title: 'Hire Marketers',
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
                    border:
                    Border.all(color: Pallet.borderColor),
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
          ),),
          body: SafeArea(
            child: Column(
              children: [
                /// 🔹 FILTERS
                Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Row(
                    children: [
                      _chipButton('All',
                          isSelected: selectedFilter == 'All',
                          onTap: () {
                            setState(() {
                              selectedFilter = 'All';
                            });
                          }),
                      SizedBox(width: w * 0.02),
                      _chipDropdown(
                        selectedLocation,
                        ['Kochi', 'Calicut', 'Dubai'],
                            (v) {
                          setState(() {
                            selectedLocation = v!;
                            selectedFilter = 'Location';
                          });
                        },
                      ),
                      SizedBox(width: w * 0.02),
                      _chipDropdown(
                        selectedIndustry,
                        ['IT', 'Marketing', 'Real Estate'],
                            (v) {
                          setState(() {
                            selectedIndustry = v!;
                            selectedFilter = 'Industry';
                          });
                        },
                      ),
                    ],
                  ),
                ),

                /// 🔹 GRID
                Expanded(
                  child: widget.affiliate!.when(
                    data: (affiliates) {
                      return GridView.builder(
                        padding: EdgeInsets.all(w * 0.03),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.98,
                          crossAxisSpacing: w * 0.03,
                          mainAxisSpacing: w * 0.03,
                        ),
                        itemCount: affiliates.length,
                        itemBuilder: (_, i) {
                          final affiliate = affiliates[i];
                          final id = _affId(affiliate);
                          final checked = selectedIds.contains(id);

                          return InkWell(
                            onTap: () {
                              if (isSelectionMode) {
                                setState(() {
                                  if (checked) {
                                    selectedIds.remove(id);
                                    selectedAffiliates.removeWhere(
                                            (e) => _affId(e) == id);
                                  } else {
                                    selectedIds.add(id);
                                    selectedAffiliates.add(affiliate);
                                  }
                                });
                              }
                            },
                            child: _affiliateCard(
                              affiliate,
                              checked,
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(e.toString())),
                  ),
                ),
              ],
            ),
          ),
        ),
        /// 🔹 HIRE BUTTON
        Positioned(
          top: h*.92,
          left: width*.07,
          child: Center(
            child: ElevatedButton(
              onPressed: isSelectionMode && selectedIds.isNotEmpty
                  ? _confirmAndHire
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelectionMode
                    ? Pallet.secondaryColor
                    : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.03),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: h * 0.18,
                  vertical: w * 0.02,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetConstants.hire,
                    width: w * 0.06,
                  ),
                  SizedBox(width: w * 0.01),
                  Text(
                    'Hire',
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
        ),

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

  /// 🔹 CARD UI
  Widget _affiliateCard(AffiliateModel a, bool checked) {
    return Container(
      decoration: BoxDecoration(
        color: Pallet.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(color: Pallet.borderColor),
      ),
      padding: EdgeInsets.only(top: height * 0.01,),
      child: Column(
        children: [
          if (isSelectionMode)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding:  EdgeInsets.only(right: width*.03),
                child: Container(
                  height: width * 0.06,
                  width: width * 0.06,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checked
                        ? Colors.black
                        : Colors.transparent,
                    border: Border.all(
                      color: checked
                          ? Colors.black
                          : Pallet.borderColor,
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
            backgroundImage: a.profile.isNotEmpty
                ? NetworkImage(a.profile)
                : const AssetImage('assets/image.png')
            as ImageProvider,
          ),
          SizedBox(height: width * 0.01),
          Text(
            a.name,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.045,
            ),
          ),
          SizedBox(height: width * 0.01),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/location.svg'),
              SizedBox(width: width * 0.01),
              Text(
                a.zone,
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
              'LQ : ${a.leadScore?.round() ?? 0}%',
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

  /// 🔹 CHIP BUTTON
  Widget _chipButton(
      String title, {
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: width * 0.07,
        width: width * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.05),
          color: isSelected
              ? Pallet.lightBlue
              : Pallet.lightGreyColor,
          border: Border.all(
            color: isSelected
                ? Pallet.primaryColor
                : Pallet.borderColor,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }


  /// 🔹 CHIP DROPDOWN
  Widget _chipDropdown(
      String value,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return Container(
      height: height * 0.045, // ✅ SAME HEIGHT
      width: width * 0.3,
      padding: EdgeInsets.symmetric(horizontal: width * 0.025),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(color: Pallet.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: SvgPicture.asset(
            AssetConstants.dropdown, // ✅ DOWN ARROW
            width: width * 0.035,
            color: Pallet.greyColor,
          ),
          items: {value, ...items}.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.03,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }


  /// 🔹 HIRE ACTION
  Future<void> _confirmAndHire() async {
    setState(() => isUploading = true);
    // your existing hire logic here
    setState(() => isUploading = false);
  }
}
