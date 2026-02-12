import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:refrr_admin/Core/common/chat-screen-support-%20functions.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/constants/homepage-functions.dart';
import 'package:refrr_admin/Core/constants/servicelead-color.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/models/chatbox-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showLeadBottomSheet(BuildContext context,ServiceLeadModel? service,LeadsModel? currentFirm,WidgetRef? ref) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return LeadBottomSheetUI(currentFirm:currentFirm ,service:service ,ref: ref,);
    },
  );
}

class LeadBottomSheetUI extends ConsumerStatefulWidget {
  final ServiceLeadModel? service;
  final LeadsModel? currentFirm;
  final WidgetRef? ref;
  const LeadBottomSheetUI( {super.key,this.currentFirm, this.service,  this.ref,});

  @override
  _LeadBottomSheetUIState createState() => _LeadBottomSheetUIState();
}
class _LeadBottomSheetUIState extends ConsumerState<LeadBottomSheetUI> {
  String selectedType = "";
  String selectedStatus = "";

  @override
  void initState() {
    selectedType = widget.service?.leadType ?? '';
    if (widget.service != null &&
        widget.service!.statusHistory.isNotEmpty) {
      selectedStatus = widget.service!.statusHistory.last['status'] ?? '';
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ------- TOP HANDLE -------
          Center(
            child: Container(
              height: 4,
              width: 50,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          /// ------- TITLE -------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lead Type",
                style: TextStyle(
                  fontSize: width * .055,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child:  CircleAvatar(
                    radius: width*.04,
                    backgroundColor: Color(0xFFF3F3F3),
                    child: Icon(Icons.close, size: 18)),
              ),
            ],
          ),

          SizedBox(height: 14),

          /// ------- HOT / WARM / COOL -------
          Row(
            children: [
              SizedBox(width: width*.02),
              typeChip("assets/svg/fireimogi.svg", "Hot"),
              SizedBox(width: width*.03),
              typeChip("assets/svg/warmimogi.svg", "Warm"),
              SizedBox(width: width*.03),
              typeChip("assets/svg/specsimogi.svg", "Cool"),
            ],
          ),

          SizedBox(height: 20),

          /// ------- STATUS HEADING -------
          Text(
            "Change Status",
            style: TextStyle(
              fontSize: width * .05,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 14),
          /// ------- STATUS WRAP -------
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceEvenly,
            children: statusOptions.map((status) {
              final colors = getStatusColors(status); // your helper for pastel colors
              final bool selected = selectedStatus == status;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedStatus = status);

                  showHireConfirmation(
                    context,
                    'Do you want to change the status to $status?',
                        () async {
                      try {
                        if (widget.service == null || widget.service!.reference == null) {
                          print('Error: Service or reference is null');
                          return;
                        }

                        final newHistoryEntry = {
                          "status": status,
                          "date": DateTime.now(),
                          'added': widget.currentFirm?.reference?.id ?? ''
                        };
                        final updatedHistory =
                        [...widget.service!.statusHistory, newHistoryEntry];

                        final newMessage = ChatModel(
                          type: 'status',
                          chatterId: widget.currentFirm!.reference!.id,
                          imageUrl: widget.currentFirm?.logo ?? '',
                          message: '${widget.currentFirm?.name} updated the lead status to $status',
                          time: DateTime.now(),
                          dateLabel: DateTime.now(),
                          amount: 0,
                          description: '',
                          requiresAction: false,
                          transactionStatus: '',
                        );

                        final updatedChatList = List<ChatModel>.from(widget.service!.chat)..add(newMessage);

                        final updatedService = widget.service!.copyWith(
                          statusHistory: updatedHistory, chat: updatedChatList,);

                        await ref.read(serviceLeadsControllerProvider.notifier)
                            .updateServiceLeads(serviceLeadsModel: updatedService, context: context,);

                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        print('Error updating status: $e');
                      }
                    },
                  );
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF14DFED)
                          : colors.border.withOpacity(0.25),
                      width: selected ? 1 : 1,
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

          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// LEAD TYPE CHIP (Hot, Warm, Cool)
  Widget typeChip(String svgPath, String title) {
    bool isSelected = selectedType == title;

    return GestureDetector(
      onTap: () {
        setState(() => selectedType = title);

        showHireConfirmation(
          context,
          'Do you want to change the lead type to $title?',
              () async {
            try {
              final type = title;

              if (widget.service == null || widget.service!.reference == null) {
                print('Error: Service or reference is null');
                return;
              }
              final newMessage = ChatModel(
                  type:'type',
                  chatterId: widget.currentFirm?.reference!.id ??'',
                  imageUrl: widget.currentFirm?.logo??'',
                  message:' The lead type has been changed to $selectedType.',
                  time: DateTime.now(),
                  dateLabel: DateTime.now(),
                  amount: 0,
                  description: '',
                  requiresAction: false,
                  transactionStatus: ''
              );
              // 2️⃣ Copy existing chat list
              final updatedChatList = List<ChatModel>.from(widget.service?.chat??[]);
              // 3️⃣ Add new message
              updatedChatList.add(newMessage);
              final updateType = widget.service!.copyWith(leadType: type, chat: updatedChatList);
              await ref.read(serviceLeadsControllerProvider.notifier)
                  .updateServiceLeads(serviceLeadsModel: updateType, context: context,);

              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              print('Error updating lead type: $e');
            }
          },
        );
      },
      child: Container(
        width: width*.285,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF14DFED) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                height: 18,
                width: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                    fontSize: width*.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // ⭐ Always keep space for the icon
              SizedBox(
                width: 20,
                child: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF14DFED), size: 18)
                    : const SizedBox.shrink(), // empty but same width
              ),
            ],
          ),
        ),
      ),
    );
  }
}
