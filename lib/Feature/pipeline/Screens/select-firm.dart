import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/alertBox.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/addFirm.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:refrr_admin/models/services-model.dart';

class SelectFirm extends StatelessWidget {
  final LeadsModel? lead;
  final AffiliateModel? affiliate;
  final ServiceModel? service;
  const SelectFirm({super.key, required this.lead, this.affiliate, this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Leads name title
            Padding(
              padding: EdgeInsets.only(left: width * .05, top: height * .02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Firm',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      fontSize: width * .05,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: width * .04),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddFirmScreen()),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: width * .04,
                        child: CircleAvatar(
                          backgroundColor: ColorConstants.primaryColor,
                          radius: width * .035,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: width * .05,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Firm List Container
            Container(
              margin: EdgeInsets.only(top: 30),
              width: double.infinity,
              height: height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              ),
              child: Column(
                children: [
                  SizedBox(height: height * .03),
                  SizedBox(
                    height: height * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            final firm = lead;
                            return Consumer(
                              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                                return GestureDetector(
                                  onTap: () {
                                    showCommonAlertBox(
                                      context,
                                      'Confirm lead submission to ${firm.name??''}',
                                          () async {
                                        // // Create a new Firestore reference
                                        // final docRef = FirebaseFirestore.instance
                                        //     .collection(FirebaseCollections.ServiceLeadsCollection).doc();
                                        // ✅ Create ServiceLeadModel from firm or other data
                                        final serviceLeadModel = ServiceLeadModel(
                                          marketerId:affiliate!.reference!.id,
                                          marketerName:lead?.affiliate??'',
                                          serviceName: service?.name ??'',
                                          reference: null,
                                          createTime: DateTime.now(),
                                          leadScore: 0,
                                          leadName: lead?.name??'',
                                          leadLogo: lead?.logo??'',
                                          leadEmail: lead?.mail??'',
                                          leadContact: int.parse(lead!.contactNo),
                                          location: lead?.zone ??'',
                                          statusHistory: [
                                            {
                                              'date':  DateTime.now(),
                                              'status': 'New Lead',
                                              'added' : lead?.affiliate ?? ''
                                            },
                                          ],
                                          creditedAmount: [
                                            // {
                                            //   'date' : DateTime.now(),
                                            //   'amount' : '0',
                                            //   'added' : lead?.affiliate ?? ''
                                            // }
                                          ],
                                          firmName: '',
                                          leadHandler: [],
                                          chat: [],
                                          type: '' ,
                                        );
                                        ref.read(serviceLeadsControllerProvider.notifier).addServiceLeads(
                                          serviceLeadsModel: serviceLeadModel, context: context,);

                                        int newTotalLeads = affiliate!.totalLeads + 1;
                                        int newQualifiedLeads = affiliate!.qualifiedLeads +
                                            (!["Not Qualified", "Lost"].contains(serviceLeadModel.statusHistory) ? 1 : 0);

                                        double score = (newQualifiedLeads / newTotalLeads) * 100;
                                            int finalScore = score.clamp(0, 100).toInt();

                                           final updateAffiliate = affiliate?.copyWith(
                                             generatedLeads: [  ...(affiliate?.generatedLeads ?? []), // keep old leads
                                               serviceLeadModel, // add new one
                                             ],
                                             totalLeads: newTotalLeads,
                                             qualifiedLeads: newQualifiedLeads,
                                             leadScore: double.parse(finalScore.toString()),);
                                            await ref.read(affiliateControllerProvider.notifier)
                                                .updateAffiliate(affiliateModel: updateAffiliate!, context: context);


                                          },
                                      'Confirm',
                                    );
                                  },
                                  child: buildFirmCard(firm!, index),
                                );
                              },
                            );
                          }
                      ),
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

Widget buildFirmCard(LeadsModel firm, int index) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey, width: 1.2),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Firm Name and Location vertically
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firm.name.toUpperCase(),
              style: GoogleFonts.roboto(
                fontSize: width * .04,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              firm.zone ?? 'Location not available',
              style: GoogleFonts.roboto(
                fontSize: width * .03,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}