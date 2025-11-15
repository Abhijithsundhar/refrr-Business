import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/some-custom%20codes.dart';
import 'package:refrr_admin/Feature/Funnel/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/Feature/Login/Controller/lead-controllor.dart';
import 'package:refrr_admin/Feature/Team/controller/affiliate-controller.dart';
import 'package:refrr_admin/Feature/Team/screens/hire-page.dart';
import 'package:refrr_admin/Feature/Team/screens/new-profile.dart';
import 'package:refrr_admin/models/affiliate-model.dart';
import 'package:refrr_admin/models/leads_model.dart';

class TeamHome extends ConsumerStatefulWidget {
  final LeadsModel? currentFirm;
  const TeamHome({super.key, this.currentFirm});

  @override
  ConsumerState<TeamHome> createState() => _TeamHomeState();
}
class _TeamHomeState extends ConsumerState<TeamHome> {
  String activeFilter = 'All';
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final serviceLeadAsync = ref.watch(serviceLeadsStreamProvider);
    final team = ref.watch(teamProvider(widget.currentFirm!.reference!.id));
    final totalCount = team.asData?.value.length ?? 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: EdgeInsets.only(left: width * .05),
          child: Text(
            widget.currentFirm?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.bebasNeue(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: width * .055,
            ),
          ),
        ),
        actions: [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: width * .02),
          Icon(Icons.menu_outlined, color: Colors.black),
          SizedBox(width: width * .03),
        ],
      ),
      body: Padding(
        padding:
        EdgeInsets.only(top: height * .01, left: width * .04, right: width * .05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * .01),

              /// Filter buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildFilterButton(
                    'All ($totalCount)',
                    activeFilter == 'All',
                        () {
                      setState(() {
                        activeFilter = 'All';
                        selectedLocation = null;
                      });
                    },
                  ),
                  SizedBox(width: width * .02),
                  buildFilterButton(
                    selectedLocation ?? 'Location',
                    activeFilter == 'Location',
                        () => _selectLocation(team),
                  ),
                  SizedBox(width: width * .02),
                  buildFilterButton(
                    'Performance',
                    activeFilter == 'Performance',
                        () {
                      setState(() {
                        activeFilter = 'Performance';
                      });
                    },
                  ),
                ],
              ),

                SizedBox(height: height * 0.02),
              Consumer(
                builder: (context, ref, child) {
                  final applications = ref.watch(applicationsProvider(widget.currentFirm!.reference!.id));

                  return applications.when(
                    data: (data) {
                      if (data.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending requests',
                              style: GoogleFonts.urbanist(
                                fontSize: height * 0.022,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            SizedBox(
                              height: height * 0.31,
                              width: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: data.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final appData = data[index];
                                  return SizedBox(
                                    height: height * 0.31,
                                    width: width * 0.43,
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NewProfile(affiliate: appData),
                                          ),
                                        );
                                      },
                                      child: buildCard(
                                        model: appData,
                                        width: width,
                                        completedCount: 0,
                                        lqScore: appData.leadScore!.toInt().toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink(); // nothing shown when empty
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text("Error: $err")),
                  );
                },
              ),

              SizedBox(height: height * 0.02),

          team.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text("No team members found"));
              }

              // 🔽 Apply filter logic only when data is ready
              List<AffiliateModel> filteredAffiliates = List.from(data);

              if (activeFilter == 'Location' &&
                  selectedLocation != null &&
                  selectedLocation!.isNotEmpty) {
                filteredAffiliates = filteredAffiliates
                    .where((a) => a.zone.toLowerCase() == selectedLocation!.toLowerCase())
                    .toList();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our team',
                    style: GoogleFonts.urbanist(
                      fontSize: height * 0.022,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  GridView.builder(
                    padding: const EdgeInsets.only(bottom: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredAffiliates.length,
                    itemBuilder: (context, index) {
                      final affiliate = filteredAffiliates[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NewProfile(affiliate: affiliate),
                            ),
                          );
                        },
                        child: buildCandidateCard(
                          model: affiliate,
                          width: width,
                          completedCount: affiliate.totalLeads,
                          lqScore: affiliate.leadScore!.toInt().toString(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error loading leads: $e")),
          )
          ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HirePage(
                serviceLead: serviceLeadAsync,
                affiliate: ref.watch(affiliateStreamProvider('')),
                currentFirm: widget.currentFirm,
              ),
            ),
          );
        },
        backgroundColor: Colors.black,
        label: Row(
          children: [
            const Icon(Icons.shopping_bag, color: Colors.white),
            SizedBox(width: width * .02),
            Text(
              'Hire',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: width * .035,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Location filter helper
  Future<String?> _selectLocation(AsyncValue<List<AffiliateModel>> team) async {
    final zones = team.maybeWhen(
      data: (list) => list.map((a) => a.zone).toSet().toList(),
      orElse: () => <String>[],
    );

    return await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Location'),
        children: zones.map((zone) {
          return SimpleDialogOption(
            child: Text(zone),
            onPressed: () => Navigator.pop(context, zone),
          );
        }).toList(),
      ),
    );
  }
}
