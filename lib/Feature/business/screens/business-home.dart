import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  int selectedTabIndex = 0;

  final List<ProductModel> products = [
    ProductModel(
      title: 'Espresso Martini',
      subtitle: 'Bold, Smooth, energizing',
      imageUrl:
      'https://images.pexels.com/photos/5531529/pexels-photo-5531529.jpeg',
      oldPrice: 100,
      newPrice: 70,
      commissionPercent: 10,
    ),
    ProductModel(
      title: 'Machine 001',
      subtitle: 'Bold, Smooth, energizing',
      imageUrl:
      'https://images.pexels.com/photos/6000045/pexels-photo-6000045.jpeg',
      oldPrice: 100,
      newPrice: 70,
      commissionPercent: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BusinessAppBar(
        width: width,
        topActionButton: topActionButton,
        titleText: 'Business',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.02),

              /// Segmented control (Products / Services)
              Padding(
                padding: EdgeInsets.only(left: width*.03,right:width*.03),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(0xFF1AE0ED).withOpacity(.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      _segmentItem(
                        label: 'Products',
                        index: 0,
                      ),
                      _segmentItem(
                        label: 'Services',
                        index: 1,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),

              /// Content for selected tab
              if (selectedTabIndex == 0)
                _buildProductsList(height)
              else
                _buildServicesPlaceholder(height),
            ],
          ),
        ),
      ),
    );
  }

  /// Black top-right buttons

  /// Segmented Control Item
  Widget _segmentItem({required String label, required int index}) {
    final selected = selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTabIndex = index);
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? Color(0xFF1AE0ED).withOpacity(.1): Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ?Color(0xFF1AE0ED):Colors.transparent)
          ),
          alignment: Alignment.center,
          child: Text(label,
            style: GoogleFonts.dmSans(
              fontSize: width*.037,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.black : Pallet.darkGreyColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Products horizontal list
  Widget _buildProductsList(double height) {
    return SizedBox(
      height: height * 0.42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }

  /// Placeholder when "Services" is selected
  Widget _buildServicesPlaceholder(double height) {
    return SizedBox(
      height: height * 0.3,
      child: const Center(
        child: Text(
          'No services added yet.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }
}

/// ================== PRODUCT CARD ==================

class ProductModel {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double oldPrice;
  final double newPrice;
  final double commissionPercent;

  ProductModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.oldPrice,
    required this.newPrice,
    required this.commissionPercent,
  });
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cardWidth = width * 0.5;

    return Padding(
      padding: EdgeInsets.only(left: width*.03,right:width*.03),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),

                  /// Subtitle
                  Text(
                    product.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Prices
                  Text(
                    '${product.oldPrice.toStringAsFixed(0)} AED',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.newPrice.toStringAsFixed(0)} AED',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Add Lead button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // handle add lead
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add Lead',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Commission
                  Text(
                    'Commission : ${product.commissionPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF03A84E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}