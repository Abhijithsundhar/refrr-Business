import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/colorconstnats.dart';
import 'package:refrr_admin/core/constants/sized_boxes.dart';
import 'package:refrr_admin/feature/login/Controller/lead_controller.dart';
import 'package:refrr_admin/feature/website/screens/firm_person/select_firm.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/product_model.dart';


class ProductsTile extends ConsumerWidget {
  final ProductModel? productModel;
  final LeadsModel? lead;
  final String? leadId;
  const ProductsTile(
      {super.key,
        required this.productModel,
        required this.lead,
        this.leadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CASE 1: lead already passed
    if (lead != null) {
      return _buildUI(context, lead!);
    }

    // CASE 2: fetch using leadId
    if (leadId == null) {
      return _buildUI(context, null);
    }

    final leadAsync = ref.watch(leadByIdProvider(leadId!));

    return leadAsync.when(
      data: (fetchedLead) => _buildUI(context, fetchedLead),
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox(), // or Error widget
    );
  }

  Widget _buildUI(BuildContext context, LeadsModel? lead) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: height * 0.15,
              width: double.infinity,
              child: Image.network(
                productModel?.imageUrl??'',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("error image loading -$error");
                  return const Center(child: Icon(Icons.error));
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  productModel?.name??'',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  productModel?.description??'',
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Column(
                  children: [
                    Text(
                      "${lead?.currency ?? ''} ${productModel?.price}",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${lead?.currency ?? ''} ${productModel?.offerPrice}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    AppSpacing.h001
                  ],
                ),
                SizedBox(
                  width: width * 0.3,
                  height: 33,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (lead == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content:
                              Text("No lead associated with this view")),
                        );
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SelectFirm(
                                lead: lead,
                                product: productModel,
                                service: null,
                              )));
                    },
                    icon: const Icon(Icons.add, size: 14, color: Colors.white),
                    label: const Text("Add Lead",
                        style: TextStyle(fontSize: 11, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        elevation: 0
                    ),

                  ),
                ),
                AppSpacing.h01,
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "Commission :",
                        style: TextStyle(color: Colors.grey[600]), // Grey
                      ),
                      TextSpan(
                        text: " ${productModel?.commission}%",
                        style: TextStyle(color: Colors.green), // Green
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
