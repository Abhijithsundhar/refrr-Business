import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
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

  String _affId(AffiliateModel a) {
    final id = a.id?.toString();
    if (id != null && id.isNotEmpty) return id;
    return '${a.name}|${a.zone}|${a.profile}';
  }

  List<AffiliateModel> _mergeUnique(
      List<AffiliateModel> a,
      List<AffiliateModel> b,
      ) {
    final map = <String, AffiliateModel>{};
    for (final x in a) map[_affId(x)] = x;
    for (final x in b) map[_affId(x)] = x;
    return map.values.toList();
  }

  Future<void> _hireSingle(BuildContext context) async {
    try {
      setState(() => isUploading = true);

      final baseTeam = List<AffiliateModel>.from(
        widget.currentFirm!.teamMembers ?? const <AffiliateModel>[],
      );

      final newId = _affId(widget.affiliate);
      final alreadyInTeam = baseTeam.any((m) => _affId(m) == newId);

      if (alreadyInTeam) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This member is already in your team.')),
          );
          Navigator.pop(context, false);
        }
        return;
      }
      final merged = _mergeUnique(baseTeam, [widget.affiliate]);
      final updatedLead = widget.currentFirm!.copyWith(teamMembers: merged);

      await ref.read(leadControllerProvider.notifier)
          .updateLead(context: context, leadModel: updatedLead);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added to your team.')),
        );
        Navigator.pop(context, true);
      }

      final currentFirm = widget.currentFirm;
      if (currentFirm != null) {
        final existingFirms = List<LeadsModel>.from(widget.affiliate.workingFirms);
        if (!existingFirms.any((f) => f.name == currentFirm.name)) {
          existingFirms.add(currentFirm);
        }

        final updatedAffiliate = widget.affiliate.copyWith(
          workingFirms: existingFirms,
        );

        await ref
            .read(affiliateControllerProvider.notifier)
            .updateAffiliate(context: context, affiliateModel: updatedAffiliate);
      }


    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to hire: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Profile image
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

                  // Details
                  _profileRow("Name", widget.affiliate.name),
                  _profileRow("Location", widget.affiliate.zone),
                  _profileRow("Phone NO", widget.affiliate.phone),
                  _profileRow("Email ID", widget.affiliate.mailId),
                  _profileRow("Lead Quality", '${widget.affiliate.leadScore!.toInt().toString()}%'),
                  _profileRow("Total leads added", widget.affiliate.totalLeads.toString()),
                  _profileRow("Industry", widget.affiliate.industry.join('\n')),
                  _profileRow("Qualification", widget.affiliate.qualification),
                  _profileRow("Experience", widget.affiliate.experience),
                  _profileRow("More Info",widget.affiliate.moreInfo ,
                  ),

                  const SizedBox(height: 18),

                  // Two action buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: height * .06,
                        child: ElevatedButton.icon(
                          onPressed: isUploading
                              ? null
                              : () {
                            showCommonAlertBox(
                              context,
                              'Do you want to add this member to your team?',
                                  () async {
                                await _hireSingle(context);
                              },
                              'Yes',
                            );
                          },
                          icon: const SizedBox.shrink(),
                          label: Text(
                            'Hire',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: width * .045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: height * .06,
                        child: OutlinedButton.icon(
                          onPressed: isUploading ? null : () => Navigator.pop(context),
                          icon: const SizedBox.shrink(),
                          label: Text(
                            'Cancel',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: width * .045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 1),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(
            " : ",
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}