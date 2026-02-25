import 'package:flutter/material.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/text_editing_controllers.dart';
import 'package:refrr_admin/core/utils/month_list.dart';
import 'package:table_calendar/table_calendar.dart';

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
                                child: Text(monthName(i + 1)),
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

}