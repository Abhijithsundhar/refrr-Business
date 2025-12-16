import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global variables.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/addFirm.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/select-firm.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceHome extends StatefulWidget {
  final LeadsModel? currentFirm;
  final AffiliateModel? affiliate;
  const ServiceHome({super.key, required this.currentFirm, this.affiliate});

  @override
  State<ServiceHome> createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios,color: Colors.black,size: width*.06,)),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final servicesAsync = ref.watch(firmServicesProvider(widget.currentFirm!.reference!.id));

          return servicesAsync.when(
            data: (firmServices) {
              if (firmServices.isEmpty) {
                return const Center(child: Text("No services found."));
              }

              // Optional: apply filtering logic
              final filteredServices = firmServices.where((s) {
                // your filter condition
                return true;
              }).toList();

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05, ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Add new lead',style: GoogleFonts.roboto(color: Colors.black,fontWeight: FontWeight.w700, fontSize: width*.05),),
                          Spacer(),
                          GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AddFirmScreen(),));
                              },
                              child: Icon(Icons.add,size: width*.07,color: Colors.black,fontWeight: FontWeight.w700,))
                        ],
                      ),
                      SizedBox(height: height*.02,),
                      // Text('Services',style: GoogleFonts.roboto(color: Colors.black,fontWeight: FontWeight.w500, fontSize: width*.035),),
                      // Services List similar to AddService style
                      ListView.builder(
                        padding: EdgeInsets.only(bottom: height * 0.1),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: height * 0.01),
                            child: Container(
                              height: 270,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image section
                                      Container(
                                        height: 157,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: service.image.isNotEmpty
                                            ? ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          child: service.image.startsWith('http')
                                              ? Image.network(
                                            service.image,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 157,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                              );
                                            },
                                          )
                                              : Image.file(
                                            File(service.image),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 157,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                              );
                                            },
                                          ),
                                        )
                                            : const Center(
                                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                                        ),
                                      ),

                                      // Details Section
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.012),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Service Name (limit 17 characters)
                                            Text(
                                              service.name.length > 17
                                                  ? '${service.name.toUpperCase().substring(0, 17)}...'
                                                  : service.name.toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.roboto(
                                                color: const Color(0xFF00538E),
                                                fontSize: width * 0.045,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.012),

                                            // Price Range
                                            Row(
                                              children: [
                                                Text('Range :', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: width * 0.035)),
                                                Text(' AED ${service.startingPrice} - ${service.endingPrice}', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: width * 0.035)),
                                              ],
                                            ),
                                            SizedBox(height: height * 0.005),

                                            // Commission
                                            Row(
                                              children: [
                                                Text('Commission :', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: width * 0.035)),
                                                Text(' ${service.commission}%'.toUpperCase(), style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.w500, fontSize: width * 0.035)),
                                              ],
                                            ),
                                            SizedBox(height: height * 0.005),

                                            // Leads Given - example static value
                                            Row(
                                              children: [
                                                Text('Lead Given :', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: width * 0.035)),
                                                Text(service.leadsGiven.toString(), style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: width * 0.035)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Positioned "Lead" Button on top right
                                  Positioned(
                                    top: height * 0.28,
                                    left: width * 0.56,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                            SelectFirm(lead: widget.currentFirm,affiliate:widget.affiliate,service: service,),));
                                      },
                                      child: Container(
                                        height: height * 0.05,
                                        width: width * 0.32,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.black),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: width * 0.07),
                                            CircleAvatar(
                                              radius: width * 0.025,
                                              backgroundColor: Colors.grey.shade300,
                                              child: Icon(Icons.add, color: Colors.white, size: width * 0.05),
                                            ),
                                            SizedBox(width: width * 0.02),
                                            Text(
                                              'Lead',
                                              style: GoogleFonts.roboto(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: width * 0.035,
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
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          );
        },
      ));
  }
}