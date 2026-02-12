import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:refrr_admin/Core/common/custom-round-button.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Core/common/some-custom%20codes.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart' hide searchQuery;
import 'package:refrr_admin/Core/constants/homepage-functions.dart';
import 'package:refrr_admin/Core/constants/servicelead-color.dart';
import 'package:refrr_admin/Feature/Login/Screens/connectivity.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/city-controller.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/menu/menu.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/pipeline/date-filter.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/pipeline/lead-card-ui.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/scale/add-city.dart';
import 'package:refrr_admin/Feature/pipeline/Screens/scale/city-home.dart';
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
  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(kLocationsPrefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      locations
        ..clear()
        ..addAll(names.map((n) => {"name": n}));
    });
  }

  void _pickDateRange() async {
    final result = await showDateRangeBottomSheet(context);
    if (result != null) {
      setState(() {
        fromDate = result['from'];
        toDate = result['to'];
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
                  alignment: WrapAlignment.spaceEvenly,
                  children: statusOptions.map((status) {
                    final colors = getStatusColors(status);
                    return GestureDetector(
                      onTap: () => Navigator.of(bottomSheetContext).pop(status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        decoration: BoxDecoration(
                          color: colors.bigBackground,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: colors.border),
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
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    if (result != null) setState(() => selectedStatus = result);
  }

  void _selectMarketer(List<ServiceLeadModel> leads) async {
    if (!mounted) return;
    final marketers = leads
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
                  child: ListView.builder(
                    itemCount: marketers.length,
                    itemBuilder: (context, index) {
                      final marketer = marketers[index];
                      return Padding(
                        padding: EdgeInsets.only(
                            right: width * 0.03,
                            left: width * 0.03,
                            bottom: height * 0.01),
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
                                vertical: 14, horizontal: 24),
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

  List<Map<String, dynamic>> getFilterBox(List<ServiceLeadModel> leads) {
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
              searchController.clear();
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
        'isSelected': selectedStatus != null
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
        'onTap': () => _selectMarketer(leads),
        'isSelected': selectedMarketer != null,
      },
    ];
  }

  Future<List<ServiceLeadModel>> _filterLeadsAsync(
      List<ServiceLeadModel> leads) async {
    final currentFirmId = widget.currentFirm?.reference?.id.trim() ?? '';
    final currentFirmName =
        widget.currentFirm?.name.trim().toLowerCase() ?? '';
    return compute(_computeFilter, {
      'leads': leads,
      'id': currentFirmId,
      'name': currentFirmName,
      'status': selectedStatus,
      'marketer': selectedMarketer,
      'from': fromDate,
      'to': toDate,
      'query': searchQuery,
    });
  }

  static List<ServiceLeadModel> _computeFilter(Map<String, dynamic> args) {
    final leads = args['leads'] as List<ServiceLeadModel>;
    final firmId = args['id'] as String;
    final firmName = args['name'] as String;
    var result = leads
        .where((lead) =>
    (lead.leadFor ?? '').trim() == firmId ||
        (lead.leadName ?? '').trim().toLowerCase() == firmName)
        .toList();

    final status = args['status'] as String?;
    final marketer = args['marketer'] as String?;
    final from = args['from'] as DateTime?;
    final to = args['to'] as DateTime?;
    final query = args['query'] as String;

    if (status != null) {
      result = result
          .where((l) =>
      (getLatestStatus(l.statusHistory) ?? '')
          .toLowerCase() ==
          status.toLowerCase())
          .toList();
    }
    if (from != null && to != null) {
      result = result
          .where((l) =>
      l.createTime
          .isAfter(from.subtract(const Duration(days: 1))) &&
          l.createTime
              .isBefore(to.add(const Duration(days: 1))))
          .toList();
    }
    if (marketer != null) {
      result =
          result.where((l) => l.marketerName == marketer).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((l) =>
      l.leadName.toLowerCase().contains(q) ||
          l.firmName.toLowerCase().contains(q) ||
          l.marketerName.toLowerCase().contains(q) ||
          l.location.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(serviceLeadsStreamProvider);
    final appBarTitle = widget.currentFirm?.name ?? 'Leads';

    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: leadsAsync.when(
            loading: () =>
            const Center(child: CommonLoader()), // ✅ main loader only
            error: (e, _) => Center(child: Text("Error: $e")),
            data: (leads) {
              return FutureBuilder<List<ServiceLeadModel>>(
                future: _filterLeadsAsync(leads),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CommonLoader());
                  }

                  final filtered = snapshot.data!;
                  final boxData = getFilterBox(leads);
                  final double screenWidth = MediaQuery.of(context).size.width;
                  const double visibleItems = 4.5;
                  const double spacing = 8.0;
                  final double leftPad = width * .04;
                  final double available = screenWidth - leftPad;
                  final double itemWidth = (available - (spacing * 4)) / visibleItems;
                  final double avatarRadius = itemWidth / 2;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * .01),
                        // AppBar Section
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: width * .03),
                                    SvgPicture.asset(
                                        "assets/svg/waving-hand.svg",
                                        height: width * 0.05,
                                        width: width * 0.05),
                                    const SizedBox(width: 6),
                                    Text("Welcome,",
                                        style: GoogleFonts.dmSans(
                                            fontSize: width * 0.04,
                                            color: Colors.black,
                                            fontWeight:
                                            FontWeight.w700)),
                                  ],
                                ),
                                Padding(
                                  padding:
                                  EdgeInsets.only(left: width * .035),
                                  child: Text(
                                    appBarTitle.length > 19
                                        ? appBarTitle.substring(0, 19)
                                        : appBarTitle,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: width * 0.055,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: width * .01, top: height * .01),
                              child: Row(
                                children: [
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             NotificationScreen(currentFirm: widget.currentFirm),
                                  //       ),
                                  //     );
                                  //   },
                                  //   child: CircleSvgButton(
                                  //     size: width * .09,
                                  //     child: SvgPicture.asset("assets/svg/bell.svg", width: 15, height: 15),
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        backgroundColor:
                                        Colors.transparent,
                                        barrierColor: Colors.black
                                            .withOpacity(0.4),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.vertical(
                                              top: Radius.circular(
                                                  30)),
                                        ),
                                        builder: (context) {
                                          return MenuBottomSheet(
                                            appBarTitle: appBarTitle,
                                            currentFirm:
                                            widget.currentFirm!,
                                          );
                                        },
                                      );
                                    },
                                    child: CircleSvgButton(
                                      size: width * .09,
                                      child: SvgPicture.asset(
                                          "assets/svg/menu.svg",
                                          width: 15,
                                          height: 15),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.03),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Location avatars
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: leftPad,
                                top: height * .015,
                                right: width * .02),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => Scale(
                                              currentFirm:
                                              widget.currentFirm,
                                              serviceLeads: leads)),
                                    );
                                  },
                                  child: SizedBox(
                                    width: itemWidth,
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: avatarRadius,
                                          backgroundColor:
                                          Colors.black,
                                          child: SvgPicture.asset(
                                              'assets/svg/scale.svg'),
                                        ),
                                        SizedBox(height: height * .003),
                                        SizedBox(
                                            width: itemWidth,
                                            child: Text("Scale",
                                                maxLines: 1,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                                textAlign:
                                                TextAlign.center,
                                                style:
                                                GoogleFonts.dmSans(
                                                    fontSize: MediaQuery
                                                        .of(
                                                        context)
                                                        .size
                                                        .width *
                                                        .035,
                                                    fontWeight:
                                                    FontWeight
                                                        .w500,
                                                    color: Colors
                                                        .black))),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: spacing),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final citiesAsync = ref.watch(
                                        citiesStreamProvider(widget
                                            .currentFirm
                                            ?.reference
                                            ?.id ??
                                            ''));
                                    return citiesAsync.when(
                                      loading: () =>
                                      const SizedBox.shrink(), // ⛔ no 2nd loader
                                      error: (e, _) => Center(
                                          child:
                                          Text(e.toString())),
                                      data: (cities) {
                                        final activeCities = cities
                                            .where((c) => !c.isDeleted)
                                            .toList();
                                        return Row(
                                            children:
                                            List.generate(
                                                activeCities
                                                    .length, (i) {
                                              final city =
                                              activeCities[i];
                                              return Row(children: [
                                                SizedBox(
                                                  width: itemWidth,
                                                  child: Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator
                                                              .push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  CityScreen(
                                                                      currentFirm:
                                                                      widget
                                                                          .currentFirm,
                                                                      serviceLeads:
                                                                      leads,
                                                                      city:
                                                                      city),
                                                            ),
                                                          );
                                                        },
                                                        child:
                                                        CircleAvatar(
                                                          radius:
                                                          avatarRadius,
                                                          backgroundColor:
                                                          Colors.grey
                                                              .shade200,
                                                          child: ClipOval(
                                                            child:
                                                            CachedNetworkImage(
                                                              imageUrl: city
                                                                  .profile,
                                                              width:
                                                              avatarRadius *
                                                                  2,
                                                              height:
                                                              avatarRadius *
                                                                  2,
                                                              fit: BoxFit
                                                                  .cover,
                                                              placeholder:
                                                                  (context,
                                                                  _) =>
                                                              const SizedBox
                                                                  .shrink(), // 🔸 silent placeholder
                                                              errorWidget: (context,
                                                                  _,
                                                                  __) =>
                                                              const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                          height *
                                                              .005),
                                                      SizedBox(
                                                          width:
                                                          itemWidth,
                                                          child: Text(
                                                              city.zone,
                                                              maxLines:
                                                              1,
                                                              overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                  fontSize:
                                                                  width *
                                                                      .035,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                                  color:
                                                                  Colors.black))),
                                                    ],
                                                  ),
                                                ),
                                                if (i !=
                                                    activeCities
                                                        .length -
                                                        1)
                                                  SizedBox(
                                                      width:
                                                      spacing),
                                              ]);
                                            }));
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // keep rest identical
                        Padding(
                          padding: EdgeInsets.only(
                              top: height * .02,
                              left: width * .04),
                          child: Text('Your Growth Pipeline',
                              style: GoogleFonts.dmSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: width * .06)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: height * .02,
                              left: width * .04,
                              right: width * .04),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children:
                            boxData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value;
                              bool isSelected =
                                  index == selectedIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => selectedIndex =
                                      index);
                                  if (item['onTap'] != null) {
                                    item['onTap']();
                                  }
                                },
                                child: Container(
                                  width: width * 0.22,
                                  height: height * 0.043,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color.fromRGBO(
                                        26, 224, 237, 0.1)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color.fromRGBO(
                                          26, 224, 237, 0.3)
                                          : Colors.grey
                                          .withOpacity(.2),
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['title'],
                                      overflow:
                                      TextOverflow.ellipsis,
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
                        filtered.isEmpty
                            ? SizedBox(
                          height: height * 0.6,
                          child: const Center(
                              child: Text("No leads found")),
                        )
                            : Padding(
                          padding: EdgeInsets.only(
                              bottom: height * .02,
                              top: height * .01,
                              left: width * .04,
                              right: width * .04),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: width * 0.04,
                              mainAxisSpacing: height * 0.02,
                              childAspectRatio: 0.9,
                            ),
                            itemBuilder: (context, idx) {
                              final lead = filtered[idx];
                              final latestStatus = getLatestStatus(lead.statusHistory);
                              final statusColors =
                              getStatusColors(latestStatus);
                              return GestureDetector(
                                onTap: () async {
                                  // final marketer = await ref
                                  //     .read(affiliateControllerProvider.notifier)
                                  //     .getAffiliateByMarketerId(
                                  //     lead.marketerId);
                                  // if (!mounted) return;
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => LeadTimelineScreen(
                                  //       statuscolor: statusColors,
                                  //       currentFirm: widget.currentFirm,
                                  //       service: lead,
                                  //       marketer: marketer,
                                  //     ),
                                  //   ),
                                  // );
                                },
                                child: buildLeadCard(lead, statusColors, latestStatus, widget.currentFirm!),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}