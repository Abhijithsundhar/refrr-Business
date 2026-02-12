import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/chat-screen-support-%20functions.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';

class ScheduledEventsPage extends StatelessWidget {
  final ServiceLeadModel? service;
  final LeadsModel? currentFirm;
  final WidgetRef ref;
  const ScheduledEventsPage({super.key, this.service, this.currentFirm, required this.ref});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           SizedBox(height: height*.03,),
            /// ---------------- BACK + TITLE ----------------
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Scheduled Events",
                  style: GoogleFonts.urbanist(
                    fontSize: width * .05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: height*.015,),

            /// ---------------- EVENT LIST ----------------
            Consumer(
              builder: (context, ref, child) {
                final chat = ref.watch(chatProvider(service!.reference!.id));
                return  chat.when(data: (data) {
                  if (data.isEmpty){
                    return const Center(child: Text("No scheduled events"));
                  }
                  final scheduleChats = data
                      .where((c) => c.type == 'schedule')
                      .toList()
                    ..sort((a, b) => b.time!.compareTo(a.time!)); // Latest → Oldest

                  return Expanded(
                    child: ListView.builder(
                      itemCount: scheduleChats.length,
                      itemBuilder: (context, index) {
                        final chat = scheduleChats[index];
                        return Column(
                          children: [
                            eventTile(
                              width: width,
                              title: chat.message ?? 'Schedule',
                              description: chat.description ?? '',
                              date: chat.time!,
                              // time: chat.dateLabel!,
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  );
                },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text("Error loading leads: $e")));
              },
            )
          ],
        ),
      ),

      /// ---------------- BOTTOM BUTTON ----------------
      floatingActionButton: GestureDetector(
        onTap: (){
          showScheduleBottomSheet(context,service!,currentFirm!,ref);
        },
        child: Container(
          width: 120,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Icon(Icons.add, color: Colors.white),
                 SizedBox(width: width*.01),
                Text(
                  "Schedule",
                  style: GoogleFonts.urbanist(
                    fontSize: width * .04,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- EVENT TILE WIDGET ----------------
  Widget eventTile({
    required double width,
    required String title,
    required String description,
    required DateTime date,
    // required DateTime time,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- Title + Date ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_note, size: 20, color: Colors.black),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.urbanist(
                      fontSize: width * .04,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                formatDateTime(date,showTime: false),
                style: GoogleFonts.urbanist(
                  fontSize: width * .033,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// --- Description ---
          Text(
            description,
            style: GoogleFonts.urbanist(
              fontSize: width * .032,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
