import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/common/custom_appBar.dart';
import 'package:refrr_admin/core/common/customtextfield.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/loader.dart';
import 'package:refrr_admin/core/common/web_category.dart';
import 'package:refrr_admin/core/constants/asset.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/core/theme/pallet.dart';
import 'package:refrr_admin/feature/Login/screens/connectivity.dart';
import 'package:refrr_admin/feature/website/controller/product_controller.dart';
import 'package:refrr_admin/feature/website/controller/service_controller.dart';
import 'package:refrr_admin/feature/website/controller/website_controller.dart';
import 'package:refrr_admin/feature/website/screens/product/product_screen.dart';
import 'package:refrr_admin/feature/website/screens/service/service_screen.dart';
import 'package:refrr_admin/feature/website/screens/website/bottomsheet.dart';
import 'package:refrr_admin/models/category_model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class WebsiteHomeScreen extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const WebsiteHomeScreen({super.key, this.currentFirm});

  @override
  ConsumerState<WebsiteHomeScreen> createState() => _WebsiteHomeScreenState();
}

class _WebsiteHomeScreenState extends ConsumerState<WebsiteHomeScreen> {
  // ✅ Local controller and search query tracker
  late TextEditingController searchController;
  String searchQuery = '';
  String selectedCategoryId = "All";

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(websiteControllerProvider.notifier)
          .checkHostedStatus(widget.currentFirm?.reference?.id ?? '');
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose(); // ✅ Properly disposed
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  // helper to fetch category documents by their ids
  Future<List<CategoryModel>> _loadCategories(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection(FirebaseCollections.categoryCollection)
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(
      doc.data(),
      ref: doc.reference,
    ).copyWith(documentId: doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentFirm = widget.currentFirm;
    final productsAsync =
    ref.watch(productsStreamProvider(currentFirm?.reference?.id ?? ''));
    final servicesAsync =
    ref.watch(servicesStreamProvider(currentFirm?.reference?.id ?? ''));

    // Check if either is loading
    final isLoading = productsAsync.isLoading || servicesAsync.isLoading;

    // Show single loading indicator if any data is loading
    if (isLoading) {
      return ConnectivityWrapper(
        child: Scaffold(
          backgroundColor: Pallet.backgroundColor,
          body: const Center(child: CommonLoader()),
        ),
      );
    }

    final bool bothEmpty =
        (productsAsync.maybeWhen(data: (p) => p.isEmpty, orElse: () => false)) &&
            (servicesAsync.maybeWhen(data: (s) => s.isEmpty, orElse: () => false));
    final websiteState = ref.watch(websiteControllerProvider);

    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Pallet.backgroundColor,
        appBar: BusinessAppBar(
          width: width,
          titleText: websiteState.isPublished
              ? websiteState.siteConfig?.websiteName ?? '' : 'Website',
          actions: [
            // GestureDetector(
            //   onTap: () {
            //     if (websiteState.isPublished) {
            //       shareButtonOnTapPopup(
            //         context: context,
            //         onShare: () {},
            //         url: websiteState.siteConfig?.url ?? '',
            //       );
            //     } else {
            //       final productsNow = productsAsync.asData?.value ?? [];
            //       final servicesNow = servicesAsync.asData?.value ?? [];
            //       final productIds =
            //       productsNow.map((p) => p.id).whereType<String>().toList();
            //       final serviceIds =
            //       servicesNow.map((s) => s.id).whereType<String>().toList();
            //       if (currentFirm == null) return;
            //       showDialog(
            //         context: context,
            //         builder: (context) => ShareAlert(
            //           currentFirm: currentFirm,
            //           productIds: productIds,
            //           serviceIds: serviceIds,
            //         ),
            //       );
            //     }
            //   },
            //   child: CircleSvgButton(
            //     child: SvgPicture.asset('assets/svg/shareblack.svg'),
            //   ),
            // ),
            // AppSpacing.w02,
            // GestureDetector(
            //   onTap: () {
            //     showCommonSnackbar(context,
            //         'This feature will be available in the next update.');
            //   },
            //   child: CircleSvgButton(
            //     child: SvgPicture.asset('assets/svg/CogOutline.svg'),
            //   ),
            // ),
          ],
        ),

        // ---------- BODY ----------
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: AppSpacing.h02),

                // ---------- Search ----------
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * .03),
                    child: inputField(
                      ' Search',
                      searchController,
                      TextInputType.text,
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(
                          'assets/svg/SearchGrey.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: AppSpacing.h01),

                // ---------- Category Section ----------
                SliverToBoxAdapter(
                  child: Builder(builder: (context) {
                    final prods = productsAsync.asData?.value ?? [];
                    final servs = servicesAsync.asData?.value ?? [];
                    final total = prods.length + servs.length;
                    if (total <= 1) return const SizedBox.shrink();

                    final allCategoryIds = {
                      ...prods
                          .map((p) => p.category)
                          .whereType<String>()
                          .where((id) => id.isNotEmpty),
                      ...servs
                          .map((s) => s.category)
                          .whereType<String>()
                          .where((id) => id.isNotEmpty),
                    }.toList();

                    return FutureBuilder<List<CategoryModel>>(
                      future: _loadCategories(allCategoryIds),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final categories = snapshot.data!;
                        if (categories.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // "All" chip
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCategoryId = "All";
                                      });
                                    },
                                    child: CircleAvatharList(
                                      "All",
                                      icon: Icons.grid_view,
                                      isSelected: selectedCategoryId == "All",
                                      label: "All",
                                    ),
                                  );
                                }
                                final c = categories[index - 1];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryId =
                                          c.documentId ?? c.documentId ?? '';
                                    });
                                  },
                                  child: CircleAvatharList(
                                    c.name,
                                    imageUrl: c.image,
                                    isSelected: selectedCategoryId ==
                                        (c.documentId ?? c.documentId ?? ''),
                                    label: c.name,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                // ---------- Products Section ----------
                SliverToBoxAdapter(
                  child: productsAsync.when(
                    data: (products) {
                      if (products.isEmpty) return const SizedBox.shrink();

                      // -------- Filters ----------
                      final filteredProducts = products.where((p) {
                        final matchesSearch =
                            p.name.toLowerCase().contains(searchQuery) ||
                                p.description.toLowerCase().contains(searchQuery);
                        final matchesCategory = selectedCategoryId == "All" ||
                            p.category == selectedCategoryId;
                        return matchesSearch && matchesCategory;
                      }).toList();

                      if (filteredProducts.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Featured Products",
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            AppSpacing.h02,
                            ProductsSection(
                                currentFirm: currentFirm,
                                products: filteredProducts),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error loading products: ${e.toString()}',
                          style: GoogleFonts.dmSans(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),

                // ---------- Services Section ----------
                SliverToBoxAdapter(
                  child: servicesAsync.when(
                    data: (services) {
                      if (services.isEmpty) return const SizedBox.shrink();

                      final filteredServices = services.where((s) {
                        final matchesSearch =
                            s.name.toLowerCase().contains(searchQuery) ||
                                s.description.toLowerCase().contains(searchQuery);
                        final matchesCategory = selectedCategoryId == "All" ||
                            s.category == selectedCategoryId;
                        return matchesSearch && matchesCategory;
                      }).toList();

                      if (filteredServices.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Popular Services",
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSpacing.h01,
                            ServicesSection(
                                currentFirm: currentFirm,
                                services: filteredServices),
                            AppSpacing.h03,
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error loading services: ${e.toString()}',
                          style: GoogleFonts.dmSans(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),

                // ---------- Empty/No Results Message ----------
                if (bothEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.2,
                        left: width * 0.06,
                        right: width * 0.06,
                      ),
                      child: Center(
                        child: Text(
                          "No products or services have been listed yet.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.04,
                            color: Pallet.darkGreyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        final prods = productsAsync.asData?.value ?? [];
                        final servs = servicesAsync.asData?.value ?? [];

                        final filteredProds = prods.where((p) {
                          final matchesSearch = p.name
                              .toLowerCase()
                              .contains(searchQuery) ||
                              p.description.toLowerCase().contains(searchQuery);
                          final matchesCategory = selectedCategoryId == "All" ||
                              p.category == selectedCategoryId;
                          return matchesSearch && matchesCategory;
                        }).toList();

                        final filteredServs = servs.where((s) {
                          final matchesSearch = s.name
                              .toLowerCase()
                              .contains(searchQuery) ||
                              s.description
                                  .toLowerCase()
                                  .contains(searchQuery);
                          final matchesCategory =
                              selectedCategoryId == "All" ||
                                  s.category == selectedCategoryId;
                          return matchesSearch && matchesCategory;
                        }).toList();

                        if (filteredProds.isEmpty && filteredServs.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: height * 0.1,
                              left: width * 0.06,
                              right: width * 0.06,
                            ),
                            child: Center(
                              child: Text(
                                "No results found for \"$searchQuery\"",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: width * 0.04,
                                  color: Pallet.darkGreyColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
              ],
            ),

            // ---------- Add Button ----------
            Positioned(
              right: width * 0.04,
              bottom: width * 0.01,
              child: ElevatedButton(
                onPressed: () {
                  showAddBottomSheet(
                    context,
                    currentFirm,
                    initialTab: AddType.product,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallet.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(AssetConstants.add, width: width * 0.05),
                    SizedBox(width: width * 0.008),
                    Text(
                      "Add",
                      style: GoogleFonts.dmSans(
                        color: Pallet.backgroundColor,
                        fontWeight: FontWeight.w600,
                        fontSize: width * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
