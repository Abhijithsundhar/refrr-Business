import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/Team/screens/bottomsheets/add-own-team-bottomsheet3.dart';
import 'package:refrr_admin/Feature/Team/screens/bottomsheets/job-history-alert.dart';
import 'package:refrr_admin/models/job-history-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

final List<String> qualificationList = [
  'SSLC',
  'Higher Secondary',
  'Diploma',
  'ITI (Industrial Training Institute)',
  'Polytechnic Diploma',
  'Bachelors Degree',
  'Masters Degree',
  'M.Phil',
  'Ph.D / Doctorate',
  'Professional Certification',
  'Other',
];

final List<String> jobTitleList = ["Developer", "Designer", "Manager"];

final List<String> jobTypeList = [
  "Full Time",
  "Part Time",
  "Contract",
  "Freelance"
];

final List<String> exp = [
  'Less than 1 year',
  '1 year',
  '2 years',
  '3 years',
  '4 years',
  '5 years',
  '6 years',
  '7 years',
  '8 years',
  '8+ years',
];

const double fieldHeight = 55.0;

Widget registration2BottomSheet(BuildContext context, LeadsModel? currentFirm) {
  final parentContext = context;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      bool validateFields() {
        if (selectedQualification == null || selectedQualification!.isEmpty) {
          showCommonSnackbar(
              context, "Please select your highest qualification");
          return false;
        }
        if (marketerCurrentJobTitleController.text.trim().isEmpty) {
          showCommonSnackbar(context, "Please enter your current job title");
          return false;
        }
        if (selectedJobType == null || selectedJobType!.isEmpty) {
          showCommonSnackbar(context, "Please select your current job type");
          return false;
        }
        if (selectedExp == null || selectedExp!.isEmpty) {
          showCommonSnackbar(context, "Please select years of experience");
          return false;
        }
        if (jobHistoryList.isEmpty) {
          showCommonSnackbar(
              context, "Please add at least one job history entry");
          return false;
        }
        return true;
      }

      return Align(  // <-- ADDED Align widget
        alignment: Alignment.bottomCenter,  // <-- Align to bottom
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
                  bottom: MediaQuery.of(context).viewInsets.bottom + width * 0.05,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 50,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    // Header
                    Container(
                      width: width,
                      padding: EdgeInsets.all(width * 0.02),
                      decoration: BoxDecoration(
                        color: Pallet.lightBlue,
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Professional Information",
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
                              _stepLine(false),
                              _stepCircle("3", false),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: width * 0.02),

                    // Highest Qualification
                    SizedBox(
                      height: fieldHeight,
                      child: dropdownField<String>(
                        label: "Highest Qualification",
                        value: selectedQualification,
                        items: qualificationList
                            .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedQualification = value;
                            marketerQualificationController.text = value ?? "";
                          });
                        },
                      ),
                    ),

                    SizedBox(height: width * 0.02),

                    // Current Job Title
                    SizedBox(
                      height: fieldHeight,
                      child: inputField(
                        'Current Job Title',
                        marketerCurrentJobTitleController,
                        TextInputType.text,
                        SizedBox(),
                      ),
                    ),

                    SizedBox(height: width * 0.02),

                    // Current Job Type
                    SizedBox(
                      height: fieldHeight,
                      child: dropdownField<String>(
                        label: "Current Job Type",
                        value: selectedJobType,
                        items: jobTypeList
                            .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedJobType = value;
                            marketerCurrentJobTypeController.text = value ?? "";
                          });
                        },
                      ),
                    ),

                    SizedBox(height: width * 0.02),

                    // Years of Experience
                    SizedBox(
                      height: fieldHeight,
                      child: dropdownField<String>(
                        label: "Years of Experience",
                        value: selectedExp,
                        items: exp
                            .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedExp = value;
                            marketerExpireanceController.text = value ?? "";
                          });
                        },
                      ),
                    ),

                    SizedBox(height: width * 0.02),

                    // Add Job History Button
                    GestureDetector(
                      onTap: () {
                        showAddJobHistoryDialog(
                          context,
                          onAdd: (job) {
                            setState(() {
                              jobHistoryList.add(job);
                            });
                          },
                        );
                      },
                      child: _buildKeyPointsSection(),
                    ),

                    SizedBox(height: width * 0.02),

                    // Show Added Job History
                    if (jobHistoryList.isNotEmpty)
                      Column(
                        children: jobHistoryList.asMap().entries.map((entry) {
                          int index = entry.key;
                          JobHistory job = entry.value;

                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(width * 0.03),
                            margin: EdgeInsets.only(bottom: width * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(width * 0.02),
                              border: Border.all(color: Pallet.borderColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job.role ?? '',
                                        style: GoogleFonts.dmSans(
                                          fontSize: width * 0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: width * 0.01),
                                      Text(
                                        'Experience: ${job.experience ?? "N/A"}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: width * 0.03,
                                          color: Pallet.greyColor,
                                        ),
                                      ),
                                      SizedBox(height: width * 0.005),
                                      Text(
                                        'Industry: ${job.industry ?? "N/A"}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: width * 0.03,
                                          color: Pallet.greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete button
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: width * 0.05,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      jobHistoryList.removeAt(index);
                                    });
                                    showCommonSnackbar(
                                        context, "Job history removed");
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    SizedBox(height: width * 0.02),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: width * 0.13,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Pallet.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                        ),
                        onPressed: () {
                          if (validateFields()) {
                            Navigator.pop(context);
                            _showSlideSheet(
                              parentContext,
                              registration3BottomSheet(parentContext, currentFirm),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Next",
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: width * 0.01),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                              size: width * 0.04,
                            ),
                          ],
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
}

// Slide animation helper - UPDATED
void _showSlideSheet(BuildContext context, Widget sheet) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return sheet;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),  // <-- Changed from (1.0, 0.0) to (0.0, 1.0) for bottom slide
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

// Job History Input Section
Widget _buildKeyPointsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          Container(
            height: fieldHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Pallet.borderColor),
              borderRadius: BorderRadius.circular(width * 0.025),
              color: Colors.white,
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: width * 0.03,
            ),
            child: Text(
              "Add Job History",
              style: GoogleFonts.dmSans(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w500,
                color: Pallet.greyColor,
              ),
            ),
          ),
          // Add Button
          Positioned(
            right: width * 0.02,
            top: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              margin: EdgeInsets.symmetric(vertical: width * 0.015),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(width * 0.02),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: width * 0.055,
              ),
            ),
          ),
        ],
      ),
    ],
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