
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/custom-text-field.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Core/common/image-convert-to-url.dart';
import 'package:refrr_admin/Feature/website/controller/category-controler.dart';
import 'package:refrr_admin/Feature/website/controller/product-controller.dart';
import 'package:refrr_admin/Feature/website/controller/service-controller.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product-model.dart';
import 'package:refrr_admin/models/services-model.dart';

/// Which form is active in the bottom sheet
enum AddType { product, service }

/// Unified bottom sheet entry point
void showAddBottomSheet(
    BuildContext context,
    LeadsModel? currentFirm, {
      AddType initialTab = AddType.product,
    }) {
  final rootContext = context;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Pallet.backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(width * 0.05),
      ),
    ),
    builder: (sheetContext) {
      return ProviderScope(
        // in case this is not in the main ProviderScope
        parent: ProviderScope.containerOf(context),
        child: _AddBottomSheetContent(
          rootContext: rootContext,
          sheetContext: sheetContext,
          currentFirm: currentFirm,
          initialTab: initialTab,
        ),
      );
    },
  );
}

/// Optional: keep old APIs working if they are used elsewhere
void showAddProductBottomSheet(
    BuildContext context, LeadsModel? currentFirm) =>
    showAddBottomSheet(context, currentFirm, initialTab: AddType.product);

void showAddServiceBottomSheet(
    BuildContext context, LeadsModel? currentFirm) =>
    showAddBottomSheet(context, currentFirm, initialTab: AddType.service);

///  INTERNAL WIDGET

class _AddBottomSheetContent extends ConsumerStatefulWidget {
  final BuildContext rootContext;
  final BuildContext sheetContext;
  final LeadsModel? currentFirm;
  final AddType initialTab;

  const _AddBottomSheetContent({
    required this.rootContext,
    required this.sheetContext,
    required this.currentFirm,
    this.initialTab = AddType.product,
  });

  @override
  ConsumerState<_AddBottomSheetContent> createState() =>
      _AddBottomSheetContentState();
}

class _AddBottomSheetContentState
    extends ConsumerState<_AddBottomSheetContent> {
  AddType _selectedType = AddType.product;

  XFile? selectedImage;
  bool isProcessing = false;

  // Product-only
  List<String> keyPoints = [];

  // Category
  String? selectedCategoryId;
  String? selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTab;
  }

  // Common helpers

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  // Key points (Product)

  void addKeyPoint() {
    if (keyPointController.text.trim().isNotEmpty) {
      setState(() {
        keyPoints.add(keyPointController.text.trim());
        keyPointController.clear();
      });

      ScaffoldMessenger.of(widget.rootContext).showSnackBar(
        SnackBar(
          content: const Text('Features added'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(width * 0.04),
        ),
      );
    } else {
      showCommonSnackbar(widget.rootContext, 'Please enter a Features');
    }
  }

  void removeKeyPoint(int index) {
    setState(() => keyPoints.removeAt(index));

    ScaffoldMessenger.of(widget.rootContext).showSnackBar(
      SnackBar(
        content: const Text('Features removed'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(width * 0.04),
      ),
    );
  }

  // Submit Product

  Future<void> _handleAddProduct() async {
    if (productNameController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter product name');
      return;
    }
    if (productDescriptionController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter description');
      return;
    }
    if (productPriceController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter price');
      return;
    }
    if (productCommissionController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter commission');
      return;
    }
    if (selectedImage == null) {
      showCommonSnackbar(widget.rootContext, 'Please select an image');
      return;
    }
    if (keyPoints.isEmpty) {
      showCommonSnackbar(
          widget.rootContext, 'Please add at least one Features');
      return;
    }

    setState(() => isProcessing = true);

    try {
      final imageUrl = await uploadImage(
        image: selectedImage!,
        context: widget.rootContext,
      );

      if (imageUrl == null) {
        setState(() => isProcessing = false);
        showCommonSnackbar(widget.rootContext, 'Failed to upload image');
        return;
      }

      final product = ProductModel(
        name: productNameController.text.trim(),
        description: productDescriptionController.text.trim(),
        price: productPriceController.text.trim(),
        offerPrice: productOfferPriceController.text.trim().isEmpty
            ? productPriceController.text.trim()
            : productOfferPriceController.text.trim(),
        commission: productCommissionController.text.trim(),
        imageUrl: imageUrl,
        keyPoints: keyPoints,
        addedBy: widget.currentFirm?.reference?.id ?? '',
        delete: false,
        createTime: DateTime.now(),
        category: selectedCategoryId ?? '',
        brand: brandController.text.trim(),
      );

      setState(() => isProcessing = false);

      await ref.read(productControllerProvider.notifier).addProduct(
        leadId: widget.currentFirm?.reference?.id ?? '',
        product: product,
        context: widget.rootContext,
      );

      if (mounted && !ref.read(productControllerProvider)) {
        showSuccessAlertDialog(
          context: widget.rootContext,
          title: "Product Added Successfully",
          subtitle: "You have successfully added your product",
          onTap: () {
            productNameController.clear();
            productDescriptionController.clear();
            productPriceController.clear();
            productOfferPriceController.clear();
            productCommissionController.clear();
            productCategoryController.clear();
            brandController.clear();
            selectedCategoryId = null;
            selectedCategoryName = null;

            setState(() {
              selectedImage = null;
              keyPoints.clear();
            });

            Navigator.pop(widget.rootContext); // dialog
            Navigator.pop(widget.sheetContext); // bottom sheet
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isProcessing = false);
        showCommonSnackbar(widget.rootContext, 'Error: $e');
      }
    }
  }

  // Submit Service

  Future<void> _handleAddService() async {
    if (serviceNameController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter service name');
      return;
    }
    if (serviceDescriptionController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter description');
      return;
    }
    if (serviceCommissionController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter commission');
      return;
    }
    if (serviceStartingPriceController.text.trim().isEmpty) {
      showCommonSnackbar(widget.rootContext, 'Please enter starting price');
      return;
    }

    if (selectedImage == null) {
      showCommonSnackbar(widget.rootContext, 'Please select an image');
      return;
    }

    setState(() => isProcessing = true);

    try {
      final imageUrl = await uploadImage(
        image: selectedImage!,
        context: widget.rootContext,
      );

      if (imageUrl == null) {
        setState(() => isProcessing = false);
        showCommonSnackbar(widget.rootContext, 'Failed to upload image');
        return;
      }

      final service = ServiceModel(
        name: serviceNameController.text.trim(),
        image: imageUrl,
        startingPrice:
        int.tryParse(serviceStartingPriceController.text.trim()) ?? 0,
        endingPrice:
        int.tryParse(serviceEndingPriceController.text.trim()) ?? 0,
        commission: serviceCommissionController.text.trim(),
        leadsGiven: 0,
        createTime: DateTime.now(),
        delete: false,
        commissionFor: 'Converted',
        description: serviceDescriptionController.text.trim(),
        category: selectedCategoryId??'',
        brand: brandController.text.trim(),
        addedBy: widget.currentFirm?.reference?.id ?? '',
      );

      setState(() => isProcessing = false);

      await ref.read(serviceControllerProvider.notifier).addService(
        leadId: widget.currentFirm?.reference?.id ?? '',
        service: service, context: widget.rootContext,);

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted && !ref.read(serviceControllerProvider)) {
        showSuccessAlertDialog(
          context: widget.rootContext,
          title: "Service Added Successfully",
          subtitle: "You have successfully added your service",
          onTap: () {
            serviceNameController.clear();
            serviceDescriptionController.clear();
            serviceCommissionController.clear();
            serviceStartingPriceController.clear();
            serviceEndingPriceController.clear();
            productCategoryController.clear();
            brandController.clear();

            setState(() => selectedImage = null);

            Navigator.pop(widget.rootContext); // dialog
            Navigator.pop(widget.sheetContext); // bottom sheet
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isProcessing = false);
        showCommonSnackbar(widget.rootContext, 'Error: $e');
      }
    }
  }

  // UI Pieces

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _typeChip(AddType.product, 'Product'),
        SizedBox(width: width * 0.06),
        _typeChip(AddType.service, 'Service'),
      ],
    );
  }

  Widget _typeChip(AddType type, String label) {
    final bool isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      child: Row(
        children: [
          Container(
            width: width * 0.05,
            height: width * 0.05,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Pallet.primaryColor,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
              child: Container(
                width: width * 0.025,
                height: width * 0.025,
                decoration: BoxDecoration(
                  color: Pallet.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
                : null,
          ),
          SizedBox(width: width * 0.02),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Pallet.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Consumer(
      builder: (context, ref, _) {
        final asyncCategories = ref.watch(categoriesFutureProvider);
        return asyncCategories.when(
          data: (categories) {
            return Container(
              margin: EdgeInsets.only(bottom: width * 0.02),
              child: StatefulBuilder(
                builder: (context, setInner) {
                  final visibleSuggestions =
                  ValueNotifier<List<dynamic>>(categories);
                  final showDropdown = ValueNotifier<bool>(false);
                  final focusNode = FocusNode();

                  if (selectedCategoryName != null &&
                      productCategoryController.text.isEmpty) {
                    productCategoryController.text = selectedCategoryName!;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange: (hasFocus) {
                          showDropdown.value = hasFocus;
                        },
                        child: TextField(
                          controller: productCategoryController,
                          focusNode: focusNode,
                          onChanged: (pattern) {
                            final lower = pattern.toLowerCase();
                            visibleSuggestions.value = categories
                                .where((c) =>
                                c.name.toLowerCase().contains(lower))
                                .toList();
                            showDropdown.value = true;
                          },
                          decoration: InputDecoration(
                            labelText: "Choose Category",
                            labelStyle: GoogleFonts.dmSans(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w500,
                              color: Pallet.greyColor,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: width * 0.03,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Pallet.borderColor),
                              borderRadius:
                              BorderRadius.circular(width * 0.025),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Pallet.borderColor),
                              borderRadius:
                              BorderRadius.circular(width * 0.025),
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: showDropdown,
                        builder: (context, bool open, _) {
                          if (!open) return const SizedBox.shrink();
                          return ValueListenableBuilder(
                            valueListenable: visibleSuggestions,
                            builder:
                                (context, List<dynamic> filtered, _) {
                              if (filtered.isEmpty) {
                                return Padding(
                                  padding:
                                  EdgeInsets.only(top: width * 0.02),
                                  child: Text(
                                    'No category found',
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * 0.034,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                margin:
                                EdgeInsets.only(top: width * 0.02),
                                constraints: BoxConstraints(
                                  maxHeight: height * 0.4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(
                                      width * 0.02),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final category = filtered[index];
                                    return ListTile(
                                      dense: true,
                                      visualDensity:
                                      const VisualDensity(
                                          horizontal: -4,
                                          vertical: -2),
                                      title: Text(
                                        category.name,
                                        style: GoogleFonts.dmSans(
                                            fontSize: width * 0.035),
                                      ),
                                      onTap: () {
                                        productCategoryController.text =
                                            category.name;
                                        selectedCategoryId =
                                            category.documentId ??
                                                category.id;
                                        selectedCategoryName =
                                            category.name;

                                        FocusScope.of(context)
                                            .unfocus();
                                        showDropdown.value = false;

                                        ScaffoldMessenger.of(
                                            widget.rootContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Category selected: ${category.name}'),
                                            duration:
                                            const Duration(
                                                seconds: 1),
                                            backgroundColor:
                                            Pallet.secondaryColor,
                                          ),
                                        );
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
              ),
            );
          },
          loading: () => Padding(
            padding: EdgeInsets.symmetric(vertical: width * 0.02),
            child: const LinearProgressIndicator(),
          ),
          error: (e, _) => Text(
            'Error: $e',
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
  final TextEditingController keyPointController = TextEditingController();

  Widget _buildKeyPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field + Add button
        Stack(
          children: [
            TextField(
              controller: keyPointController,
              onSubmitted: (_) => addKeyPoint(),
              textInputAction: TextInputAction.done,
              enabled: !isProcessing,
              decoration: InputDecoration(
                labelText: "Add Features",
                labelStyle: GoogleFonts.dmSans(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Pallet.greyColor,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: width * 0.03,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Pallet.borderColor),
                  borderRadius: BorderRadius.circular(width * 0.025),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Pallet.borderColor),
                  borderRadius: BorderRadius.circular(width * 0.025),
                ),
              ),
            ),
            Positioned(
              right: width * 0.02,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: isProcessing ? null : addKeyPoint,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  margin: EdgeInsets.symmetric(vertical: width * 0.02),
                  decoration: BoxDecoration(
                    color: isProcessing
                        ? ColorConstants.primaryColor.withOpacity(0.5)
                        : ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: width * 0.045,
                      ),
                      Text(
                        'Add',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        if (keyPoints.isNotEmpty) ...[
          SizedBox(height: width * 0.04),
          Container(
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.025),
              border: Border.all(color: Pallet.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: ColorConstants.primaryColor,
                      size: width * 0.05,
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      'Added Features (${keyPoints.length})',
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: width * 0.03),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: keyPoints.length,
                  separatorBuilder: (context, index) => Divider(
                    height: width * 0.04,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: width * 0.012,
                            right: width * 0.025,
                          ),
                          width: width * 0.02,
                          height: width * 0.02,
                          decoration: BoxDecoration(
                            color: ColorConstants.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            keyPoints[index],
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: isProcessing
                              ? null
                              : () => removeKeyPoint(index),
                          borderRadius:
                          BorderRadius.circular(width * 0.02),
                          child: Container(
                            padding: EdgeInsets.all(width * 0.015),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius:
                              BorderRadius.circular(width * 0.015),
                            ),
                            child: Icon(
                              Icons.close,
                              size: width * 0.04,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade600,
                  size: width * 0.05,
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Text(
                    'Add at-least one Features',
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.033,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final productLoading = ref.watch(productControllerProvider);
    final serviceLoading = ref.watch(serviceControllerProvider);

    final bool isControllerLoading =
    _selectedType == AddType.product ? productLoading : serviceLoading;

    final bool isLoading = isProcessing || isControllerLoading;

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
              // Handle
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

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add",
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  CircleIconButton(icon:Icons.close, onTap: (){
                    Navigator.pop(context);
                  }),
                ],
              ),

              SizedBox(height: width * 0.03),

              _buildTypeSelector(),
              SizedBox(height: width * 0.05),

              _buildCategoryField(),
              SizedBox(height: width * 0.02),

              inputField("Name",
                _selectedType == AddType.product
                    ? productNameController
                    : serviceNameController,
                TextInputType.name,
                const SizedBox(),
              ),
              SizedBox(height: width * 0.02),

              inputField("Description",
                _selectedType == AddType.product
                    ? productDescriptionController
                    : serviceDescriptionController,
                TextInputType.text,
                const SizedBox(),
                maxLines: 3,
              ),
              SizedBox(height: width * 0.02),

              inputField(
                "Brand",
                brandController,
                TextInputType.text,
                const SizedBox(),
              ),
              SizedBox(height: width * 0.02),

              // Price / Range row
              if (_selectedType == AddType.product) ...[
                Row(
                  children: [
                    Expanded(
                      child: priceField(
                        'Price',
                        productPriceController,
                        widget.currentFirm?.currency ?? '',
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: priceField(
                        'Offer Price',
                        productOfferPriceController,
                        widget.currentFirm?.currency ?? '',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: priceField(
                        "Range",
                        serviceStartingPriceController,
                        widget.currentFirm?.currency ?? '',
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(child: priceField("Range",
                        serviceEndingPriceController,
                        widget.currentFirm?.currency ?? '',
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: width * 0.02),

              inputField("Commission",
                _selectedType == AddType.product
                    ? productCommissionController
                    : serviceCommissionController,
                TextInputType.text,
                const SizedBox(),
              ),
              SizedBox(height: width * 0.02),

              // Image
              GestureDetector(
                onTap: isLoading ? null : pickImage,
                child: Container(
                  height: width * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: selectedImage == null
                      ? Row(mainAxisAlignment: MainAxisAlignment.center,
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
                    borderRadius:
                    BorderRadius.circular(width * 0.02),
                    child: Image.file(
                      File(selectedImage!.path),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              if (_selectedType == AddType.product) ...[
                SizedBox(height: width * 0.02),
                _buildKeyPointsSection(),
              ],

              SizedBox(height: width * 0.04),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: width * 0.12,
                child: GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                    if (_selectedType == AddType.product) {
                      _handleAddProduct();
                    } else {
                      _handleAddService();
                    }
                  },
                  child: Container(
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
                      child: CommonLoader(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}