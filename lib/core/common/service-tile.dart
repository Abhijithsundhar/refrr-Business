import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/constants/sizedboxes.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/website/screens/firm-person/select-firm.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services-model.dart';


class ServicesTile extends ConsumerWidget {
  final ServiceModel serviceModel;
  final LeadsModel? lead;
  final AffiliateModel affiliate;
  final String? leadId;

  const ServicesTile(
      {super.key,
        required this.serviceModel,
        this.lead,
        required this.affiliate,
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
      error: (e, _) => const SizedBox(),
    );
  }

  Widget _buildUI(BuildContext context, LeadsModel? lead) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              serviceModel.image,
              height: height * 0.2,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: height * 0.2,
                  width: double.infinity,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height * 0.2,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceModel.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  serviceModel.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                AppSpacing.h001,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${lead?.currency ?? ""} ${serviceModel.startingPrice} - ${serviceModel.endingPrice}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (lead == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text("No lead associated with this view")),
                          );
                          return;
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SelectFirm(
                                  lead: lead,
                                  affiliate: affiliate,
                                  service: serviceModel,
                                  product: null,
                                )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                      ),
                      child: const Text("Enquire Now",
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
