import 'package:flutter/material.dart';
import 'package:refrr_admin/feature/pipeline/Controller/service_lead_controller.dart';
import 'package:refrr_admin/feature/pipeline/screens/pipeline/shedule_bottom_sheet_page.dart';
import 'package:refrr_admin/models/chatbox_model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLead_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///schedule alert box
void showScheduleBottomSheet(
    BuildContext parentContext,
    ServiceLeadModel service,
    LeadsModel currentFirm,
    WidgetRef ref,
    ) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ScheduleBottomSheet(
      onSchedule: (date, event, remarks) async {
        // ✅ Validate: date and event must not be null
        if (date == null) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text("Please select a date")),
          );
          return;
        }

        if (event == null || event.isEmpty) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text("Please select an event type")),
          );
          return;
        }

        final newMessage = ChatModel(
          type: 'schedule',
          chatterId: currentFirm.reference!.id,
          imageUrl: currentFirm.logo ?? '',
          message: event,
          time: date,  // ✅ Now guaranteed not null
          dateLabel: DateTime.now(),
          amount: 0,
          description: remarks,
          requiresAction: false,
          transactionStatus: '',
        );

        // ✅ Use ArrayUnion to safely add chat
        await ref.read(serviceLeadsControllerProvider.notifier).addChatMessageWithUpdate(
          serviceLeadId: service.reference!.id,
          message: newMessage,
          context: parentContext,
        );

        print("DATE: $date");
        print("EVENT: $event");
        print("REMARKS: $remarks");
      },
    ),
  );
}