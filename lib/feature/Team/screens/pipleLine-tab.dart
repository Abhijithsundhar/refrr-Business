import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/servicelead-color.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class PipelineTab extends ConsumerWidget {
  final AffiliateModel? affiliate;
  final LeadsModel? currentFirm;
  const PipelineTab({super.key, this.affiliate, this.currentFirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliateId = affiliate?.id ?? affiliate?.reference?.id ?? '';
    final firmId = currentFirm?.reference?.id ?? '';

    if (affiliateId.isEmpty || firmId.isEmpty) {
      return Center(
        child: Text(
          'No leads found',
          style: GoogleFonts.dmSans(
            fontSize: width * 0.04,
            color: Pallet.greyColor,
          ),
        ),
      );
    }

    final serviceLeadsAsync = ref.watch(
      affiliateServiceLeadsProvider((affiliateId: affiliateId, firmId: firmId)),
    );

    return serviceLeadsAsync.when(
      data: (serviceLeads) {
        if (serviceLeads.isEmpty) {
          return Center(
            child: Text(
              'No leads found',
              style: GoogleFonts.dmSans(
                fontSize: width * 0.04,
                color: Pallet.greyColor,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(width * 0.02),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: serviceLeads.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: width * 0.03,
            mainAxisSpacing: width * 0.03,
          ),
          itemBuilder: (context, i) {
            final item = serviceLeads[i];

            // ✅ Get current status properly
            final currentStatus = _getCurrentStatus(item.statusHistory);
            final statusColor = getStatusColors(currentStatus);

            return GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor.background,
                  border: Border.all(
                    color: statusColor.border,
                    width: width * .0015,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: height * .008),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER BAND
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * .015,
                        vertical: height * .005,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: statusColor.bigBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * .02,
                          vertical: height * .008,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: width * 0.038,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: width * 0.033,
                                backgroundImage: NetworkImage(
                                  item.leadLogo,
                                ),
                              ),
                            ),
                            SizedBox(width: width * .01),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.firmName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * .029,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: height * .001),
                                  Text(
                                    item.marketerLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * .024,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * .008),

                    /// LEAD TYPE (HOT / WARM / COLD)
                    Container(
                      width: width * .13,
                      height: height * .022,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          _getStatusIcon(item.leadType ?? 'cold'),
                          width: 12,
                          height: 12,
                        ),
                      ),
                    ),

                    SizedBox(height: height * .005),

                    /// TIME
                    Text(
                      _formatDays(item.createTime),
                      style: GoogleFonts.dmSans(
                        fontSize: width * .028,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6E7C87),
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: height * .006),

                    /// SERVICE NAME
                    Text(
                      item.serviceName ?? 'Service',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: width * .038,
                        fontWeight: FontWeight.w700,
                        color: Pallet.blueColor,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: height * .003),

                    /// COMPANY NAME
                    Text(
                      item.leadName ?? '',
                      style: GoogleFonts.dmSans(
                        fontSize: width * .032,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: height * .01),

                    /// STAGE BUTTON
                    Container(
                      height: height * .035,
                      width: width * .28,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: statusColor.border,
                          width: width * .002,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          currentStatus, // ✅ Fixed: Use currentStatus
                          style: GoogleFonts.dmSans(
                            fontSize: width * .028,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * .008),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Failed to load leads',
          style: GoogleFonts.dmSans(
            fontSize: width * 0.04,
            color: Pallet.greyColor,
          ),
        ),
      ),
    );
  }

  // ✅ Get current status from statusHistory list
  String _getCurrentStatus(List<dynamic>? statusHistory) {
    if (statusHistory == null || statusHistory.isEmpty) {
      return 'New';
    }

    final lastStatus = statusHistory.last;

    // If statusHistory contains StatusModel objects
    if (lastStatus is Map<String, dynamic>) {
      return lastStatus['status'] ?? lastStatus['name'] ?? 'New';
    }

    // If statusHistory contains StatusModel with .status property
    // Adjust based on your StatusModel structure
    try {
      return lastStatus.status ?? 'New';
    } catch (e) {
      // If it's just a String
      return lastStatus.toString();
    }
  }

  String _getStatusIcon(String leadType) {
    switch (leadType.toLowerCase()) {
      case 'hot':
        return 'assets/svg/fireimogi.svg';
      case 'warm':
        return 'assets/svg/warmimogi.svg';
      default:
        return 'assets/svg/coldimogi.svg';
    }
  }

  String _formatDays(DateTime? createdAt) {
    if (createdAt == null) return 'Today';
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays} days ago';
  }
}