import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:refrr_admin/Core/common/textEditingControllers.dart';
import 'package:refrr_admin/Feature/pipeline/Controller/serviceLead-controllor.dart';
import 'package:refrr_admin/models/chatbox-model.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/models/serviceLeadModel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget dateLabel(String date) {
  return Container(
    width: double.infinity, // FULL WIDTH
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Color(0xFFE5E9EB),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          date,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: Color(0xFFE5E9EB),
          ),
        ),
      ],
    ),
  );
}

Widget simpleMessage(String msg, String time,String bgimage) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage:CachedNetworkImageProvider(bgimage),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ⭐ RICH TEXT PARSING
              RichText(
                text: _buildRichText(msg),
              ),

              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
}
TextSpan _buildRichText(String text) {
  // List of all status keywords
  final keywords = [
    "New Lead",
    "Contacted",
    "Interested",
    "Follow-up-needed",
    "Proposal Sent",
    "Negotiation",
    "Converted",
    "Invoice Raised",
    "Work in Progress",
    "Completed",
    "Not Qualified",
    "Lost",
  ];

  // Build a single regex pattern for all keywords, case-insensitive
  final pattern = keywords
      .map((e) => RegExp.escape(e))
      .join('|'); // New Lead|Contacted|...

  final regex = RegExp(pattern, caseSensitive: false);

  // Find all matches
  final matches = regex.allMatches(text).toList();

  // If no keyword found → return normal TextSpan
  if (matches.isEmpty) {
    return TextSpan(
      text: text,
      style: GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  // Build the rich text dynamically
  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (var match in matches) {
    // Add normal text before the match
    if (match.start > lastEnd) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd, match.start),
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      );
    }

    // Add bold text (the matched keyword with actual casing)
    spans.add(
      TextSpan(
        text: match.group(0), // actual matched text
        style: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w800, // bold
          color: Colors.black,
        ),
      ),
    );

    lastEnd = match.end;
  }

  // Add any remaining text at end
  if (lastEnd < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastEnd),
        style: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  return TextSpan(children: spans);
}

Widget messageWithActions(String msg, String time) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ⭐ Profile Image (same as simpleMessage)
        const CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage("assets/user.jpg"),
        ),

        const SizedBox(width: 10),

        /// ⭐ MAIN CONTENT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Rich Text
              RichText(
                text: _buildRichText(msg),
              ),

              const SizedBox(height: 8),

              /// Time Row
              Row(
                children: [
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Reject",
                    style: GoogleFonts.urbanist(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 25),
                  Text(
                    "Accept",
                    style: GoogleFonts.urbanist(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget bottomChatInput({
  required String profileImageUrl,
  required VoidCallback onWalletTap,
  required VoidCallback onRefreshTap,
  required VoidCallback onCalendarTap,
  required VoidCallback onAvatarTap,
  required VoidCallback onSendTap,
  required TextEditingController msgController
}) {
  return Container(
    height: height * .08,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 50,
                  maxWidth: 3000,
                ),
              child: IntrinsicWidth(
                child: TextField(
                  controller: msgController,
                  maxLines: 1,
                  minLines: 1,
                  keyboardType: TextInputType.text,

                  scrollPhysics: const BouncingScrollPhysics(),
                  scrollPadding: EdgeInsets.zero,

                  decoration: InputDecoration(
                    hintText: "Add Your Story Here...",
                    hintStyle: GoogleFonts.urbanist(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                  ),

                  // ⭐ VERY IMPORTANT FOR HORIZONTAL SCROLLING
                  expands: false,
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
          )
          ,
        ),

        const SizedBox(width: 8),
        circleButton(Icons.cached_rounded, onTap: onRefreshTap),
        const SizedBox(width: 8),

        circleButton(Icons.account_balance_wallet_outlined, onTap: onWalletTap),
        const SizedBox(width: 8),

        circleButton(Icons.calendar_month, onTap: onCalendarTap),
        const SizedBox(width: 8),

        /// ---------------- AVATAR OR SEND BUTTON ----------------
        hasText
            ? sendButton(onSendTap)
            : networkAvatar(
          imageUrl: profileImageUrl,
          radius: 16,
          onTap: onAvatarTap,
        ),
      ],
    ),
  );
}

Widget networkAvatar({
  required String imageUrl,
  required double radius,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,

        // When loading
        placeholder: (context, url) => Container(
          width: radius * 2,
          height: radius * 2,
          color: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.grey, size: 20),
        ),

        // When error
        errorWidget: (context, url, error) => Container(
          width: radius * 2,
          height: radius * 2,
          color: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.grey, size: 18),
        ),
      ),
    ),
  );
}

Widget sendButton(VoidCallback onSendTap) {
  return GestureDetector(
    onTap: onSendTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: const Icon(Icons.send, size: 14, color: Colors.white),
    ),
  );
}

Widget circleButton(IconData icon, {required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5E9EB)),
      ),
      child: Icon(icon, size: 16, color: Colors.black),
    ),
  );
}

Widget transactionMessage({
  required String amount,
  required String message,
  required String description,
  required String time,
  required String bgImage
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔵 Avatar
        CircleAvatar(
          radius: 16,
          backgroundImage: CachedNetworkImageProvider(bgImage),
        ),

        const SizedBox(width: 10),

        /// 📝 Message Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ₹1000.00 + main message
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "₹$amount \n",
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00D1FF),
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              /// description
              Text(
                message,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 10),

              /// time
              Row(
                children: [
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    ),
  );
}

///date custom format
String formatDateTime(
    DateTime date, {
      bool showDate = true,
      bool showTime = true,
    }) {
  if (showDate && showTime) {
    return DateFormat("dd/MM/yyyy   hh:mm a").format(date);
  } else if (showDate) {
    return DateFormat("dd/MM/yyyy").format(date);
  } else if (showTime) {
    return DateFormat("hh:mm a").format(date);
  } else {
    return "";
  }
}

///chat screen wallet button
void showAddPaymentSheet(BuildContext context,String name,TextEditingController amountController,
    TextEditingController remarksController,LeadsModel? currentFirm,VoidCallback onTap) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// --- Top small bar ---
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFF49454F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(height: 15),

                /// --- Title ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Money",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "To $name",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
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
                SizedBox(height: 20),

                /// --- Amount Field ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color:  Color(0x1A14DFED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF14DFED)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter Amount",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: height*.03,
                        width: width*.115,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(currentFirm?.currency??'',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: width*.03
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                /// --- Remarks Field ---
                Container(
                  height: height * .055,
                  padding: EdgeInsets.symmetric(horizontal: 9), // add padding here
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFE5E9EB)),
                  ),
                  child: TextField(
                    controller: remarksController,
                    decoration: InputDecoration(
                      hintText: "Remarks..",
                      hintStyle: TextStyle(fontSize: width * .04),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                /// --- Button ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onTap,
                    child: Text(
                      "Add Money",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

///schedule alert box
void showScheduleBottomSheet(BuildContext parentContext,ServiceLeadModel service,
    LeadsModel currentFirm,WidgetRef ref,) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ScheduleBottomSheet(
      onSchedule: (date, event, remarks) async {

        final newMessage = ChatModel(
            type:'schedule',
            chatterId: currentFirm.reference!.id,
            imageUrl: currentFirm.logo??'',
            message:event,
            time: date,
            dateLabel: DateTime.now(),
            amount: 0,
            description: remarks,
            requiresAction: false,
            transactionStatus: ''
        );
        // 2️⃣ Copy existing chat list
        final updatedChatList = List<ChatModel>.from(service.chat);
        // 3️⃣ Add new message
        updatedChatList.add(newMessage);
         final schedule  = service.copyWith(chat: updatedChatList);
        await ref.read(serviceLeadsControllerProvider.notifier)
            .updateServiceLeads(context: parentContext, serviceLeadsModel: schedule,);
        print("DATE: $date");
        print("EVENT: $event");
        print("REMARKS: $remarks");
      },
    ),
  );
}

class ScheduleBottomSheet extends StatefulWidget {
  final Function(DateTime?, String?, String) onSchedule;

  const ScheduleBottomSheet({
    super.key,
    required this.onSchedule,
  });

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}
class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Schedule",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

            SizedBox(height: height * .015),

            /// MONTH + YEAR + CALENDAR BOX
            Container(
              height: height * .41,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// MONTH + YEAR ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// MONTH BOX
                      Container(
                        height: height * .05,
                        width: 131,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _focusedDay.month,
                            isExpanded: true,
                            items: List.generate(12, (i) {
                              return DropdownMenuItem(
                                value: i + 1,
                                child: Text(_monthName(i + 1)),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _focusedDay = DateTime(
                                  _focusedDay.year,
                                  value!,
                                  1,
                                );
                              });
                            },
                          ),
                        ),
                      ),

                      /// YEAR BOX
                      Container(
                        height: height * .05,
                        width: 110,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _focusedDay.year,
                            isExpanded: true,
                            items: List.generate(20, (index) {
                              int year = 2015 + index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text("$year"),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _focusedDay = DateTime(
                                  value!,
                                  _focusedDay.month,
                                  1,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * .015),

                  /// CALENDAR (REDUCED SIZE)
                  SizedBox(
                    height: 220,
                    child: TableCalendar(
                      firstDay: DateTime.utc(2010, 1, 1),
                      lastDay: DateTime.utc(2050, 1, 1),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      },
                      headerVisible: false,
                      daysOfWeekHeight: 22,
                      rowHeight: 32,
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Colors.cyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: height * .015),

            /// EVENT DROPDOWN
            Container(
              height: height * .06,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.black),
                  value: selectedValue,
                  hint: const Text("Select Event"),
                  dropdownColor: Colors.white,

                  selectedItemBuilder: (context) {
                    return ["Call", "Meeting", "Followup", "Remind"]
                        .map((item) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedValue ?? "Select Event",
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList();
                  },

                  items: ["Call", "Meeting", "Followup", "Remind"]
                      .map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item),
                          if (selectedValue == item)
                            const Icon(Icons.check_circle,
                                color: Colors.cyan),
                        ],
                      ),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// REMARKS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: remarksSheduleController,
                decoration: const InputDecoration(
                  hintText: "Remarks..",
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                 onPressed: () {
            widget.onSchedule(
            _selectedDay,
            selectedValue,
            remarksSheduleController.text.trim(),
            );
            Navigator.pop(context);
            },
                child: const Text(
                  "Schedule",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const m = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return m[month - 1];
  }
}

///alertbox
void showHireConfirmation(BuildContext context,String subtitle, VoidCallback onYes) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Title
              const Text(
                "Confirmation",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
               Text(subtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 25),

              /// Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  /// Yes Button
                  GestureDetector(
                    onTap: () {
                      onYes();
                      Navigator.pop(context);
                      // your action here
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      );
    },
  );
}

///whats app and phone call funtions
Future<void> openWhatsApp(String phone) async {
  final Uri url = Uri.parse("https://wa.me/$phone");

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception("Could not open WhatsApp");
  }
}
Future<void> callNumber(String phoneNumber) async {
  final String cleanedNumber = phoneNumber.replaceAll(" ", "");
  final Uri url = Uri.parse("tel:$cleanedNumber");

  if (!await launchUrl(url)) {
    throw Exception("Could not launch phone dialer");
  }
}

///hide delete alert box
void showHideDeleteMenu(
    BuildContext context,
    Offset position, {
      VoidCallback? onHide,
      VoidCallback? onDelete,
    }) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy - 10, 40, 40),
      Offset.zero & overlay.size,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    color: Colors.white,
    items: [
      // PopupMenuItem(
      //   onTap: onHide,
      //   child: Row(
      //     children: [
      //       Icon(Icons.visibility_off_outlined, color: Colors.black),
      //       SizedBox(width: 10),
      //       Text("Hide", style: TextStyle(color: Colors.black)),
      //     ],
      //   ),
      // ),
      PopupMenuItem(
        onTap: onDelete,
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 10),
            Text("Delete", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ],
  );
}
Widget chatItem(ChatModel msg) {
  switch (msg.type) {
    case "simple":
      return simpleMessage(
        msg.message ?? "",
        formatDateTime(msg.time ?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );

    case "status":
      return simpleMessage(
        msg.message ?? "",
        formatDateTime(msg.time?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );
      case "sales":
      return simpleMessage(
        msg.message ?? "",
        formatDateTime(msg.time?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );
    case "schedule":
      return simpleMessage(
        getMessageText(msg.message, msg.time.toString(),msg.description) ?? "",
        formatDateTime(msg.dateLabel?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );
    case "type":
      return simpleMessage(
        msg.message ?? "",
        formatDateTime(msg.time?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );

    case "transaction":
      return transactionMessage(
        amount: msg.amount.toString(),
        message: msg.message ?? "",
        description: msg.description ?? "",
        time: formatDateTime(msg.time?? DateTime.now(), showDate: false),
        bgImage: msg.imageUrl ??'',
      );

    default:
      return SizedBox.shrink();
  }
}

String getMessageText(String? msg, String date,String? description) {
  final formattedDate = formatDateOnly(date);

  // Add a space + description only if it's not null/empty
  final descText = (description != null && description.isNotEmpty)
      ? ". $description"
      : "";

  switch (msg) {
    case "Meeting":
      return "A meeting has been scheduled on $formattedDate$descText.";

    case "Remind":
      return "A reminder has been set for $formattedDate$descText.";

    case "Followup":
      return "A follow-up has been scheduled on $formattedDate$descText.";

    case "Call":
      return "A call has been scheduled on $formattedDate$descText.";

    default:
      return msg ?? "";
  }
}

String formatDateOnly(String dateString) {
  try {
    final dateTime = DateTime.parse(dateString);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return "$day-$month-$year";
  } catch (e) {
    return dateString; // fallback if parse fails
  }
}
Map<String, String> leadTypeIcons = {
  "Hot": "assets/svg/fireimogi.svg",
  "Warm": "assets/svg/warmimogi.svg",
  "Cool": "assets/svg/specsimogi.svg",
};

Widget buildTypeMessage(String? msg) {
  final message = msg ?? "";

  // Check if the message is one of the types
  final svgPath = leadTypeIcons[message];

  if (svgPath != null) {
    // If it's Hot/Warm/Cool, show SVG + text inline
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: SvgPicture.asset(
              svgPath,
              height: 18,
              width: 18,
            ),
            alignment: PlaceholderAlignment.middle,
          ),
          const WidgetSpan(child: SizedBox(width: 6)),
          TextSpan(
            text: message,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  } else {
    // If it's any other message, just show the text
    return Text(
      message,
      style: const TextStyle(fontSize: 14, color: Colors.black),
    );
  }
}
