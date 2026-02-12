import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/color-constnats.dart';
import 'package:refrr_admin/Core/constants/homepage-functions.dart';
import 'package:refrr_admin/Core/constants/servicelead-color.dart';
import 'package:refrr_admin/Core/theme/pallet.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/pipeline/lead-card-ui.dart';
import 'package:refrr_admin/models/city-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CityPipeline extends StatefulWidget {
  final LeadsModel? currentFirm;
  final CityModel? city;
  final List<ServiceLeadModel>? serviceLeads;

  const CityPipeline({super.key, required this.currentFirm, required this.serviceLeads, this.city});

  @override
  State<CityPipeline> createState() => _CityPipelineState();
}

class _CityPipelineState extends State<CityPipeline> {
  int selectedTab = 0;
  String? selectedStatus;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedMarketer;
  String searchQuery = '';
  int selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ Get latest status from lead
  String _getLatestStatus(ServiceLeadModel lead) {
    if (lead.statusHistory.isNotEmpty) {
      final Map<String, dynamic> lastStatus = lead.statusHistory.last;
      return lastStatus['status']?.toString() ?? 'New Lead';
    }
    return 'New Lead';
  }

  /// ✅ Get status colors based on status
  StatusColors _getStatusColors(String status) {
    return getStatusColors(status);
  }

  /// ✅ Filtered leads getter - NOW WITH ZONE FILTER
  List<ServiceLeadModel> get filteredLeads {
    List<ServiceLeadModel> result = widget.serviceLeads ?? [];

    // ✅ Filter leads where (firm name == leadName) AND (city.zone == marketerLocation)
    result = result.where((lead) {
      final firmName = widget.currentFirm?.name.toLowerCase().trim() ?? '';
      final leadName = lead.leadName.toLowerCase().trim();
      final cityZone = widget.city?.zone.toLowerCase().trim() ?? '';
      final marketerLocation = lead.marketerLocation.toLowerCase().trim();

      return leadName == firmName && marketerLocation == cityZone;
    }).toList();

    // ✅ Apply additional filters (status, period, marketer)
    if (selectedStatus != null) {
      result = result.where((lead) {
        final latestStatus = _getLatestStatus(lead);
        return latestStatus.toLowerCase() == selectedStatus!.toLowerCase();
      }).toList();
    }

    if (fromDate != null && toDate != null) {
      result = result.where((lead) {
        final leadDate = lead.createTime;
        return leadDate.isAfter(fromDate!) &&
            leadDate.isBefore(toDate!.add(const Duration(days: 1)));
      }).toList();
    }

    if (selectedMarketer != null) {
      result = result.where((lead) => lead.marketerName == selectedMarketer).toList();
    }

    return result;
  }

  void _pickDateRange() async {
    if (!mounted) return;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  Future<void> selectStatus() async {
    if (!mounted) return;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lead status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(bottomSheetContext).pop(),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: statusOptions.map((status) {
                    final colors = getStatusColors(status); // your helper for pastel colors
                    final bool selected = selectedStatus == status;
                    return GestureDetector(
                      onTap: () => Navigator.of(bottomSheetContext).pop(status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 18,
                        ),
                        decoration: BoxDecoration(
                          color: colors.bigBackground,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: colors.bigBackground,
                          ),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5E5E5E),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (result != null) {
      setState(() => selectedStatus = result);
    }
  }

  void _selectMarketer() async {
    if (!mounted) return;
    final Size size = MediaQuery.sizeOf(context);
    final double width = size.width;
    final double height = size.height;

    // ✅ Get marketers only from filtered zone leads
    final filteredZoneLeads = (widget.serviceLeads ?? []).where((lead) {
      if (widget.city == null) return true;
      return lead.marketerLocation.toLowerCase().trim() == widget.city!.zone.toLowerCase().trim();
    }).toList();

    final marketers = filteredZoneLeads
        .map((e) => e.marketerName)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: width * 0.05,
            right: width * 0.05,
            top: height * 0.02,
          ),
          child: SizedBox(
            height: height * 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select marketer',
                      style: GoogleFonts.roboto(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: width * 0.07),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: marketers.isEmpty
                      ? Center(
                    child: Text(
                      'No marketers available in this city',
                      style: GoogleFonts.roboto(
                        fontSize: width * 0.04,
                        color: Pallet.greyColor,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: marketers.length,
                    itemBuilder: (context, index) {
                      final marketer = marketers[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: width * 0.03,
                          left: width * 0.03,
                          bottom: height * 0.01,
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            if (mounted) {
                              setState(() => selectedMarketer = marketer);
                            }
                            Navigator.of(bottomSheetContext).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F3F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            side: BorderSide(
                              color: const Color(0xFF828282),
                              width: width * 0.001,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              marketer,
                              style: GoogleFonts.roboto(
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> getFilterBox() {
    return [
      {
        'title': 'All',
        'onTap': () {
          if (mounted) {
            setState(() {
              selectedMarketer = null;
              selectedStatus = null;
              fromDate = null;
              toDate = null;
              searchQuery = '';
              selectedIndex = 0;
              _searchController.clear();
            });
          }
        },
        'isSelected': selectedMarketer == null &&
            selectedStatus == null &&
            fromDate == null &&
            toDate == null &&
            searchQuery.isEmpty,
      },
      {
        'title': selectedStatus ?? 'Status',
        'onTap': selectStatus,
        'isSelected': selectedStatus != null,
      },
      {
        'title': fromDate != null && toDate != null
            ? "${DateFormat('dd/MM/yy').format(fromDate!)} - ${DateFormat('dd/MM/yy').format(toDate!)}"
            : 'Period',
        'onTap': _pickDateRange,
        'isSelected': fromDate != null && toDate != null,
      },
      {
        'title': selectedMarketer ?? 'Marketer',
        'onTap': _selectMarketer,
        'isSelected': selectedMarketer != null,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final boxData = getFilterBox();
    final leads = filteredLeads;
    return Scaffold(
      backgroundColor: Pallet.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Growth Pipeline",
                style: GoogleFonts.dmSans(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: width * 0.06,
                ),
              ),
              SizedBox(height: width * 0.03),

              /// ========== FILTER BUTTONS ==========
              _buildFilterButtons(boxData, width, height),

              SizedBox(height: width * 0.03),

              /// ========== LEADS GRID ==========
              if (selectedTab == 0) _buildLeadsGrid(leads, width, height),
            ],
          ),
        ),
      ),
    );
  }

  /// ========== LEADS GRID ==========
  Widget _buildLeadsGrid(
      List<ServiceLeadModel> leads,
      double width,
      double height,
      ) {
    // Handle empty state
    if (leads.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.1),
          child: Column(
            children: [
              Text(
                widget.city != null
                    ? 'No leads found in ${widget.city!.zone}'
                    : 'No leads found',
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.04,
                  color: Pallet.greyColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: width * 0.02),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leads.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: width * 0.015,
        mainAxisSpacing: width * 0.015,
      ),
      itemBuilder: (context, index) {
        final ServiceLeadModel lead = leads[index];
        final String latestStatus = _getLatestStatus(lead);
        final StatusColors statusColors = _getStatusColors(latestStatus);
        final LeadsModel? currentFirm = widget.currentFirm;

        return buildLeadCard(
          lead,
          statusColors,
          latestStatus,
          currentFirm,
          width,
          height,
        );
      },
    );
  }

  /// ========== FILTER BUTTONS WIDGET ==========
  Widget _buildFilterButtons(
      List<Map<String, dynamic>> boxData,
      double width,
      double height,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: boxData.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          bool isSelected = index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(
              right: index < boxData.length - 1 ? width * 0.015 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
                if (item['onTap'] != null) item['onTap']();
              },
              child: Container(
                width: width * 0.2,
                height: height * 0.04,
                decoration: BoxDecoration(
                  color: isSelected ? const Color.fromRGBO(26, 224, 237, 0.1) : Colors.white,
                  border: Border.all(
                    width: width * 0.0014,
                    color: isSelected
                        ? ColorConstants.primaryColor
                        : Pallet.greyColor.withOpacity(.3),
                  ),
                  borderRadius: BorderRadius.circular(width * 0.06),
                ),
                child: Center(
                  child: Text(
                    item['title'],
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: width * 0.032,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : Pallet.darkGreyColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ========== BUILD LEAD CARD ==========
  Widget buildLeadCard(
      ServiceLeadModel item,
      StatusColors statusColors,
      String latestStatus,
      LeadsModel? currentFirm,
      double width,
      double height,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: statusColors.bigBackground,
        border: Border.all(color: statusColors.border, width: width * 0.0015),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(vertical: height * 0.008),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HEADER BAND
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.015,
              vertical: height * 0.01,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: statusColors.background,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                vertical: height * 0.008,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.038,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: width * 0.033,
                      backgroundImage: item.leadLogo.isEmpty
                          ? const AssetImage('assets/image.png')
                          : CachedNetworkImageProvider(item.leadLogo) as ImageProvider,
                    ),
                  ),
                  SizedBox(width: width * 0.01),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.marketerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.029,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: height * 0.001),
                        Text(
                          item.marketerLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: width * 0.024,
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

          SizedBox(height: height * 0.008),

          /// TYPE (Warm / Hot / Cool)
          Container(
            width: width * 0.13,
            height: height * 0.022,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/warmimogi.svg',
                    width: 9,
                    height: 9,
                  ),
                  SizedBox(width: width * 0.005),
                  Text(
                    'Warm',
                    style: GoogleFonts.dmSans(
                      fontSize: width * 0.024,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: height * 0.005),

          /// TIME
          Text(
            getTimeAgo(item.createTime),
            style: GoogleFonts.dmSans(
              fontSize: width * 0.028,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6E7C87),
              height: 1.2,
            ),
          ),

          SizedBox(height: height * 0.006),

          /// SERVICE NAME
          Text(
            item.serviceName,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF027DCF),
              height: 1.2,
            ),
          ),

          SizedBox(height: height * 0.003),

          /// LEAD NAME
          Text(
            item.leadName,
            style: GoogleFonts.dmSans(
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),

          SizedBox(height: height * 0.01),

          /// STATUS BUTTON
          Container(
            height: height * 0.035,
            width: width * 0.28,
            decoration: BoxDecoration(
              border: Border.all(
                color: statusColors.border,
                width: width * 0.002,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                latestStatus,
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.028,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.008),
        ],
      ),
    );
  }
}