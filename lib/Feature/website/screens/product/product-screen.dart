import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/asset.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/website/screens/product/product-details.dart';
import 'package:refrr_admin/Feature/website/screens/firm-person/select-firm.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product-model.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProductsSection extends StatelessWidget {
  final LeadsModel? currentFirm;
  final List<ProductModel> products;
  const ProductsSection(
      {required this.currentFirm, required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.621,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final p = products[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailsScreen(product: p, currentFirm: currentFirm),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Pallet.greyColor.withOpacity(.1),
              border: BoxBorder.all(color: Pallet.greyColor.withOpacity(.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: p.imageUrl ?? '',
                    height: height * 0.15,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(p.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.04)),
                      Text(p.description,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: GoogleFonts.dmSans(
                              color: Pallet.darkGreyColor,
                              fontSize: width * 0.03)),
                      const SizedBox(height: 5),
                      // check if offerPrice is present and valid
                      if (p.offerPrice.toString().isNotEmpty)
                        ...[
                          Text(
                            "${currentFirm?.currency ?? ''} ${p.price}",
                            style: GoogleFonts.dmSans(
                              color: Colors.red,
                              fontSize: width * 0.032,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            "${currentFirm?.currency ?? ''} ${p.offerPrice}",
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.w700,
                              color: Pallet.darkGreyColor,
                            ),
                          ),
                        ]
                      else
                        Padding(
                          padding:  EdgeInsets.only( top: height*.02),
                          child: Text(
                            "${currentFirm?.currency ?? ''} ${p.price}",
                            style: GoogleFonts.dmSans(
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.w700,
                              color: Pallet.darkGreyColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectFirm(
                              lead: currentFirm,
                              product: p,
                            ),
                          ),
                        ),
                        child: Container(
                          height: height * 0.045,
                          width: width * .35,
                          decoration: BoxDecoration(
                            color: Pallet.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AssetConstants.add,
                                  width: width * 0.045),
                              const SizedBox(width: 4),
                              Text("Add Lead",
                                  style: GoogleFonts.dmSans(
                                      color: Pallet.backgroundColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: width * 0.032)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text("Commission: ${p.commission}",
                          style: GoogleFonts.dmSans(
                              color: Pallet.greenColor,
                              fontWeight: FontWeight.w500,
                              fontSize: width * 0.03)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
