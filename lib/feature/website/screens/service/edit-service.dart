import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/constants/sizedboxes.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Core/common/image-convert-to-url.dart';
import 'package:refrr_admin/Feature/website/controller/category-controler.dart';
import 'package:refrr_admin/Feature/website/controller/service-controller.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services-model.dart';

class EditServiceScreen extends ConsumerStatefulWidget {
  final ServiceModel? service;
  final LeadsModel? currentFirm;

  const EditServiceScreen({
    super.key,
    required this.service,
    required this.currentFirm,
  });

  @override
  ConsumerState<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends ConsumerState<EditServiceScreen> {
  XFile? selectedImage;
  String? currentImageUrl;
  bool isProcessing = false;
  String? selectedCategoryId;
  String? selectedCategoryName;

  @override
  void initState() {
    super.initState();
    serviceNameController.text = widget.service!.name;
    serviceDescriptionController.text = widget.service!.description;
    serviceCommissionController.text = widget.service!.commission;
    serviceStartingPriceController.text = widget.service!.startingPrice.toString();
    serviceEndingPriceController.text = widget.service!.endingPrice.toString();
    currentImageUrl = widget.service!.image;
    selectedCategoryId = widget.service!.category;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryNameFromId();
    });
  }

  Future<void> _loadCategoryNameFromId() async {
    final categoriesAsync = ref.read(categoriesFutureProvider);
    categoriesAsync.whenData((categories) {
      if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
        final match =
        categories.where((c) => c.documentId == selectedCategoryId).toList();
        if (match.isNotEmpty) {
          setState(() {
            selectedCategoryName = match.first.name;
            serviceCategoryController.text = match.first.name;
          });
        } else {
          setState(() =>
          serviceCategoryController.text = widget.service!.category ?? '');
        }
      } else {
        setState(() =>
        serviceCategoryController.text = widget.service!.category ?? '');
      }
    });
  }

  @override
  void dispose() {
    serviceNameController.clear();
    serviceDescriptionController.clear();
    serviceCommissionController.clear();
    serviceStartingPriceController.clear();
    serviceEndingPriceController.clear();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = image);
  }

  Future<void> _handleUpdateService() async {
    if (serviceNameController.text.trim().isEmpty ||
        serviceDescriptionController.text.trim().isEmpty ||
        serviceStartingPriceController.text.trim().isEmpty ||
        serviceCommissionController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please fill all required fields');
      return;
    }
    setState(() => isProcessing = true);

    try {
      String imageUrl = currentImageUrl ?? '';
      if (selectedImage != null) {
        final uploadedUrl =
        await uploadImage(image: selectedImage!, context: context);
        if (uploadedUrl == null) {
          setState(() => isProcessing = false);
          showCommonSnackbar(context, 'Image upload failed');
          return;
        }
        imageUrl = uploadedUrl;
      }

      final updatedService = widget.service?.copyWith(
        name: serviceNameController.text.trim(),
        description: serviceDescriptionController.text.trim(),
        commission: serviceCommissionController.text.trim(),
        startingPrice: int.tryParse(serviceStartingPriceController.text.trim()),
        endingPrice: int.tryParse(serviceEndingPriceController.text.trim()),
        image: imageUrl,
        category: selectedCategoryId ?? widget.service!.category,
      );

      final controller = ref.read(serviceControllerProvider.notifier);
      await controller.updateService(
        leadId: widget.currentFirm?.reference?.id ?? '',
        service: updatedService!,
        context: context,
      );

      if (mounted && !ref.read(serviceControllerProvider)) {
        showSuccessAlertDialog(
          context: context,
          title: "Service updated successfully",
          subtitle: "Changes have been saved",
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);

          },
        );
      }
    } catch (e) {
      setState(() => isProcessing = false);
      showCommonSnackbar(context, 'Error: $e');
    }
  }

  Future<void> _handleDeleteService() async {
    try {
      final serviceRef = widget.service?.reference;

      if (serviceRef == null) {
        showCommonSnackbar(context, 'Invalid service reference');
        return;
      }

      await serviceRef.delete();

      if (mounted) {
        Navigator.pop(context); // close alert box
        Navigator.pop(context); // pop screen
        showCommonSnackbar(context, 'Service deleted successfully');
      }
    } catch (e) {
      showCommonSnackbar(context, 'Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(serviceControllerProvider) || isProcessing;

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Edit Service',),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- IMAGE ----------
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(width * 0.02),
                      child: selectedImage != null
                          ? Image.file(
                        File(selectedImage!.path),
                        height: height * 0.25,
                        width: width,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        currentImageUrl ?? '',
                        height: height * 0.25,
                        width: width,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => CommonLoader(),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AssetConstants.upload,
                                width: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Change Image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h03,

              inputField("Name", serviceNameController, TextInputType.name,
                  const SizedBox()),
              AppSpacing.h02,

              // ---------- CATEGORY ----------
              Consumer(
                builder: (context, ref, _) {
                  final asyncCategories = ref.watch(categoriesFutureProvider);
                  return asyncCategories.when(
                    data: (categories) {
                      return StatefulBuilder(
                        builder: (context, setInner) {
                          final ValueNotifier<List<dynamic>> visible =
                          ValueNotifier<List<dynamic>>(categories);
                          final ValueNotifier<bool> open =
                          ValueNotifier<bool>(false);
                          final FocusNode focusNode = FocusNode();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Focus(
                                onFocusChange: (f) => open.value = f,
                                child: TextField(
                                  controller: serviceCategoryController,
                                  focusNode: focusNode,
                                  onChanged: (pattern) {
                                    final lower = pattern.toLowerCase();
                                    visible.value = categories
                                        .where((c) => c.name
                                        .toLowerCase()
                                        .contains(lower))
                                        .toList();
                                    open.value = true;
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Category",
                                    labelStyle: GoogleFonts.dmSans(
                                      fontSize: width * 0.035,
                                      fontWeight: FontWeight.w500,
                                      color: Pallet.greyColor,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Pallet.borderColor),
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Pallet.darkGreyColor,
                                    ),
                                    filled: false,
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: open,
                                builder: (context, bool show, _) {
                                  if (!show) return const SizedBox.shrink();
                                  return ValueListenableBuilder(
                                    valueListenable: visible,
                                    builder: (context, List<dynamic> list, _) {
                                      if (list.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("No category found"),
                                        );
                                      }
                                      return Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        constraints: BoxConstraints(
                                          maxHeight: height * 0.4,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: list.length,
                                          itemBuilder: (context, i) {
                                            final c = list[i];
                                            return ListTile(
                                              title: Text(c.name),
                                              onTap: () {
                                                serviceCategoryController.text =
                                                    c.name;
                                                selectedCategoryId =
                                                    c.documentId ?? c.id;
                                                selectedCategoryName = c.name;
                                                FocusScope.of(context)
                                                    .unfocus();
                                                open.value = false;
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CommonLoader()),
                    error: (e, _) => Text('Error: $e',
                        style: const TextStyle(color: Colors.red)),
                  );
                },
              ),
              AppSpacing.h02,

              inputField("Description", serviceDescriptionController,
                  TextInputType.text, const SizedBox(),
                  maxLines: 3),
              AppSpacing.h02,

              Row(
                children: [
                  Expanded(
                    child: priceField('Starting Price',
                        serviceStartingPriceController,
                        widget.currentFirm!.currency),
                  ),
                  AppSpacing.h02,
                  Expanded(
                    child: priceField('Ending Price',
                        serviceEndingPriceController,
                        widget.currentFirm!.currency),
                  ),
                ],
              ),
              AppSpacing.h02,

              inputField("Commission", serviceCommissionController,
                  TextInputType.text, const SizedBox()),
              AppSpacing.h03,
              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: width * 0.12,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleUpdateService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CommonLoader())
                      : Text(
                    "Update Service",
                    style: GoogleFonts.dmSans(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
