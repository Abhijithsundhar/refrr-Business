import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refrr_admin/core/common/alert_box.dart';
import 'package:refrr_admin/core/common/custom_round_button.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/promote/controller/creative_controller.dart';
import 'package:refrr_admin/models/leads_model.dart';

void addCreativePopUp(BuildContext context ,LeadsModel? currentFirm) {
  final rootContext = context;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(width * 0.05),
      ),
    ),
    builder: (context) {
      File? selectedImage;

      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

            if (image != null) {
              setState(() {
                selectedImage = File(image.path);
              });
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                color: Pallet.backgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(width * 0.05),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DRAG INDICATOR
                    Center(
                      child: Container(
                        width: width * 0.12,
                        height: 4,
                        margin: EdgeInsets.only(bottom: width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    /// TITLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Creative",
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CircleFilledButton(
                          icon: Icons.close,
                          size: width * 0.08,
                          iconSize: width * 0.05,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    SizedBox(height: width * 0.05),

                    /// IMAGE PICKER
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(width * 0.02),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius:
                          BorderRadius.circular(width * 0.03),
                        ),
                        child: selectedImage == null
                            ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              AssetConstants.upload,
                              width: width * 0.08,
                            ),
                            SizedBox(height: width * 0.02),
                            Text(
                              "Upload Image",
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                            : ClipRRect(
                          borderRadius:
                          BorderRadius.circular(width * 0.02),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: width * 0.04),

                    /// ADD BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: Consumer(
                        builder: (context, ref, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                vertical: width * 0.025,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(width * 0.03),
                              ),
                            ),
                            onPressed: () {
                              if (selectedImage == null) {
                                showCommonSnackbar(context, 'Please select an image');
                                return;
                              }

                              final leadId = currentFirm?.reference?.id ?? '';
                              if (leadId.isEmpty) {
                                showCommonSnackbar(rootContext, 'Invalid firm');
                                return;
                              }
                              showSuccessAlertDialog(context: rootContext, title: 'Creative Added Successful',
                                  subtitle: 'You have successfully added your Creative',
                                  onTap: () {
                                    Navigator.pop(rootContext); // closes success dialog
                                    Navigator.pop(rootContext);

                                  });
                              // 🚀 RUN HEAVY WORK IN BACKGROUND
                              ref.read(creativeControllerProvider.notifier).addCreativeFlow(
                                file: selectedImage!,
                                leadId: leadId,
                                context: context,
                              );
                            },

                            child: Text(
                              "Add",
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: width * 0.03),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
