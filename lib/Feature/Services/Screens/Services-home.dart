import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Core/common/global variables.dart';
import '../../../Core/common/session-manager.dart';
import '../../../Model/leads-model.dart';
import '../../../Model/services-model.dart';

class ServiceHome extends StatefulWidget {
  final LeadsModel currentFirm;
  const ServiceHome({super.key, required this.currentFirm});

  @override
  State<ServiceHome> createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {
  final TextEditingController searchController = TextEditingController();

  LeadsModel? currentLead;
  List<ServiceModel> firmServices = [];
  List<ServiceModel> filteredServices = [];


  @override
  void initState() {
    super.initState();
    loadLeadData();
  }

  // 🔹 Load the current lead and extract firm services
  Future<void> loadLeadData() async {
    final lead = await SessionManager.getLoggedInLead();
    if (lead != null) {
      final allServices = lead.firms
          .expand((firm) => firm.services!.cast<ServiceModel>())
          .toList();

      setState(() {
        currentLead = lead;
        firmServices = allServices;
        filteredServices = allServices;
      });
    }
  }
  // 🔍 Filter services based on search query
  void onSearch(String keyword) {
    final query = keyword.toLowerCase();
    final result = firmServices.where((service) =>
    service.name.toLowerCase().contains(query) ||
        service.commission.toString().contains(query)
    ).toList();

    setState(() {
      filteredServices = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: currentLead == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: height * .035, left: width * .05, right: width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header (logo and menu)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/refrrTextLogo.png',
                    width: width * .2,
                    height: 50,
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                ],
              ),

              /// Firm Name (Optional header)
              SizedBox(height: height * 0.015),


              /// Search Bar & Add New
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔍 Search Bar
                  Container(
                    height: height * .06,
                    width: width * 0.7,
                    padding: EdgeInsets.symmetric(horizontal: width * .05),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // ➕ Add New Button (does nothing for now)
                  Container(
                    height: height * .048,
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: width * .023),
                        Text(
                          'Add New',
                          style: TextStyle(color: Colors.white, fontSize: width * .023),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              /// Services List
              filteredServices.isEmpty
                  ? const Text("No services found.")
                  : ListView.builder(
                padding: EdgeInsets.only(bottom: height * 0.1),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.01),
                    child: Container(
                      height: 255,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Image (placeholder)
                          Container(
                            height: 157,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            child: service.image.isNotEmpty
                                ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.network(
                                service.image,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),

                          SizedBox(height: height * 0.015),

                          /// Name
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Text(
                              service.name.toUpperCase(),
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF00538E),
                                fontSize: width * .05,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),

                          SizedBox(height: height * 0.01),

                          /// Price Range
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Row(
                              children: [
                                _infoText('Range:'),
                                _infoText(' AED ${service.startingPrice} - ${service.endingPrice}'),
                              ],
                            ),
                          ),

                          /// Commission
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Row(
                              children: [
                                _infoText('Commission:'),
                                Text(
                                  '   ${service.commission}%',
                                  style: GoogleFonts.roboto(
                                    color: Colors.green,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(String text) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: width * .04,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}