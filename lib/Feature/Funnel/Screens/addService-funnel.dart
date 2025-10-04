import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Services/Screens/add-service.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/services-model.dart';

class ServiceHome extends StatefulWidget {
  final LeadsModel? currentFirm;
  const ServiceHome({super.key, required this.currentFirm});

  @override
  State<ServiceHome> createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {
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
    setState(() {
      firmServices = services;
      filteredServices = services;
    });
  }

  void onSearch(String keyword) {
    final query = keyword.toLowerCase();
    final result = firmServices.where((service) =>
    service.name.toLowerCase().contains(query) ||
        service.commission.toString().contains(query)).toList();

    setState(() {
      filteredServices = result;
    });
  }

  // Method to handle navigation with proper error handling
  void _navigateToAddService() async {
    try {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
          AddNewServicePage(currentFirm: widget.currentFirm,),),);

      // If a new service was added, refresh the list
      if (result == true) {
        initServices();
      }
    } catch (e) {
      // Handle navigation errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening add service page: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          widget.currentFirm?.name ?? 'Services',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: width * 0.05,
          ),
        ),
        actions: [
          GestureDetector(
              onTap: _navigateToAddService,
              child: Icon(Icons.add, color: Colors.black)
          ),
          SizedBox(width: width*.02,),
          Icon(Icons.menu, color: Colors.black),
          SizedBox(width: width*.02,),
        ],
      ),
      body: firmServices.isEmpty
          ? const Center(child: Text("No services found."))
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                                        Text(' 20', style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: width * 0.035)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Positioned "Lead" Button on top right
                          Positioned(
                            top: height * 0.3,
                            left: width * 0.56,
                            child: GestureDetector(
                              onTap: () {

                              },
                              child: Container(
                                height: height * 0.05,
                                width: width * 0.32,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: width * 0.07),
                                    CircleAvatar(
                                      radius: width * 0.025,
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.add, color: Colors.white, size: width * 0.05),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      'Lead',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
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
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}