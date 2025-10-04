import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/homepage-functions.dart';
import 'package:refrr_admin/Core/constants/servicelead-color.dart';
import 'package:refrr_admin/Feature/Funnel/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/Funnel/Screens/Services-home-funnel.dart';
import 'package:refrr_admin/Feature/Funnel/Screens/funnel-inner-page.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/Team/screens/dummyHire.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FunnelHome extends ConsumerStatefulWidget {
  final AffiliateModel? affiliate;
  final LeadsModel? currentFirm;

  const FunnelHome({super.key, this.affiliate, this.currentFirm});

  @override
  ConsumerState<FunnelHome> createState() => _FunnelHomeState();
}

class _FunnelHomeState extends ConsumerState<FunnelHome> {
  String? selectedStatus; // filter chip
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedMarketer;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Persisted locations
  final List<Map<String, dynamic>> locations = [];
  static const String _kLocationsPrefsKey = 'funnel_locations_v1';

  // Only these 3 images, repeated for any place
  static const List<String> _imagePool = [
    'assets/banglore.jpeg',
    'assets/chennai.jpeg',
    'assets/dubai.jpeg',
  ];

  String imageForPlace(String name) {
    final idx = name.toLowerCase().hashCode.abs() % _imagePool.length;
    return _imagePool[idx];
  }

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_kLocationsPrefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      locations
        ..clear()
        ..addAll(
          names.map((n) => {"name": n, "image": imageForPlace(n)}),
        );
    });
  }

  Future<void> _saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final names = locations.map((e) => e['name'] as String).toList();
    await prefs.setStringList(_kLocationsPrefsKey, names);
  }

  String getTimeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) {
      return "Just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
    } else if (diff.inDays == 1) {
      return "Yesterday";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return "$weeks week${weeks > 1 ? 's' : ''} ago";
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return "$months month${months > 1 ? 's' : ''} ago";
    } else {
      final years = (diff.inDays / 365).floor();
      return "$years year${years > 1 ? 's' : ''} ago";
    }
  }

  void _addLocation() {
    final TextEditingController searchCtrl = TextEditingController();

    // Full place list (as provided)
    final List<String> allPlaces = [
      'Alappuzha',
      'Angamaly',
      'Adoor',
      'Attingal',
      'Changanassery',
      'Chalakudy',
      'Cherthala',
      'Ernakulam (Kochi)',
      'Guruvayur',
      'Haripad',
      'Idukki (Painavu)',
      'Irinjalakuda',
      'Kalpetta (Wayanad)',
      'Kannur',
      'Karunagappally',
      'Kasaragod',
      'Kayamkulam',
      'Kodungallur',
      'Kollam',
      'Kondotty',
      'Kothamangalam',
      'Kottakkal',
      'Kottarakkara',
      'Kottayam',
      'Koyilandy',
      'Kozhikode (Calicut)',
      'Kunnamkulam',
      'Malappuram',
      'Manjeri',
      'Mannarkkad',
      'Mavelikkara',
      'Muvattupuzha',
      'Nedumangad',
      'Neyyattinkara',
      'Nilambur',
      'Ottappalam',
      'Palakkad',
      'Pala',
      'Paravur (North Paravur)',
      'Pathanamthitta',
      'Payyannur',
      'Perinthalmanna',
      'Perumbavoor',
      'Ponnani',
      'Shornur',
      'Thiruvalla',
      'Thiruvananthapuram',
      'Thodupuzha',
      'Thrippunithura',
      'Thrissur',
      'Varkala',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        String query = '';
        List<String> filtered = List.from(allPlaces);

        return StatefulBuilder(
          builder: (context, setModalState) {
            filtered = allPlaces
                .where((p) => p.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Add location',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(bottomSheetContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),

                    // Search
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                      child: TextField(
                        controller: searchCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search location',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setModalState(() => query = val),
                      ),
                    ),

                    // Results
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                        child: Text(
                          'No results',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                          : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          final name = filtered[index];

                          final alreadyAdded = locations.any((e) =>
                          (e['name'] as String).toLowerCase() ==
                              name.toLowerCase());

                          final String imagePath = imageForPlace(name);

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: AssetImage(imagePath),
                            ),
                            title: Text(
                              name,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: alreadyAdded
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.add_circle_outline, color: Colors.black),
                            onTap: alreadyAdded
                                ? null
                                : () async {
                              setState(() {
                                locations.add({
                                  "name": name,
                                  "image": imagePath,
                                });
                              });
                              await _saveLocations();
                              if (mounted) {
                                Navigator.of(bottomSheetContext).pop();
                              }
                            },
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
      },
    );
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

  // Filter UI: select a status (does not update a lead)
  Future<void> _selectStatus() async {
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
              // Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lead status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(bottomSheetContext).canPop()) {
                        Navigator.of(bottomSheetContext).pop();
                      }
                    },
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status chips
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: statusOptions.map((status) {
                    return GestureDetector(
                      onTap: () {
                        if (Navigator.of(bottomSheetContext).canPop()) {
                          Navigator.of(bottomSheetContext).pop(status);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        decoration: BoxDecoration(
                          color: chipBackground(status),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: chipAccent(status).withOpacity(0.25),
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

  void _selectMarketer(List<ServiceLeadModel> leads) async {
    if (!mounted) return;

    final marketers = leads.map((e) => e.marketerName).toSet().toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
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
                // Title + Close Button
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
                      onPressed: () {
                        if (Navigator.of(bottomSheetContext).canPop()) {
                          Navigator.of(bottomSheetContext).pop();
                        }
                      },
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
                            right: width * 0.03,
                            left: width * 0.03,
                            bottom: height * 0.01,
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  selectedMarketer = marketer;
                                });
                              }
                              if (Navigator.of(bottomSheetContext).canPop()) {
                                Navigator.of(bottomSheetContext).pop();
                              }
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

  // Update a single lead's status (adds a new history entry)
  Future<void> updateStatus(ServiceLeadModel lead) async {
    if (!mounted) return;

    final String? status = await showModalBottomSheet<String>(
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
              // Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lead status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: width * .04),
                  InkWell(
                    onTap: () async {
                      if (Navigator.of(bottomSheetContext).canPop()) {
                        Navigator.of(bottomSheetContext).pop();
                      }
                      // await _creditMoney(lead);
                    },
                    child: Center(
                      child: Text(
                        ' + Add money',
                        style: GoogleFonts.roboto(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue.shade600,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(bottomSheetContext).canPop()) {
                        Navigator.of(bottomSheetContext).pop();
                      }
                    },
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              // Status chips
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: statusOptions.map((s) {
                    return GestureDetector(
                      onTap: () {
                        if (Navigator.of(bottomSheetContext).canPop()) {
                          Navigator.of(bottomSheetContext).pop(s);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        decoration: BoxDecoration(
                          color: chipBackground(s),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: chipAccent(s).withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          s,
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
    if (status == null) return;

    try {
      // Show loading indicator while updating
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Append with Timestamp to avoid type crashes
      final newHistoryEntry = {
        "status": status,
        "date": Timestamp.now(),
      };

      final updatedHistory = [...lead.statusHistory, newHistoryEntry];

      final updatedLead = lead.copyWith(
        statusHistory: updatedHistory,
      );

      await ref
          .read(serviceLeadsControllerProvider.notifier)
          .updateServiceLeads(
        context: context,
        serviceLeadsModel: updatedLead,
      );

      // Close loading dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Optional: Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $status'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Print error for debugging
      print('Error updating status: $e');
    }
  }

  int selectedIndex = 0;

  List<Map<String, dynamic>> getFilterBox(List<ServiceLeadModel> leads) {
    return [
      {
        'title': '   All   ',
        'onTap': () {
          if (mounted) {
            setState(() {
              selectedMarketer = null;
              selectedStatus = null;
              fromDate = null;
              toDate = null;
              searchQuery = '';
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
        'onTap': _selectStatus,
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
        'onTap': () {
          _selectMarketer(leads);
        },
        'isSelected': selectedMarketer != null,
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(serviceLeadsStreamProvider);
    final String appBarTitle = widget.currentFirm?.name ?? 'Leads';
    final affiliatesAsync = ref.watch(affiliateStreamProvider(searchQuery));
    final serviceLeadAsync = ref.watch(serviceLeadsStreamProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: Text(
              appBarTitle,
              style: GoogleFonts.bebasNeue(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: width * .055,
              ),
            ),
            actions: [
              Stack(children: [
                SvgPicture.asset('assets/svg/update_unfill.svg', height: 25),
                const Positioned(
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.red,
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ]),
              SizedBox(width: width * .02),
              const Icon(Icons.menu_outlined, color: Colors.black),
              SizedBox(width: width * .03),
            ],
          ),
          body: SafeArea(
            child: leadsAsync.when(
              data: (leads) {
                // Start with all leads
                var filtered = leads.toList();

                // Narrow by current firm if provided
                final firmName =
                (widget.currentFirm?.name ?? '').trim().toLowerCase();
                if (firmName.isNotEmpty) {
                  filtered = filtered.where((lead) {
                    final firm = (lead.firmName).trim().toLowerCase();
                    final ln = (lead.leadName ?? '').trim().toLowerCase();
                    // Match either firmName or leadName to currentFirm.name
                    return firm == firmName || ln == firmName;
                  }).toList();
                }

                // Status filter (latest in history)
                if (selectedStatus != null) {
                  filtered = filtered.where((lead) {
                    final latest =
                    (getLatestStatus(lead.statusHistory) ?? '').toLowerCase();
                    return latest == selectedStatus!.toLowerCase();
                  }).toList();
                }

                // Date range filter (createTime)
                if (fromDate != null && toDate != null) {
                  filtered = filtered.where((lead) {
                    return lead.createTime.isAfter(
                        fromDate!.subtract(const Duration(days: 1))) &&
                        lead.createTime
                            .isBefore(toDate!.add(const Duration(days: 1)));
                  }).toList();
                }

                // Marketer filter
                if (selectedMarketer != null) {
                  filtered = filtered
                      .where((lead) => lead.marketerName == selectedMarketer)
                      .toList();
                }

                // Search filter
                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  filtered = filtered.where((lead) {
                    return (lead.leadName ?? '').toLowerCase().contains(q) ||
                        (lead.firmName).toLowerCase().contains(q) ||
                        (lead.marketerName).toLowerCase().contains(q) ||
                        (lead.location ?? '').toLowerCase().contains(q);
                  }).toList();
                }

                final boxData = getFilterBox(leads);

                // Sizing math for avatar carousel (4 full + 1 half)
                final double screenWidth = MediaQuery.of(context).size.width;
                const double visibleItems = 4.5; // 4 full + half
                const double spacing = 8.0;
                final double leftPad = width * .04;
                final double available = screenWidth - leftPad;
                final double itemWidth =
                    (available - (spacing * 4)) / visibleItems;
                final double avatarRadius = itemWidth / 2;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle avatar row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: leftPad, top: height * .015, right: width * .02),
                          child: Row(
                            children: [
                              // Fixed "Scale" item
                              GestureDetector(
                                onTap: _addLocation,
                                child: SizedBox(
                                  width: itemWidth,
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: avatarRadius,
                                        backgroundColor: Colors.black,
                                        child: Transform.rotate(
                                          angle: 50 * 3.1415926535 / 180,
                                          child: Icon(
                                            Icons.navigation,
                                            color: Colors.white,
                                            size: avatarRadius * 0.7,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: height * .005),
                                      SizedBox(
                                        width: itemWidth,
                                        child: Text(
                                          "Scale",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                            fontSize:
                                            MediaQuery.of(context).size.width * .035,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: spacing),

                              // Dynamic avatars (unlimited)
                              ...List.generate(locations.length, (i) {
                                final loc = locations[i];
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: itemWidth,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DummyHire(
                                                    currentFirm: widget.currentFirm,
                                                    serviceLead: serviceLeadAsync,
                                                    affiliate: ref.watch(
                                                      affiliateStreamProvider(
                                                        searchQuery,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: CircleAvatar(
                                              radius: avatarRadius,
                                              backgroundImage: AssetImage(loc["image"]),
                                            ),
                                          ),
                                          SizedBox(height: height * .005),
                                          SizedBox(
                                            width: itemWidth,
                                            child: Text(
                                              loc["name"],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.roboto(
                                                fontSize:
                                                MediaQuery.of(context).size.width * .035,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (i != locations.length - 1)
                                      const SizedBox(width: spacing),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      // Text heading
                      Padding(
                        padding:
                        EdgeInsets.only(top: height * .02, left: width * .04),
                        child: Text(
                          'Your Growth Pipeline',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: width * .048,
                          ),
                        ),
                      ),

                      // Filter row
                      Padding(
                        padding: EdgeInsets.only(
                            top: height * .02,
                            left: width * .04,
                            right: width * .04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: boxData.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            bool isSelected = index == selectedIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index; // update selected tab
                                });
                                if (item['onTap'] != null) item['onTap']();
                              },
                              child: Container(
                                width: width * 0.22,
                                height: height * 0.043,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    item['title'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                      fontSize: width * 0.03,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: height * .02),

                      // Lead cards
                      filtered.isEmpty
                          ? SizedBox(
                        height: height * 0.6,
                        child: const Center(child: Text("No leads found")),
                      )
                          : Padding(
                        padding: EdgeInsets.only(
                            top: height * .02,
                            left: width * .04,
                            right: width * .04),
                        child: GridView.builder(
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
                                getLatestStatus(lead.statusHistory) ??
                                    'Unknown';
                            final statusColors =
                            getStatusColors(latestStatus);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PipeLineInnerPage(),
                                    ));
                              },
                              child: buildLeadCard(
                                lead,
                                statusColors,
                                latestStatus,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ),
        // Add new button
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
                          ServiceHome(currentFirm: widget.currentFirm)));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: width * .027,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: width * .025,
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
                    'New',
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

  /// Card UI
  Widget buildLeadCard(ServiceLeadModel item, StatusColors statusColors,
      String latestStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: statusColors.border, width: width * .0015),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header band
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColors.background,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: width * .02, vertical: height * .01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: width * .036,
                      backgroundColor: statusColors.circleAvatarBorder,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/image.png'),
                      ),
                    ),
                    SizedBox(width: width * .01),
                    Expanded(
                      child: Text(
                        item.marketerName,
                        style: GoogleFonts.roboto(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: height * .015),
                      child: Icon(Icons.more_vert_rounded,
                          color: Colors.black, size: width * .05),
                    ),
                  ],
                ),
                SizedBox(height: height * .008),
                Text(
                  item.location ?? "Location",
                  style: GoogleFonts.roboto(
                    fontSize: width * .03,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColors.bigBackground,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            padding: EdgeInsets.all(width * 0.025),
            child: Column(
              children: [
                SizedBox(height: height * .003),
                Text(
                  getTimeAgo(item.createTime),
                  style: GoogleFonts.roboto(
                    fontSize: width * .025,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * .003),
                Text(
                  item.firmName,
                  style: GoogleFonts.roboto(
                    fontSize: width * .03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.serviceName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: width * .04,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: height * .0258),
                Text(
                  'Status',
                  style: GoogleFonts.roboto(
                    fontSize: width * .027,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: height * .001),
                latestStatus == 'Converted'
                    ? GestureDetector(
                  onTap: () => updateStatus(item),
                  child: Container(
                    height: height * .04,
                    width: width * .3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D8D00),
                      border: Border.all(
                          color: const Color(0xFF3D8D00),
                          width: width * .002),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(width: width * .03),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Credited ',
                                  style: GoogleFonts.roboto(
                                    fontSize: width * .025,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: 'AED 500',
                                  style: GoogleFonts.roboto(
                                    fontSize: width * .025,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: width * .004),
                          SvgPicture.asset(
                            'assets/svg/tickIcon.svg',
                            height: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: () => updateStatus(item),
                  child: Container(
                    height: height * .04,
                    width: width * .3,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: statusColors.border,
                          width: width * .002),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}