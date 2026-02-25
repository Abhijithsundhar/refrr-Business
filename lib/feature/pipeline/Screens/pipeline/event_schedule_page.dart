import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/core/alert_dailogs/shedule_message_alert.dart';
import 'package:refrr_admin/core/common/chat_screen_support_functions.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/loader.dart';
import 'package:refrr_admin/core/utils/date_format.dart';
import 'package:refrr_admin/feature/pipeline/controller/service_lead_controller.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';

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
            SizedBox(height: height * .03),

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

            SizedBox(height: height * .015),

            /// ---------------- EVENT LIST ----------------
            Consumer(
              builder: (context, ref, child) {
                final chat = ref.watch(chatProvider(service!.reference!.id));
                return chat.when(
                  data: (data) {
                    // ✅ FIRST filter for schedule type
                    final scheduleChats = data.where((c) => c.type == 'schedule').toList()
                      ..sort((a, b) => b.time!.compareTo(a.time!));

                    // ✅ THEN check if filtered list is empty
                    if (scheduleChats.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No scheduled events",
                                style: GoogleFonts.urbanist(
                                  fontSize: width * .045,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap the button below to add a schedule",
                                style: GoogleFonts.urbanist(
                                  fontSize: width * .035,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // ✅ Show list if not empty
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
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Expanded(
                    child: Center(child:CommonLoader()),
                  ),
                  error: (e, _) => Expanded(
                    child: Center(child: Text("Error loading events: $e")),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      /// ---------------- BOTTOM BUTTON ----------------
      floatingActionButton: SafeArea(
        child: GestureDetector(
          onTap: () {
            showScheduleBottomSheet(context, service!, currentFirm!, ref);
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
                  SizedBox(width: width * .01),
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
      ),
    );
  }

  /// ---------------- EVENT TILE WIDGET ----------------
  Widget eventTile({
    required double width,
    required String title,
    required String description,
    required DateTime date,
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
                formatDateTime(date, showTime: false),
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