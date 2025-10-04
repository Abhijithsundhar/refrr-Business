import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/global variables.dart';
import 'package:refrr_admin/Core/common/image-picker.dart'; // PickedImage + helper
import 'package:refrr_admin/Core/common/loadings.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';

import 'package:refrr_admin/Feature/Services/controllor/offer-controller.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/offer-model.dart';

class AddOffer extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const AddOffer({super.key, this.currentFirm});

  @override
  ConsumerState<AddOffer> createState() => _AddOfferState();
}

class _AddOfferState extends ConsumerState<AddOffer> {
  PickedImage? _pickedImage;
  bool _saving = false;

  DateTime? _selectedOfferEndDate;
  DateTime? _selectedOfferStartDate;

  static const double kFieldHeight = 44;
  final _dateFmt = DateFormat('dd-MM-yyyy');

  // Local controllers to avoid conflicts with global controllers
  final TextEditingController _offerNameController = TextEditingController();
  final TextEditingController _offerAmountController = TextEditingController();
  final TextEditingController _offerDescriptionController = TextEditingController();
  final TextEditingController _offerStartDateController = TextEditingController();
  final TextEditingController _offerEndDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear inputs on load
    _offerNameController.text = '';
    _offerAmountController.text = '';
    _offerDescriptionController.text = '';

    // Default "From" date to today on page load
    _selectedOfferStartDate = DateTime.now();
    _offerStartDateController.text = _dateFmt.format(_selectedOfferStartDate!);

    // Ensure End Date is empty until user selects
    _selectedOfferEndDate = null;
    _offerEndDateController.clear();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _offerNameController.dispose();
    _offerAmountController.dispose();
    _offerDescriptionController.dispose();
    _offerStartDateController.dispose();
    _offerEndDateController.dispose();
    super.dispose();
  }

  File? _resolveFileFromPicked(PickedImage? picked) {
    if (picked == null) return null;

    try {
      if (picked is File) {
        return picked as File;
      }
      final dynamic p = picked;

      if (p.file != null && p.file is File) {
        return p.file as File;
      }
      if (p.imageFile != null && p.imageFile is File) {
        return p.imageFile as File;
      }
      if (p.path != null && p.path is String) {
        return File(p.path as String);
      }
      if (p.filePath != null && p.filePath is String) {
        return File(p.filePath as String);
      }

      final pathString = picked.toString();
      if (pathString.isNotEmpty && pathString != 'Instance of \'PickedImage\'') {
        return File(pathString);
      }
    } catch (e) {
      debugPrint('Error resolving file from picked image: $e');
    }

    return null;
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePickerHelper.pickImage();
      if (!mounted) return;
      if (picked != null) {
        setState(() => _pickedImage = picked);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      showCommonSnackbar(context, 'Failed to pick image');
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedOfferStartDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _selectedOfferStartDate = picked;
        // If end date is before start date, clear it
        if (_selectedOfferEndDate != null && _selectedOfferEndDate!.isBefore(picked)) {
          _selectedOfferEndDate = null;
          _offerEndDateController.clear();
        }
      });
      _offerStartDateController.text = _dateFmt.format(picked);
    }
  }

  Future<void> _pickEndDate() async {
    final base = _selectedOfferStartDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedOfferEndDate ?? base.add(const Duration(days: 7)),
      firstDate: base, // End date cannot be before start date
      lastDate: DateTime(base.year + 5),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedOfferEndDate = picked);
      _offerEndDateController.text = _dateFmt.format(picked);
    }
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffix,
    double vPad = 8,
    double hPad = 12,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F3F3),
      contentPadding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      suffix: suffix,
    );
  }

  void _clearForm() {
    _offerNameController.clear();
    _offerAmountController.clear();
    _offerDescriptionController.clear();
    _offerStartDateController.clear();
    _offerEndDateController.clear();

    if (mounted) {
      setState(() {
        _pickedImage = null;
        _selectedOfferStartDate = DateTime.now();
        _offerStartDateController.text = _dateFmt.format(_selectedOfferStartDate!);
        _selectedOfferEndDate = null;
        _saving = false;
      });
    }
  }

  bool _validateForm() {
    if (_offerNameController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please enter offer name');
      return false;
    }
    if (_pickedImage == null) {
      showCommonSnackbar(context, 'Please select an image');
      return false;
    }
    if (_offerAmountController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please enter amount');
      return false;
    }

    // Validate amount is a valid number
    final amount = double.tryParse(_offerAmountController.text.trim());
    if (amount == null || amount <= 0) {
      showCommonSnackbar(context, 'Please enter a valid amount');
      return false;
    }

    if (_offerDescriptionController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please enter description');
      return false;
    }
    if (_selectedOfferEndDate == null) {
      showCommonSnackbar(context, 'Please select end date');
      return false;
    }

    // Validate end date is after start date
    if (_selectedOfferEndDate!.isBefore(_selectedOfferStartDate!)) {
      showCommonSnackbar(context, 'End date must be after start date');
      return false;
    }

    return true;
  }

  Future<void> _submitOffer() async {
    if (!_validateForm()) return;

    try {
      setState(() => _saving = true);

      // Upload image
      final uploadedUrl = await ImagePickerHelper.uploadImageToFirebase(_pickedImage!);

      if (!mounted) return;

      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        if (mounted) {
          showCommonSnackbar(context, 'Image upload failed. Please try again.');
          setState(() => _saving = false);
        }
        return;
      }

      final OfferModel offer = OfferModel(
        name: _offerNameController.text.trim(),
        amount: _offerAmountController.text.trim(),
        endDate: _selectedOfferEndDate!,
        delete: false,
        createTime: DateTime.now(),
        currency: 'AED',
        description: _offerDescriptionController.text.trim(),
        mode: 'public',
        affiliate: '',
        image: uploadedUrl,
      );

      // Call the provider method
      await ref
          .read(offerControllerProvider.notifier)
          .addOffer(context: context, offerModel: offer);

      if (!mounted) return;

      // Clear form first
      _clearForm();

      // Show success message with a small delay to ensure UI updates
      if (mounted) {
        showCommonSnackbar(context, 'Offer added successfully!');

        // Add small delay before navigation to ensure snackbar is shown
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate back with proper context check
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(true);
        } else if (mounted) {
          // If can't pop, navigate to a specific route or replace current route
          Navigator.of(context).pushReplacementNamed('/offers'); // Replace with your offers list route
        }
      }

    } catch (e) {
      debugPrint('Error submitting offer: $e');
      if (mounted) {
        setState(() => _saving = false);
        showCommonSnackbar(context, 'Something went wrong! Please try again.');
      }
    }
  }

  void _handleBackNavigation() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      // If can't pop, navigate to a specific route
      Navigator.of(context).pushReplacementNamed('/home'); // Replace with your home route
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final previewFile = _resolveFileFromPicked(_pickedImage);

    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false; // Prevent default pop behavior
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: _handleBackNavigation,
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(right: width * .05, left: width * .05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading
                Padding(
                  padding: EdgeInsets.only(left: width * .017),
                  child: Text(
                    'Add new offer',
                    style: GoogleFonts.roboto(
                      fontSize: width * .04,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: mq.size.height * .02),

                // Offer name
                Padding(
                  padding: EdgeInsets.only(bottom: height * .01, left: width * .017),
                  child: Text(
                    'Offer Name',
                    style: GoogleFonts.roboto(
                      fontSize: width * .03,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF575757),
                    ),
                  ),
                ),
                SizedBox(
                  height: kFieldHeight,
                  child: TextField(
                    controller: _offerNameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDecoration(hint: '', vPad: 8),
                  ),
                ),
                SizedBox(height: mq.size.height * .02),

                // Image
                Padding(
                  padding: EdgeInsets.only(bottom: height * .01, left: width * .017),
                  child: Text(
                    'Add Image',
                    style: GoogleFonts.roboto(
                      fontSize: width * .03,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF575757),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent, width: 1),
                    ),
                    child: previewFile == null
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 44,
                            color: Colors.black54,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add image',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.file(
                            previewFile,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 44,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _pickedImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: mq.size.height * .02),

                // Amount (AED)
                Padding(
                  padding: EdgeInsets.only(bottom: height * .01, left: width * .017),
                  child: Text(
                    'Amount',
                    style: GoogleFonts.roboto(
                      fontSize: width * .03,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF575757),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: kFieldHeight,
                        child: TextField(
                          controller: _offerAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 14),
                          decoration: _inputDecoration(
                            hint: '',
                            vPad: 8,
                            suffix: const Text(
                              'AED',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: mq.size.height * .02),

                // Description
                Padding(
                  padding: EdgeInsets.only(bottom: height * .01, left: width * .017),
                  child: Text(
                    'Description',
                    style: GoogleFonts.roboto(
                      fontSize: width * .03,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF575757),
                    ),
                  ),
                ),
                TextField(
                  controller: _offerDescriptionController,
                  minLines: 5,
                  maxLines: 10,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration(hint: '', vPad: 12),
                ),
                SizedBox(height: height * .02),

                // Validity
                Padding(
                  padding: EdgeInsets.only(bottom: height * .01, left: width * .017),
                  child: Text(
                    'Validity',
                    style: GoogleFonts.roboto(
                      fontSize: width * .03,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF575757),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: kFieldHeight,
                        child: TextField(
                          controller: _offerStartDateController,
                          readOnly: true,
                          onTap: _pickStartDate,
                          style: const TextStyle(fontSize: 14),
                          decoration: _inputDecoration(
                            hint: 'From',
                            vPad: 8,
                            suffix: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * .02),
                    Expanded(
                      child: SizedBox(
                        height: kFieldHeight,
                        child: TextField(
                          controller: _offerEndDateController,
                          readOnly: true,
                          onTap: _pickEndDate,
                          style: const TextStyle(fontSize: 14),
                          decoration: _inputDecoration(
                            hint: 'Until',
                            vPad: 8,
                            suffix: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * .03),

                // Submit
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: height * .06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saving
                          ? null
                          : () async {
                        showCommonAlertBox(
                          context,
                          'Do you want to add this offer?',
                          _submitOffer,
                          'Yes',
                        );
                      },
                      child: _saving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Add Offer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}