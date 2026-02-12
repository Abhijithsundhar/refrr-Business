import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class HireSinglePage extends ConsumerStatefulWidget {
  final AffiliateModel affiliate;
  final LeadsModel? currentFirm;
  const HireSinglePage({
    super.key,
    required this.affiliate,
    this.currentFirm,
  });

  @override
  ConsumerState<HireSinglePage> createState() => _HireSinglePageState();
}

class _HireSinglePageState extends ConsumerState<HireSinglePage> {
  bool isUploading = false;
  final Set<String> hiringInProgress = {};

  Future<void> _hireSingleAffiliate(AffiliateModel affiliate) async {
    try {
      if (widget.currentFirm == null) {
        showCommonSnackbar(context, 'Current firm not found');
        return;
      }

      final String? leadId = widget.currentFirm?.reference?.id;
      if (leadId == null || leadId.isEmpty) {
        showCommonSnackbar(context, 'Invalid firm/lead ID');
        return;
      }

      final String affiliateId = affiliate.reference?.id ?? '';
      if (affiliateId.isEmpty) {
        showCommonSnackbar(context, 'Invalid affiliate ID');
        return;
      }

      // prevent double firing
      if (hiringInProgress.contains(affiliateId)) return;

      // ✅ CHECK TEAM LIMIT AGAIN HERE (before actually hiring)
      final data = widget.currentFirm;
      if (data == null) {
        showCommonSnackbar(context, 'Firm data not found');
        return;
      }

      final currentCount = data.teamMembers.length;
      final teamLimit = int.tryParse(data.teamLimit.toString()) ?? 0;
      final newCount = currentCount + 1;

      if (newCount > teamLimit) {
        showTeamLimitAlert(context, teamLimit);
        return;
      }

      setState(() {
        hiringInProgress.add(affiliateId);
      });

      debugPrint('🚀 Starting hire process for: ${affiliate.name}');

      final result = await ref
          .read(affiliateControllerProvider.notifier)
          .hireAffiliates(
        leadId: leadId,
        affiliates: [affiliate],
        context: context,
      );

      if (!mounted) return;

      setState(() => hiringInProgress.remove(affiliateId));

      if (result['success'] == true) {
        debugPrint('🎉 Successfully hired ${affiliate.name}');
      } else {
        debugPrint('⚠️ Hire failed for ${affiliate.name}');
      }
    } catch (e, stack) {
      debugPrint('❌ Error hiring affiliate: $e\n📋 $stack');
      if (mounted) {
        final affiliateId = affiliate.reference?.id ?? '';
        setState(() => hiringInProgress.remove(affiliateId));
        showCommonSnackbar(context, 'Failed to hire: $e');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final data = widget.currentFirm;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Row(
          children: [
            SizedBox(width: width * .05),
            CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: widget.affiliate.profile.isEmpty
                        ? const NetworkImage(
                      "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg",
                    )
                        : NetworkImage(widget.affiliate.profile),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 18),

                  _profileRow("Name", widget.affiliate.name),
                  _profileRow("Location", widget.affiliate.zone),
                  _profileRow("Phone NO", widget.affiliate.phone),
                  _profileRow("Email ID", widget.affiliate.mailId),
                  _profileRow("Lead Quality",
                      '${widget.affiliate.leadScore!.toInt()}%'),
                  _profileRow(
                      "Total leads added", widget.affiliate.totalLeads.toString()),
                  _profileRow("Industry", widget.affiliate.industry.join('\n')),
                  _profileRow("Qualification", widget.affiliate.qualification),
                  _profileRow(
                      "Experience",
                      widget.affiliate.experience.isNotEmpty
                          ? widget.affiliate.experience
                          : 'NIL'),
                  _profileRow(
                      "More Info",
                      widget.affiliate.moreInfo.isNotEmpty
                          ? widget.affiliate.moreInfo
                          : 'NIL'),

                  const SizedBox(height: 18),

                  // ────── ACTION BUTTONS ──────
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: height * .06,
                        child: ElevatedButton(
                          onPressed: isUploading
                              ? null
                              : () {
                            if (data == null) {
                              showCommonSnackbar(context, 'Firm data not found');
                              return;
                            }

                            final currentCount = data.teamMembers.length;
                            final teamLimit = int.tryParse(data.teamLimit.toString()) ?? 0;
                            final newCount = currentCount + 1; // Adding 1 new member

                            print('currentCount: $currentCount, teamLimit: $teamLimit, newCount: $newCount');

                            // Check if adding this member would exceed the limit
                            if (newCount > teamLimit) {
                              showTeamLimitAlert(context, teamLimit);
                              return;
                            }

                            // Only show confirmation if we have space
                            showCommonAlertBox(
                              context,
                              'Do you want to add this member to your team?',
                                  () async {
                                await _hireSingleAffiliate(widget.affiliate);
                              },
                              'Yes',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Hire',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: width * .045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: height * .06,
                        child: OutlinedButton(
                          onPressed:
                          isUploading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side:
                            const BorderSide(color: Colors.black, width: 1),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Cancel',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: width * .045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: value.contains('\n') || value.length > 40
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          const Text(" : ",
              style: TextStyle(fontSize: 15, color: Colors.black87)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}