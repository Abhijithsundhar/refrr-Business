import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-appBar.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/constants/sizedboxes.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/website/screens/product/edit-product.dart';
import 'package:refrr_admin/Feature/website/screens/firm-person/select-firm.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product-model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel? product;
  final LeadsModel? currentFirm;
  const ProductDetailsScreen({super.key, this.product, required this.currentFirm});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {

  Future<void> handleDeleteProduct() async {
    try {
      final productRef = widget.product?.reference;

      if (productRef == null) {
        showCommonSnackbar(context, 'Invalid product reference');
        return;
      }

      // Delete the whole Firestore document directly
      await productRef.delete();

      if (mounted) {
        Navigator.pop(context); // close alert dialog
        Navigator.pop(context); // pop Edit screen
        showCommonSnackbar(context, 'Product deleted successfully');
      }
    } catch (e) {
      showCommonSnackbar(context, 'Delete failed: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      appBar: CustomAppBar(title: 'Product Details'),

      // ------------------ SCROLLABLE BODY ------------------
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: width * 0.25, // leave space for fixed button
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: width * 0.02),

            // PRODUCT IMAGE
            Padding(
              padding: EdgeInsets.all(width * 0.03),
              child: SizedBox(
                width: width,
                height: height * 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(width * 0.05),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: product?.imageUrl ?? '',
                  ),
                ),
              ),
            ),

            // PRODUCT NAME + EDIT ICON
            Padding(
              padding: EdgeInsets.only(left: width * 0.03, right: width * 0.03),
              child: Text(
                product?.name ?? '',
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // DESCRIPTION
            Padding(
              padding: EdgeInsets.only(left: width * 0.03, right: width * 0.03),
              child: Text(
                product?.description ?? '',
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.03,
                  fontWeight: FontWeight.w300,
                  color: Pallet.darkGreyColor,
                ),
              ),
            ),

            // PRICE + OFFER PRICE
            Padding(
              padding: EdgeInsets.only(
                top: height * .02,
                left: width * 0.03,
                right: width * 0.03,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: width * 0.03,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
                child: Row(
                  children: [
                    // Regular price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Price",
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.03,
                              color: Pallet.greyColor,
                            ),
                          ),
                          Text(
                            "${widget.currentFirm?.currency ?? ''} ${product?.price ?? ''}",
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Offer price only if present
                    if (product?.offerPrice != null &&
                        product!.offerPrice.toString().isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Offer Price",
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.03,
                                color: Pallet.greyColor,
                              ),
                            ),
                            Text(
                              "${widget.currentFirm?.currency ?? ''} ${product.offerPrice}",
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // COMMISSION
            Padding(
              padding: EdgeInsets.only(
                top: height * .02,
                left: width * 0.03,
                right: width * 0.03,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: width * 0.03,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Commission",
                        style: GoogleFonts.dmSans(
                          fontSize: width * 0.036,
                          color: Pallet.greyColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      product?.commission ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: width * 0.04,
                        color: Pallet.greenColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.h01,
            Padding(
              padding: EdgeInsets.only(left: width*.03),
              child: Text('Features',
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // BULLET LIST
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(product?.keyPoints ?? [])
                      .map((point) => BulletPoint(text: point)),
                ],
              ),
            ),
          ],
        ),
      ),

      // ------------------ FIXED ADD LEAD BUTTON ------------------
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        decoration: BoxDecoration(
          color: Pallet.backgroundColor,
        ),
        child: Row(
          children: [
            // DELETE BUTTON
            GestureDetector(
              onTap: (){
                commonAlert(context, 'Delete Product','Are you sure want to Delete this Product?', 'Yes', (){
                  handleDeleteProduct();
                });
              },
              child: Container(
                height: height * 0.06,
                width: width * 0.13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallet.borderColor),
                  color: Colors.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/deleteRed.svg',
                    width: width * 0.07,
                  ),
                ),),
            ),
            AppSpacing.w02,

            // EDIT BUTTON
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProductScreen(product: product,currentFirm: widget.currentFirm,),));
              },
              child: Container(
                height: height * 0.06,
                width: width * 0.13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Pallet.borderColor),
                  color: Colors.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AssetConstants.edit,
                    width: width * 0.07,
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.04),

            // ADD LEAD BUTTON
            Expanded(
              child: SizedBox(
                height: height * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectFirm(
                          lead: widget.currentFirm,
                          product: widget.product,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AssetConstants.add,
                        width: width * 0.045,
                        color: Colors.white,
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        "Add Lead",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ BULLET POINT WIDGET ------------------
class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.005),
      child: Row(
        children: [
          SizedBox(width: width * 0.015),
          SvgPicture.asset(
            'assets/svg/star.svg',
            width: width * 0.035,
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: width * 0.033,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
