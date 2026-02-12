import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/promote/controller/offers-controller.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/offer-model.dart';
import 'package:refrr_admin/Core/common/image-convert-to-url.dart';

DateTime? selectedEndDate;

Future pickDate(
    BuildContext context,
    TextEditingController offerEndDateController,
    void Function(DateTime) onDateSelected,
    ) async {
  final DateTime? newDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (newDate != null) {
    offerEndDateController.text = "${newDate.day.toString().padLeft(2, '0')}-"
        "${newDate.month.toString().padLeft(2, '0')}-"
        "${newDate.year}";
    onDateSelected(newDate);
  }
}

void showAddOffersBottomSheet(BuildContext context, LeadsModel? currentFirm) {
  // Store the root context
  final rootContext = context;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Pallet.backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(width * 0.05)),
    ),
    builder: (sheetContext) {
      return _OffersBottomSheetContent(
        rootContext: rootContext,
        sheetContext: sheetContext,
        currentFirm: currentFirm,
      );
    },
  );
}

// Separate StatefulWidget to maintain state properly
class _OffersBottomSheetContent extends ConsumerStatefulWidget {
  final BuildContext rootContext;
  final BuildContext sheetContext;
  final LeadsModel? currentFirm;

  const _OffersBottomSheetContent({
    required this.rootContext,
    required this.sheetContext,
    required this.currentFirm,
  });

  @override
  ConsumerState<_OffersBottomSheetContent> createState() =>
      _OffersBottomSheetContentState();
}

class _OffersBottomSheetContentState
    extends ConsumerState<_OffersBottomSheetContent> {
  XFile? selectedImage;
  bool isProcessing = false;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> handleAddOffer() async {
    // Validation
    if (offerNameController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter offer name');
      return;
    }

    if (offerAmountController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter offer amount');
      return;
    }

    if (offerDescriptionController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter description');
      return;
    }

    if (selectedImage == null) {
      showCommonSnackbar(widget.rootContext, 'Please select an image');
      return;
    }

    if (selectedEndDate == null) {
      showCommonSnackbar(widget.rootContext, 'Please select end date');
      return;
    }

    // Start loading state for image upload
    setState(() {
      isProcessing = true;
    });

    String? imageUrl;

    try {
      // Upload image
      imageUrl = await uploadImage(
        image: selectedImage!,
        context: widget.rootContext,
      );

      if (imageUrl == null) {
        setState(() {
          isProcessing = false;
        });
        showCommonSnackbar(widget.rootContext, 'Failed to upload image');
        return;
      }

      // Create offer model
      final offer = OfferModel(
        name: offerNameController.text.trim(),
        amount: offerAmountController.text.trim(),
        endDate: selectedEndDate!,
        createTime: DateTime.now(),
        delete: false,
        currency: widget.currentFirm?.currency,
        description: offerDescriptionController.text.trim(),
        mode: 'public',
        affiliate: '',
        addedBy: widget.currentFirm?.reference?.id ?? '',
        image: imageUrl,
      );

      // Stop local loading, controller loading will take over
      setState(() {
        isProcessing = false;
      });

      // Add offer - this will trigger controller loading state
      await ref.read(offerControllerProviders.notifier).addOffer(
        context: widget.rootContext,
        offerModel: offer,
      );

      // Clear form only if still mounted and operation successful
      if (mounted && !ref.read(offerControllerProviders)) {
        offerNameController.clear();
        offerAmountController.clear();
        offerDescriptionController.clear();
        offerEndDateController.clear();
        selectedEndDate = null;
        setState(() {
          selectedImage = null;
        });
      }
    } catch (e) {
      // Stop loading on error
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
        showCommonSnackbar(widget.rootContext, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isControllerLoading = ref.watch(offerControllerProviders);
    final isLoading = isProcessing || isControllerLoading;

    return AbsorbPointer(
      absorbing: isLoading,
      child: Padding(
        padding: EdgeInsets.only(
          left: width * 0.05,
          right: width * 0.05,
          top: width * 0.08,
          bottom: MediaQuery.of(context).viewInsets.bottom + width * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              /// ---------- Header ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Offers",
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: width * 0.02),
                    child: CircleFilledButton(
                      icon: Icons.close,
                      size: width * 0.08,
                      onTap: () {
                        if (isLoading) return;
                        Navigator.pop(context);
                      },
                      iconSize: width * 0.05,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.03),

              /// ---------- Name ----------
              inputField("Name", offerNameController, SizedBox()),
              SizedBox(height: width * 0.02),

              /// ---------- Price ----------
              priceField("Price", offerAmountController,widget.currentFirm!.currency),
              SizedBox(height: width * 0.02),

              /// ---------- Description ----------
              inputField("Description",
                offerDescriptionController,
                const SizedBox(),
                maxLines: 3,
              ),

              /// ---------- Upload Image ----------
              SizedBox(height: width * 0.02),
              GestureDetector(
                onTap: isLoading ? null : pickImage,
                child: Container(
                  height: width * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: selectedImage == null
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AssetConstants.upload,
                        width: width * 0.05,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Upload Image",
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.035,
                        ),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    child: Image.file(
                      File(selectedImage!.path),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              /// ---------- Valid Until ----------
              SizedBox(height: width * 0.02),
              inputField(
                "Valid Until",
                offerEndDateController,
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                    pickDate(
                      context,
                      offerEndDateController,
                          (date) {
                        selectedEndDate = date;
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svg/calendarOff.svg',
                    width: width * 0.04,
                  ),
                ),
              ),
              SizedBox(height: width * 0.04),

              /// ---------- Add Button ----------
              SizedBox(
                width: double.infinity,
                height: width * 0.12,
                child: GestureDetector(
                  onTap: isLoading ? null : handleAddOffer,
                  child: Container(
                    height: width * 0.12,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isLoading
                          ? Pallet.secondaryColor.withOpacity(0.6)
                          : Pallet.secondaryColor,
                      borderRadius: BorderRadius.circular(width * 0.02),
                    ),
                    child: isLoading
                        ? SizedBox(
                      width: width * 0.05,
                      height: width * 0.05,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "Add",
                      style: GoogleFonts.dmSans(
                        color: Pallet.backgroundColor,
                        fontWeight: FontWeight.w500,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


/// ------------------------------------------------------------
/// CUSTOM INPUT FIELD WIDGET
/// ------------------------------------------------------------
Widget inputField(
    String hint, TextEditingController controller, Widget suffix,
    {int maxLines = 1, bool alwaysSuffix = false}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Pallet.borderColor),
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Pallet.borderColor),
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      labelText: hint,
      labelStyle: GoogleFonts.dmSans(
        fontSize: width * 0.035,
        fontWeight: FontWeight.w500,
        color: Pallet.greyColor,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: width * 0.03,
      ),
      suffixIcon: alwaysSuffix
          ? Padding(
        padding: EdgeInsets.only(right: width * 0.02),
        child: suffix,
      )
          : suffix,
      suffixIconConstraints: BoxConstraints(
        minWidth: 50,
        minHeight: 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.02),
        borderSide: BorderSide(color: Pallet.borderColor),
      ),
    ),
  );
}
