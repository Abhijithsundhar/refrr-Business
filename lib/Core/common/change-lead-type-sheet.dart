import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:refrr_admin/Core/common/chat-screen-support-%20functions.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
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
    selectedType = widget.service?.type ?? '';
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
                child: CircleAvatar(
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
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.2,
            children: [
              statusChip("New Lead"),
              statusChip("Contacted"),
              statusChip("Interested"),

              statusChip("Follow-up-Needed"),
              statusChip("Proposal Sent"),
              statusChip("Negotiation"),

              statusChip("Converted"),
              statusChip("Invoice Raised"),
              statusChip("Work in Progress"),

              statusChip("Completed"),
              statusChip("Not Qualified"),
              statusChip("Lost"),
            ],
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// LEAD TYPE CHIP (Hot, Warm, Cool)
  Widget typeChip(String svgPath, String title) {
    bool isSelected = selectedType == title;

    return InkWell(
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
              final updateType = widget.service!.copyWith(type: type, chat: updatedChatList);
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

  /// STATUS CHIP (Selectable with border)
  Widget statusChip(String text) {
    bool selected = selectedStatus == text;
    final colors = getStatusColors(text);

    return GestureDetector(
      onTap: () {
        setState(() => selectedStatus = text);

        showHireConfirmation(context, 'Do you want to change the status to $text',
                () async {
              try {
                if (widget.service == null || widget.service!.reference == null) {
                  print('Error: Service or reference is null');
                  return;
                }
                final newHistoryEntry = {
                  "status": text,
                  "date": DateTime.now(),
                  'added' :widget.currentFirm?.reference?.id??''
                };
                final updatedHistory = [...widget.service!.statusHistory, newHistoryEntry];
                final newMessage = ChatModel(
                    type:'status',
                    chatterId: widget.currentFirm!.reference!.id,
                    imageUrl: widget.currentFirm?.logo??'',
                    message: '${widget.currentFirm?.name} updated the lead status to $text  ',
                    time: DateTime.now(),
                    dateLabel: DateTime.now(),
                    amount: 0,
                    description: '',
                    requiresAction: false,
                    transactionStatus: ''
                );
                // 2️⃣ Copy existing chat list
                final updatedChatList = List<ChatModel>.from(widget.service!.chat);
                // 3️⃣ Add new message
                updatedChatList.add(newMessage);
                final updatedService = widget.service!.copyWith(statusHistory: updatedHistory,chat:updatedChatList);
                await ref.read(serviceLeadsControllerProvider.notifier)
                    .updateServiceLeads(serviceLeadsModel: updatedService, context: context);

                if (context.mounted) {Navigator.pop(context);
                }
              } catch (e) {
                print('Error updating status: $e');
              }
            }
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Color(0xFF14DFED) : colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width * .025,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }}

/// ---- Lead Type Button ----
Widget leadTypeChip(String emoji, String text, bool selected) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: selected ? Color(0xFF14DFED1A) : Color(0xFFF3F3F3),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: selected ? Color(0xFF14DFED) : Colors.transparent,
        width: 1.6,
      ),
    ),
    child: Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 16)),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

/// ---- Status Pill ----
Widget statusChip(String text, {Color bg = const Color(0xFFF3F3F3)}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
  );
}