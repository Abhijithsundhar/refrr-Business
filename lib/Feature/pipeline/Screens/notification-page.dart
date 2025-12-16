import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class NotificationPage extends StatelessWidget {
  final LeadsModel? currentFirm;
  const NotificationPage({super.key, this.currentFirm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Text(
          "Notification",
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer(builder: (context, ref, child) {
        final applications = ref.watch(applicationsProvider(currentFirm!.reference!.id));
        return applications.when(data: (data){
          if (data.isEmpty) {
            return Center(
              child: Text("No new notifications",
                style: GoogleFonts.urbanist(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final app = data[index];
              return _applicationCard(
                name: app.name,
                imageUrl: app.profile,
                index: index,
                applications: data, // ✅ pass the latest data list
                ref: ref,           // ✅ pass the provider ref
                currentFirm: currentFirm!,
              );
            },
          );
        },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),);

      },)
    );
  }

  Widget _applicationCard({
    required String name,
    required String imageUrl,
    required int index,
    required List<AffiliateModel> applications,
    required WidgetRef ref,
    required LeadsModel currentFirm,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "He interested to join with us",
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Consumer(builder: (context, ref, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showCommonAlertBox(
                              context,
                              'Do you want to accept this application?',
                                  () async {
                                try {
                                  // ✅ Defensive check
                                  if (currentFirm == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Firm not found')),
                                    );
                                    return;
                                  }

                                  final app = List<AffiliateModel>.from(applications);
                                  if (app.isEmpty || index < 0 || index >= app.length) {
                                    print('000000000000000000');
                                    print(index);
                                    print('0000000000000000000');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invalid application index')),
                                    );
                                    return;
                                  }

                                  // ✅ Create new copies
                                  final updatedApplications = List<AffiliateModel>.from(applications);
                                  final updatedTeamMembers = List<AffiliateModel>.from(currentFirm.teamMembers);

                                  // ✅ Get the selected applicant
                                  final acceptedApplicant = updatedApplications[index];

                                  // ✅ Remove from applications
                                  updatedApplications.removeAt(index);

                                  // ✅ Add to teamMembers
                                  updatedTeamMembers.add(acceptedApplicant);

                                  // ✅ Create updated Lead model
                                  final updatedLead = currentFirm.copyWith(
                                    applications: updatedApplications,
                                    teamMembers: updatedTeamMembers,
                                  );

                                  // ✅ Prepare firm details to add to affiliate
                                  final updateFirm = LeadsModel(
                                    logo: currentFirm.logo,
                                    name: currentFirm.name,
                                    industry: currentFirm.industry,
                                    contactNo: currentFirm.contactNo,
                                    mail: currentFirm.mail,
                                    country: currentFirm.country,
                                    zone: currentFirm.zone,
                                    website: currentFirm.website,
                                    currency: currentFirm.currency,
                                    address: currentFirm.address,
                                    aboutFirm: currentFirm.aboutFirm,
                                    delete: currentFirm.delete,
                                    search: currentFirm.search,
                                    createTime: currentFirm.createTime,
                                    addedBy: currentFirm.addedBy,
                                    services: currentFirm.services,
                                    status: currentFirm.status,
                                    affiliate: currentFirm.affiliate,
                                    password: currentFirm.password,
                                    organizationType: currentFirm.organizationType,
                                    teamMembers: currentFirm.teamMembers,
                                    applications: currentFirm.applications,
                                    jobType: currentFirm.jobType,
                                    lookingAt: currentFirm.lookingAt,
                                    reference: currentFirm.reference,
                                  );

                                  // ✅ Update affiliate’s workingFirms
                                  final updatedAffiliate = acceptedApplicant.copyWith(
                                    workingFirms: [...acceptedApplicant.workingFirms, updateFirm],
                                    reference: acceptedApplicant.reference,
                                  );

                                  print('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');
                                  print(updateFirm);
                                  print(updateFirm.name);
                                  print(updateFirm.reference);

                                  print(acceptedApplicant);
                                  print(acceptedApplicant.name);
                                  print(acceptedApplicant.reference);
                                  print('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');

                                  await ref.read(leadControllerProvider.notifier)
                                      .updateLead(leadModel: updatedLead, context: context);

                                  await ref.read(affiliateControllerProvider.notifier)
                                      .updateAffiliate(affiliateModel: updatedAffiliate, context: context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error accepting application: $e')),
                                  );
                                }
                              },
                              'Yes',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            "Confirm",
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showCommonAlertBox(
                              context,
                              'Do you want to reject this application?',
                                  () async {
                                try {
                                  // Defensive check before proceeding
                                  if (currentFirm == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Firm not found')),
                                    );
                                    return;
                                  }

                                  final app = List<AffiliateModel>.from(applications);
                                  if (app.isEmpty || index < 0 || index >= app.length) {
                                    print('000000000000000000');
                                    print(index);
                                    print('0000000000000000000');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invalid application index')),
                                    );
                                    return;
                                  }

                                  // Create a new immutable copy of the list
                                  final updatedApplications = List<AffiliateModel>.from(app)
                                    ..removeAt(index);

                                  // Create the updated Lead model
                                  final updatedLead = currentFirm.copyWith(applications: updatedApplications);

                                  // Show progress message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Rejecting application...')),
                                  );

                                  // Update via controller
                                  await ref.read(leadControllerProvider.notifier)
                                      .updateLead(leadModel: updatedLead, context: context);

                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error rejecting application: $e')),
                                  );
                                }
                              },
                              'Yes',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            "Reject",
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },)
                
              ],
            ),
          )
        ],
      ),
    );
  }
}
