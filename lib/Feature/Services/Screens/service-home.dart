import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global variables.dart';
import 'package:refrr_admin/Feature/Services/Screens/add-offer.dart';
import 'package:refrr_admin/Feature/Services/Screens/add-service.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services-model.dart';

class ServiceListScreenHome extends StatefulWidget {
  final LeadsModel? currentFirm;
  const ServiceListScreenHome({super.key, required this.currentFirm});

  @override
  State<ServiceListScreenHome> createState() => _ServiceListScreenHomeState();
}

class _ServiceListScreenHomeState extends State<ServiceListScreenHome> {
  final TextEditingController searchController = TextEditingController();
  List<ServiceModel> firmServices = [];
  List<ServiceModel> filteredServices = [];

  @override
  void initState() {
    super.initState();
    initServices();
  }

  void initServices() {
    // Extract all services for the current firm from all its firms
    final List<ServiceModel> services = [];
    if (widget.currentFirm?.firms != null) {
      for (var firm in widget.currentFirm!.firms) {
        if (firm.services != null) {
          services.addAll(firm.services!);
        }
      }
    }

    // Show newest first: assuming new items are appended to the end
    final List<ServiceModel> ordered = services.reversed.toList();

    setState(() {
      firmServices = ordered;
      filteredServices = List<ServiceModel>.from(ordered);
    });
  }

  void _applyFilter(String keyword) {
    final query = keyword.toLowerCase();
    filteredServices = firmServices
        .where((service) =>
    service.name.toLowerCase().contains(query) ||
        service.commission.toString().contains(query))
        .toList();
  }

  void onSearch(String keyword) {
    setState(() {
      _applyFilter(keyword);
    });
  }

  // Future<void> _openAddService() async {
  //   final result = await
  //
  //   if (!mounted) return;
  //
  //   // If AddNewServicePage returns the created ServiceModel, insert it at the top
  //   if (result is ServiceModel) {
  //     setState(() {
  //       firmServices.insert(0, result);
  //       _applyFilter(searchController.text);
  //     });
  //   } else if (result == true) {
  //     // If it returns a boolean flag, just refresh the list
  //     initServices();
  //   } else {
  //     // If result is null or anything else, still safe to refresh
  //     initServices();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              widget.currentFirm?.name ?? '',
              style: GoogleFonts.bebasNeue(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: width * .055,
              ),
            ),
            actions: [
              Icon(Icons.search),
              SizedBox(width: width * .02),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddNewServicePage(currentFirm: widget.currentFirm),
                      ),
                    );
                    }, child: Icon(Icons.add)),
              SizedBox(width: width * .02),
              Icon(Icons.menu),
              SizedBox(width: width * .03),
            ],
          ),
          body: firmServices.isEmpty
              ? const Center(child: Text("No services found."))
              : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * .015),
                  // Heading before list
                  Text(
                    'Products and Services',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: width * .048,
                    ),
                  ),
                  // Services List
                  SizedBox(height: height * .015),
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: height * 0.1),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: height * 0.01),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Image section
                                  Container(
                                    height: 157,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius:
                                      const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: service.image.isNotEmpty
                                        ? ClipRRect(
                                      borderRadius:
                                      const BorderRadius.only(
                                        topLeft:
                                        Radius.circular(8),
                                        topRight:
                                        Radius.circular(8),
                                      ),
                                      child: service.image
                                          .startsWith('http')
                                          ? Image.network(
                                        service.image,
                                        fit: BoxFit.cover,
                                        width:
                                        double.infinity,
                                        height: 157,
                                        errorBuilder: (context,
                                            error,
                                            stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons
                                                  .broken_image,
                                              size: 50,
                                              color:
                                              Colors.grey,
                                            ),
                                          );
                                        },
                                      )
                                          : Image.file(
                                        File(service.image),
                                        fit: BoxFit.cover,
                                        width:
                                        double.infinity,
                                        height: 157,
                                        errorBuilder: (context,
                                            error,
                                            stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons
                                                  .broken_image,
                                              size: 50,
                                              color:
                                              Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                        : const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  // Details Section
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03,
                                      vertical: height * 0.012,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // Service Name (limit 17 characters)
                                        Text(
                                          service.name.length > 17
                                              ? '${service.name.toUpperCase().substring(0, 17)}...'
                                              : service.name
                                              .toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.roboto(
                                            color:
                                            const Color(0xFF00538E),
                                            fontSize: width * 0.045,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                            height: height * 0.012),

                                        // Price Range
                                        Row(
                                          children: [
                                            Text(
                                              'Range :',
                                              style: GoogleFonts.roboto(
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize:
                                                width * 0.035,
                                              ),
                                            ),
                                            Text(
                                              ' AED ${service.startingPrice} - ${service.endingPrice}',
                                              style: GoogleFonts.roboto(
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize:
                                                width * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: height * 0.005),

                                        // Commission
                                        Row(
                                          children: [
                                            Text(
                                              'Commission :',
                                              style: GoogleFonts.roboto(
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize:
                                                width * 0.035,
                                              ),
                                            ),
                                            Text(
                                              ' ${service.commission}%'
                                                  .toUpperCase(),
                                              style: GoogleFonts.roboto(
                                                color: Colors.green,
                                                fontWeight:
                                                FontWeight.w500,
                                                fontSize:
                                                width * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: height * 0.005),

                                        // Removed: 'Lead Given' row
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Removed: Positioned "Lead" Button
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: height * .84,
          left: width * .71,
          child: GestureDetector(
            onTap: () {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddOffer(currentFirm: widget.currentFirm),
                ),
              );
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: width * .025,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: width * .022,
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: width * .035,
                      ),
                    ),
                  ),
                  SizedBox(width: width * .01),
                  Text(
                    'Offer',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: width * .035,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}