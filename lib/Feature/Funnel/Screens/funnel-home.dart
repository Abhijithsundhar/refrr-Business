import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:refrr_admin/Model/leads-model.dart';
import '../../../Core/common/global variables.dart';
import '../../../Core/constants/servicelead-color.dart';
import '../../../Model/affiliate-model.dart';
import '../../../Model/serviceLeadModel.dart';
import '../Controller/serviceLead-controllor.dart';

class FunnelHome extends ConsumerStatefulWidget {
  final AffiliateModel? affiliate;
  final LeadsModel? currentFirm;

  const FunnelHome({super.key, this.affiliate, this.currentFirm});

  @override
  ConsumerState<FunnelHome> createState() => _FunnelHomeState();
}

class _FunnelHomeState extends ConsumerState<FunnelHome> {
  String? selectedStatus;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedMarketer;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> statusList = [
    'New Lead',
    'Contacted',
    'Interested',
    'Follow-up-Needed',
    'Proposal Sent',
    'Negotiation',
    'Converted',
    'Invoice Raised',
    'Work in Progress',
    'Completed',
    'Not Qualified',
    'Lost',
  ];

  String? getLatestStatus(List<Map<String, dynamic>> statusHistory) {
    if (statusHistory.isEmpty) return null;
    statusHistory.sort((a, b) {
      final aDate = (a['date'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bDate = (b['date'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return statusHistory.first['status']?.toString();
  }

  /// Pick date range
  void _pickDateRange() async {
    final DateTime now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime(now.year, now.month, now.day),
      // helpText: 'Select a date range', // Optional UI text
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  /// Select Status filter
  void _selectStatus() {
    final List<String> statusList = [
      'New Lead',
      'Contacted',
      'Interested',
      'Follow-Up-Needed',
      'Proposal Sent',
      'Negotiation',
      'Converted',
      'Invoice Raised',
      'Work in Progress',
      'Completed',
      'Not Qualified',
      'Lost',
    ];

    Color getBackgroundColor(String status) {
      switch (status) {
        case 'New Lead':
          return const Color(0xFFF5FAFF);
        case 'Completed':
          return const Color(0xFFF0FFF7);
        case 'Not Qualified':
        case 'Lost':
          return const Color(0xFFFFF2F2);
        default:
          return const Color(0xFFFAFBF2);
      }
    }

    Color getTextColor(String status) {
      switch (status) {
        case 'New Lead':
          return const Color(0xFF3FA2FF);
        case 'Completed':
          return const Color(0xFF3FFF99);
        case 'Not Qualified':
        case 'Lost':
          return const Color(0xFFFF7979);
        default:
          return const Color(0xFFCFD879);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lead status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status Wrap buttons
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: statusList.map((status) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = status;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        decoration: BoxDecoration(
                          color: getBackgroundColor(status),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: getTextColor(status).withOpacity(0.25),
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
  }

  /// Select Marketer filter UI
  void _selectMarketer(List<ServiceLeadModel> leads) async {
    final marketers = leads.map((e) => e.marketerName).toSet().toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: width * 0.05,
            right: width * 0.05,
            top: height * 0.02,
          ),
          child: SizedBox(
            height: height * 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Marketer',
                      style: GoogleFonts.roboto(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: width * 0.07),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Marketers List with Outlined Buttons
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: marketers.map((marketer) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: width * .03,
                            left: width * .03,
                            bottom: height * .01,
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedMarketer = marketer;
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F3F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              side: BorderSide(
                                color: const Color(0xFF828282),
                                width: width * .001,
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
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> getFilterBox(List<ServiceLeadModel> leads) {
    return [
      {
        'title': 'All',
        'onTap': () {
          setState(() {
            selectedMarketer = null;
            selectedStatus = null;
            fromDate = null;
            toDate = null;
            searchQuery = '';
            _searchController.clear();
          });
        },
      },
      {
        'title': selectedStatus ?? 'Status',
        'onTap': _selectStatus,
      },
      {
        'title': fromDate != null && toDate != null
            ? "${DateFormat('dd/MM/yy').format(fromDate!)} - ${DateFormat('dd/MM/yy').format(toDate!)}"
            : 'Period',
        'onTap': _pickDateRange,
      },
      {
        'title': selectedMarketer ?? 'Marketer',
        'onTap': () => _selectMarketer(
            ref.read(serviceLeadsStreamProvider).asData?.value ?? []),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(serviceLeadsStreamProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: leadsAsync.when(
                data: (leads) {
                  List<ServiceLeadModel> filtered = leads
                      .where((lead) => lead.leadName == widget.currentFirm?.name)
                      .toList();

                  if (selectedStatus != null) {
                    filtered = filtered.where((lead) {
                      final status = getLatestStatus(lead.statusHistory);
                      return status?.toLowerCase() ==
                          selectedStatus?.toLowerCase();
                    }).toList();
                  }

                  if (fromDate != null && toDate != null) {
                    filtered = filtered.where((lead) {
                      return lead.createTime
                          .isAfter(fromDate!.subtract(const Duration(days: 1))) &&
                          lead.createTime.isBefore(toDate!.add(const Duration(days: 1)));
                    }).toList();
                  }

                  if (selectedMarketer != null) {
                    filtered =
                        filtered.where((lead) => lead.marketerName == selectedMarketer).toList();
                  }

                  if (searchQuery.isNotEmpty) {
                    final q = searchQuery.toLowerCase();
                    filtered = filtered.where((lead) {
                      return lead.leadName.toLowerCase().contains(q) ||
                          lead.firmName.toLowerCase().contains(q) ||
                          lead.marketerName.toLowerCase().contains(q) ||
                          (lead.location ?? '').toLowerCase().contains(q);
                    }).toList();
                  }

                  final boxData = getFilterBox(leads);

                  // Wrap all in SingleChildScrollView for full page scrolling
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .03),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * .04, vertical: height * .015),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/images/refrrTextLogo.png',
                                  width: width * .2,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * .05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: boxData.map((item) {
                                return GestureDetector(
                                  onTap: item['onTap'],
                                  child: Container(
                                    width: width * 0.2,
                                    height: height * 0.045,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F3F3),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item['title'],
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.roboto(
                                                fontSize: width * 0.03,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          if (item['icon'] != null)
                                            Icon(item['icon'], size: width * 0.04),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: height * .025),

                          filtered.isEmpty
                              ? SizedBox(
                            height: height * 0.6,
                            child: const Center(child: Text("No leads found")),
                          )
                              : GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: width * 0.04,
                              mainAxisSpacing: height * 0.02,
                              childAspectRatio: 0.8,
                            ),
                            itemBuilder: (context, index) {
                              final lead = filtered[index];
                              final latestStatus =
                                  getLatestStatus(lead.statusHistory) ?? 'Unknown';
                              final statusColors = getStatusColors(latestStatus);
                              return buildLeadCard(lead, statusColors, latestStatus);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error loading leads: $e")),
              ),
            ),

            // Floating button (bottom right)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  //     ServiceHome(currentFirm: widget.currentFirm!),));
                },
                child: Container(
                  height: height * .07,
                  width: width * .25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black, // Background color
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: width * .027,
                          child: CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: width * .025,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: width * .04,
                            ),
                          ),
                        ),
                        SizedBox(width: width * .01),
                        Text(
                          "New",
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: width * .03,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLeadCard(
      ServiceLeadModel item, StatusColors statusColors, String latestStatus) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: statusColors.border, width: width * .0015),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: height * 0.11,
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColors.background,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            padding: EdgeInsets.symmetric(horizontal: width * .025, vertical: height * .01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: width * .036,
                      backgroundColor: statusColors.circleAvatarBorder,
                      child: CircleAvatar(
                        radius: width * .035,
                        backgroundImage: NetworkImage(item.leadLogo),
                      ),
                    ),
                    SizedBox(width: width * .02),
                    Expanded(
                      child: Text(
                        item.marketerName,
                        style: GoogleFonts.roboto(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  item.firmName,
                  style: GoogleFonts.roboto(
                    fontSize: width * .03,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  item.location ?? "Location",
                  style: GoogleFonts.roboto(
                    fontSize: width * .027,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: height * .172,
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColors.bigBackground,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            padding: EdgeInsets.all(width * 0.025),
            child: Column(
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(item.createTime),
                  style: GoogleFonts.roboto(
                    fontSize: width * .03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.serviceName,
                  style: GoogleFonts.roboto(
                    fontSize: width * .03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * .03),
                Text(
                  'Status',
                  style: GoogleFonts.roboto(
                    fontSize: width * .027,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Container(
                  height: height * .04,
                  width: width * .3,
                  decoration: BoxDecoration(
                    border: Border.all(color: statusColors.border, width: width * .002),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      latestStatus,
                      style: GoogleFonts.roboto(
                        fontSize: width * .03,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
