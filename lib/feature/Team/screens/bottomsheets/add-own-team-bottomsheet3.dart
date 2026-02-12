import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/search-query.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/industry-controler.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

final List<String> jobTypeList = [
  "Full Time",
  "Part Time",
  "Contract",
  "Freelance"
];

const double fieldHeight = 55.0;

Widget registration3BottomSheet(
    BuildContext context,
    LeadsModel? currentFirm,
    ) {
  bool isCreatingAccount = false; // ✅ MUST be outside StatefulBuilder

  return Consumer(
    builder: (context, ref, child) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final widgetRef = ref;

          // ================= VALIDATION =================
          bool validateFields() {
            if (marketerIAmAnController.text.trim().isEmpty) {
              showCommonSnackbar(context, "Please enter your role");
              return false;
            }
            if (selectedIndustries.isEmpty) {
              showCommonSnackbar(
                  context, "Please select at least one preferred industry");
              return false;
            }
            if (selectedCurrentJobType == null ||
                selectedCurrentJobType!.isEmpty) {
              showCommonSnackbar(
                  context, "Please select current job type preference");
              return false;
            }
            if (selectedPreviousIndustry == null ||
                selectedPreviousIndustry!.isEmpty) {
              showCommonSnackbar(
                  context, "Please select previous industry");
              return false;
            }
            return true;
          }

          // ================= CREATE ACCOUNT =================
          Future<void> createAccount() async {
            if (!validateFields()) return;

            setState(() => isCreatingAccount = true);

            try {
              final affiliate = AffiliateModel(
                name: marketerNameController.text.trim(),
                profile: uploadedImageUrl ?? '',
                phone: marketerPhoneNOController.text.trim(),
                zone: marketerCountryController.text.trim(),
                country: marketerCountryController.text.trim(),
                userId: marketerUserIdController.text.trim(),
                password: marketerPasswordController.text.trim(),
                mailId: marketerEmailController.text.trim(),
                level: '',
                status: 0,
                delete: false,
                createTime: DateTime.now(),
                search:
                setSearchParam(marketerNameController.text.trim()),
                addedBy: currentFirm?.reference?.id ?? '',
                withdrawalRequest: [],
                balance: [],
                totalCredits: [],
                totalWithdrawals: [],
                totalBalance: 0,
                totalCredit: 0,
                totalWithrew: 0,
                language: marketerLanguageController.text.trim(),
                qualification:
                marketerQualificationController.text.trim(),
                experience:
                marketerExpireanceController.text.trim(),
                moreInfo: '',
                industry: selectedIndustries,
                jobType: selectedCurrentJobType != null ? [selectedCurrentJobType!] : [],
                role: marketerIAmAnController.text.trim(),
                leadScore: 0.0,
                workingFirms: currentFirm != null ? [currentFirm.reference!.id] : [],
                qualifiedLeads: 0,
                totalLeads: 0,
                generatedLeads: [],
                gender: marketerGenderController.text.trim(),
                age: int.tryParse(marketerAgeController.text.trim()) ?? 0,
                currentJobTitle:
                marketerCurrentJobTitleController.text.trim(),
                currentJobType:
                marketerCurrentJobTypeController.text.trim(),
                jobHistory: jobHistoryList,
                amAn: marketerIAmAnController.text.trim(),
                preferenceJobType:
                selectedCurrentJobType ?? '',
                previousIndustry:
                selectedPreviousIndustry ?? '',
                agentCount: 0
              );

              // ✅ ADD AFFILIATE
              await ref.read(affiliateControllerProvider.notifier).addAffiliate(
                affiliateModel: affiliate, context: context,);

              // ✅ UPDATE FIRM
              if (currentFirm != null) {
                final List<String> existingMembers = List<String>.from(currentFirm.teamMembers);

                existingMembers.add(affiliate.reference!.id);

                final updatedFirm = currentFirm.copyWith(teamMembers: existingMembers,);

                await ref.read(leadControllerProvider.notifier)
                    .updateLead(leadModel: updatedFirm, context: context,);
              }
              if (!context.mounted) return;
              setState(() => isCreatingAccount = false);

              // ✅ CLOSE BOTTOM SHEET

              showSuccessAlertDialog(context: context,
                title: 'Registration Successful',
                subtitle: 'You have successfully completed your Registration',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              );
              clearAllRegistrationData();

            } catch (e) {
              if (!context.mounted) return;

              setState(() => isCreatingAccount = false);
              showCommonSnackbar(context, "Failed to create account");
            }
          }

          // ================= UI =================
          return Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Pallet.backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(width * 0.05),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.03,
                      right: width * 0.03,
                      top: width * 0.05,
                      bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                          width * 0.05,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            height: 4,
                            width: 50,
                            margin:
                            const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        // Header
                        Container(
                          width: width,
                          padding: EdgeInsets.all(width * 0.02),
                          decoration: BoxDecoration(
                            color: Pallet.lightBlue,
                            borderRadius:
                            BorderRadius.circular(width * 0.02),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Career Preferences",
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: width * 0.02),
                              Row(
                                children: [
                                  _stepCircle("1", true),
                                  _stepLine(true),
                                  _stepCircle("2", true),
                                  _stepLine(true),
                                  _stepCircle("3", true),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: width * 0.02),

                        // I'm an
                        SizedBox(
                          height: fieldHeight,
                          child: inputField(
                            "I'm an..",
                            marketerIAmAnController,
                            TextInputType.text,
                            const SizedBox(),
                          ),
                        ),

                        SizedBox(height: width * 0.02),

                        // Multiple Industry
                        _buildMultipleIndustryDropdown(
                          ref: widgetRef,
                          label:
                          "Preferred Industries (Max 3)",
                          selectedValues: selectedIndustries,
                          onChanged: (values) {
                            setState(() =>
                            selectedIndustries = values);
                          },
                        ),

                        SizedBox(height: width * 0.02),

                        // Job Type
                        SizedBox(
                          height: fieldHeight,
                          child: dropdownField<String>(
                            label: "Preferred Job Type",
                            value: selectedCurrentJobType,
                            items: jobTypeList
                                .map((e) =>
                                DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCurrentJobType = value;
                                marketerPreferenceJobTypeController
                                    .text = value ?? "";
                              });
                            },
                          ),
                        ),

                        SizedBox(height: width * 0.02),

                        // Previous Industry
                        _buildIndustryDropdown(
                          ref: widgetRef,
                          label: "Previous Industry",
                          selectedValue:
                          selectedPreviousIndustry,
                          onChanged: (value) {
                            setState(() {
                              selectedPreviousIndustry = value;
                              marketerPreviousController.text =
                                  value ?? "";
                            });
                          },
                        ),

                        SizedBox(height: width * 0.04),

                        // CREATE ACCOUNT BUTTON
                        SizedBox(
                          height: width * 0.13,
                          width: double.infinity,
                          child: ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              isCreatingAccount
                                  ? Pallet.greyColor
                                  : Pallet.secondaryColor,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    width * 0.02),
                              ),
                            ),
                            onPressed: isCreatingAccount
                                ? null
                                : createAccount,
                            child: isCreatingAccount
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(
                                    width: width * 0.02),
                                Text(
                                  "Creating Account...",
                                  style:
                                  GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize:
                                    width * 0.04,
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              "Create Account",
                              style:
                              GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: width * 0.04,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// ✅ Multiple Industry Dropdown (Max 3)
Widget _buildMultipleIndustryDropdown({
  required WidgetRef ref,
  required String label,
  required List<String> selectedValues,
  required ValueChanged<List<String>> onChanged,
}) {
  return ref.watch(industryStreamProvider('')).when(
    data: (industries) {
      if (industries.isEmpty) {
        return Container(
          height: fieldHeight,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: Text(
            "No industries available",
            style: GoogleFonts.dmSans(
              fontSize: width * 0.035,
              color: Colors.orange,
            ),
          ),
        );
      }

      final List<String> industryNames =
      industries.map((i) => i.name).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _showMultiSelectIndustryDialog(
                context: ref.context,
                industries: industryNames,
                selectedValues: selectedValues,
                onChanged: onChanged,
                label: label,
              );
            },
            child: Container(
              height: fieldHeight,
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03, vertical: width * 0.015),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Pallet.borderColor),
                borderRadius: BorderRadius.circular(width * 0.025),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedValues.isEmpty
                          ? label
                          : "${selectedValues.length} industry selected",
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                        color: selectedValues.isNotEmpty
                            ? Colors.black87
                            : Pallet.greyColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),

          // ✅ Show selected industries as chips
          if (selectedValues.isNotEmpty) ...[
            SizedBox(height: width * 0.02),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedValues.map((industry) {
                return Chip(
                  label: Text(
                    industry,
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.03,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Pallet.secondaryColor,
                  deleteIcon: Icon(
                    Icons.close,
                    size: width * 0.04,
                    color: Colors.white,
                  ),
                  onDeleted: () {
                    final updated = List<String>.from(selectedValues);
                    updated.remove(industry);
                    onChanged(updated);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      );
    },
    error: (error, stackTrace) {
      return Container(
        height: fieldHeight,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Pallet.borderColor),
          borderRadius: BorderRadius.circular(width * 0.025),
        ),
        child: Text(
          "Error loading industries",
          style: GoogleFonts.dmSans(
            fontSize: width * 0.035,
            color: Colors.red,
          ),
        ),
      );
    },
    loading: () => Container(
      height: fieldHeight,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Pallet.borderColor),
        borderRadius: BorderRadius.circular(width * 0.025),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            'Loading industries...',
            style: GoogleFonts.dmSans(
              fontSize: width * 0.035,
              color: Pallet.greyColor,
            ),
          ),
        ],
      ),
    ),
  );
}

// ✅ Multi-Select Industry Dialog
void _showMultiSelectIndustryDialog({
  required BuildContext context,
  required List<String> industries,
  required List<String> selectedValues,
  required ValueChanged<List<String>> onChanged,
  required String label,
}) {
  String searchQuery = '';
  List<String> tempSelected = List.from(selectedValues);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final filteredIndustries = industries
              .where((industry) =>
              industry.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${tempSelected.length}/3 selected",
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.03,
                    color: Pallet.greyColor,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search industries...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: width * 0.02,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: filteredIndustries.isEmpty
                        ? Center(
                      child: Text(
                        'No industries found',
                        style:
                        GoogleFonts.dmSans(color: Pallet.greyColor),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredIndustries.length,
                      itemBuilder: (context, index) {
                        final industry = filteredIndustries[index];
                        final isSelected =
                        tempSelected.contains(industry);
                        final isDisabled =
                            !isSelected && tempSelected.length >= 3;

                        return ListTile(
                          enabled: !isDisabled,
                          title: Text(
                            industry,
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.035,
                              color: isDisabled
                                  ? Pallet.greyColor
                                  : isSelected
                                  ? Pallet.secondaryColor
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                              color: Pallet.secondaryColor)
                              : null,
                          onTap: isDisabled
                              ? null
                              : () {
                            setState(() {
                              if (isSelected) {
                                tempSelected.remove(industry);
                              } else {
                                if (tempSelected.length < 3) {
                                  tempSelected.add(industry);
                                }
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(color: Pallet.greyColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallet.secondaryColor,
                ),
                onPressed: () {
                  onChanged(tempSelected);
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: GoogleFonts.dmSans(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// ✅ Single Industry Dropdown (for Previous Industry)
Widget _buildIndustryDropdown({
  required WidgetRef ref,
  required String label,
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
}) {
  return ref.watch(industryStreamProvider('')).when(
    data: (industries) {
      if (industries.isEmpty) {
        return Container(
          height: fieldHeight,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: Text(
            "No industries available",
            style: GoogleFonts.dmSans(
              fontSize: width * 0.035,
              color: Colors.orange,
            ),
          ),
        );
      }

      final List<String> industryNames =
      industries.map((i) => i.name).toList();

      return GestureDetector(
        onTap: () {
          _showSearchableIndustryDialog(
            context: ref.context,
            industries: industryNames,
            selectedValue: selectedValue,
            onChanged: onChanged,
            label: label,
          );
        },
        child: Container(
          height: fieldHeight,
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.03, vertical: width * 0.015),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Pallet.borderColor),
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedValue ?? label,
                  style: GoogleFonts.dmSans(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w500,
                    color: selectedValue != null
                        ? Colors.black87
                        : Pallet.greyColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ],
          ),
        ),
      );
    },
    error: (error, stackTrace) {
      return Container(
        height: fieldHeight,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Pallet.borderColor),
          borderRadius: BorderRadius.circular(width * 0.025),
        ),
        child: Text(
          "Error loading industries",
          style: GoogleFonts.dmSans(
            fontSize: width * 0.035,
            color: Colors.red,
          ),
        ),
      );
    },
    loading: () => Container(
      height: fieldHeight,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Pallet.borderColor),
        borderRadius: BorderRadius.circular(width * 0.025),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            'Loading industries...',
            style: GoogleFonts.dmSans(
              fontSize: width * 0.035,
              color: Pallet.greyColor,
            ),
          ),
        ],
      ),
    ),
  );
}

// Single Select Dialog
void _showSearchableIndustryDialog({
  required BuildContext context,
  required List<String> industries,
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
  required String label,
}) {
  String searchQuery = '';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final filteredIndustries = industries
              .where((industry) =>
              industry.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            title: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SizedBox(
              width: width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search industries...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: width * 0.02,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: filteredIndustries.isEmpty
                        ? Center(
                      child: Text(
                        'No industries found',
                        style:
                        GoogleFonts.dmSans(color: Pallet.greyColor),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredIndustries.length,
                      itemBuilder: (context, index) {
                        final industry = filteredIndustries[index];
                        final isSelected = industry == selectedValue;

                        return ListTile(
                          title: Text(
                            industry,
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.035,
                              color: isSelected
                                  ? Pallet.secondaryColor
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                              color: Pallet.secondaryColor)
                              : null,
                          onTap: () {
                            onChanged(industry);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(color: Pallet.greyColor),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _stepCircle(String text, bool active) {
  return Container(
    width: width * 0.05,
    height: width * 0.05,
    decoration: BoxDecoration(
      color: active ? const Color(0xFF00C9D7) : Colors.white,
      border: Border.all(
        color: active ? const Color(0xFF00C9D7) : Colors.grey.shade300,
      ),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: width * 0.03,
          color: active ? Colors.white : Colors.black54,
        ),
      ),
    ),
  );
}

Widget _stepLine(bool active) {
  return Expanded(
    child: Container(
      height: 2,
      color: active ? const Color(0xFF00C9D7) : Colors.grey.shade300,
    ),
  );
}
