import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Core/common/image-convert-to-url.dart';
import 'package:refrr_admin/Feature/website/controller/category-controler.dart';
import 'package:refrr_admin/Feature/website/controller/product-controller.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product-model.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  final LeadsModel? currentFirm;
  const EditProductScreen({
    super.key,
    required this.product,
    required this.currentFirm,
  });

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  List<String> keyPoints = [];
  XFile? selectedImage;
  String? currentImageUrl;
  bool isProcessing = false;
  String? selectedCategoryId;
  String? selectedCategoryName;

  @override
  void initState() {
    super.initState();

    productNameController.text = widget.product!.name;
    productDescriptionController.text = widget.product!.description;
    productPriceController.text = widget.product!.price;
    productOfferPriceController.text = widget.product!.offerPrice;
    productCommissionController.text = widget.product!.commission;
    keyPoints = List.from(widget.product!.keyPoints);
    currentImageUrl = widget.product!.imageUrl;
    selectedCategoryId = widget.product!.category;

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
            productCategoryController.text = match.first.name;
          });
        } else {
          setState(() =>
          productCategoryController.text = widget.product!.category);
        }
      } else {
        setState(() =>
        productCategoryController.text = widget.product!.category);
      }
    });
  }

  @override
  void dispose() {
    productNameController.clear();
    productDescriptionController.clear();
    productPriceController.clear();
    productOfferPriceController.clear();
    productCommissionController.clear();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = image);
  }

  Future<void> _handleUpdateProduct() async {
    if (productNameController.text.trim().isEmpty ||
        productDescriptionController.text.trim().isEmpty ||
        productPriceController.text.trim().isEmpty ||
        productCommissionController.text.trim().isEmpty) {
      showCommonSnackbar(context, 'Please fill all required fields');
      return;
    }
    // remove empty strings and trim spaces
    keyPoints.removeWhere((point) => point.trim().isEmpty);

    if (keyPoints.isEmpty) {
      showCommonSnackbar(context, 'Please add at least one valid feature');
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

      final updated = widget.product?.copyWith(
        name: productNameController.text.trim(),
        description: productDescriptionController.text.trim(),
        price: productPriceController.text.trim(),
        offerPrice:  productOfferPriceController.text.trim(),
        commission: productCommissionController.text.trim(),
        keyPoints: keyPoints,
        imageUrl: imageUrl,
        category: selectedCategoryId ?? widget.product!.category,
      );

      final controller = ref.read(productControllerProvider.notifier);
      await controller.updateProduct(
        leadId: widget.currentFirm?.reference?.id ?? '',
        product: updated!,
        context: context,
      );

      if (mounted && !ref.read(productControllerProvider)) {
        showSuccessAlertDialog(
          context: context,
          title: "Product updated successfully",
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
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(productControllerProvider) || isProcessing;

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Edit Product',),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
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
              const SizedBox(height: 20),

              inputField("Name", productNameController, TextInputType.name,
                  const SizedBox()),
              const SizedBox(height: 16),

              // CATEGORY FIELD with arrow and color
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
                                  controller: productCategoryController,
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
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color:Pallet.borderColor),
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
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
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
                                                productCategoryController.text = c.name;
                                                selectedCategoryId = c.documentId ?? c.id;
                                                selectedCategoryName = c.name;
                                                FocusScope.of(context).unfocus();
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
                    loading: () => Center(child: CommonLoader()),
                    error: (e, _) => Text('Error: $e',
                        style: const TextStyle(color: Colors.red)),
                  );
                },
              ),
              const SizedBox(height: 16),

              inputField(
                "Description",
                productDescriptionController,
                TextInputType.text,
                const SizedBox(),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: priceField('Price', productPriceController,
                        widget.currentFirm!.currency),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: priceField('Offer Price',
                        productOfferPriceController, widget.currentFirm!.currency),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              inputField("Commission", productCommissionController,
                  TextInputType.text, const SizedBox()),
              const SizedBox(height: 16),

              // FEATURES SECTION
              Row(
                children: [
                  Text('Features',
                      style: GoogleFonts.dmSans(
                          fontSize: width * 0.034,
                          fontWeight: FontWeight.w600)),
                  Spacer(),
                  // ➕ Add new feature button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          keyPoints.add('');
                        });
                      },
                      icon: const Icon(Icons.add, color: Pallet.primaryColor),
                      label: Text(
                        "Add new feature",
                        style: GoogleFonts.dmSans(
                          color: Pallet.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: keyPoints.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      initialValue: keyPoints[index],
                      onChanged: (val) => keyPoints[index] = val,
                      maxLines: 1,
                      decoration: const InputDecoration(
                          hintText: "Enter Features",
                          border: InputBorder.none),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: width * 0.12,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleUpdateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CommonLoader())
                      : Text(
                    "Update Product",
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