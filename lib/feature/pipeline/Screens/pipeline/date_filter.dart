import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:table_calendar/table_calendar.dart';

/// Opens a bottom‑sheet to pick a date range.
/// Returns a Map like:  { 'from': DateTime, 'to': DateTime }
Future<Map<String, DateTime>?> showDateRangeBottomSheet(BuildContext context) async {
  DateTime focusedDay = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;
  bool selectingEnd = false; // true once a start date is chosen

  return showModalBottomSheet<Map<String, DateTime>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          String formattedFrom = startDate != null
              ? DateFormat('dd-MM-yyyy').format(startDate!)
              : 'From';
          String formattedTo = endDate != null
              ? DateFormat('dd-MM-yyyy').format(endDate!)
              : 'To';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select Date Range",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: width * .04,
                        backgroundColor: const Color(0xFFF3F3F3),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * .015),

                /// Row showing currently selected range
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedFrom,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyan),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "→",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formattedTo,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyan),
                    ),
                  ],
                ),

                SizedBox(height: height * .02),

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
                      /// MONTH + YEAR DROPDOWNS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
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
                                value: focusedDay.month,
                                isExpanded: true,
                                items: List.generate(12, (i) {
                                  return DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(_monthName(i + 1)),
                                  );
                                }),
                                onChanged: (m) {
                                  if (m == null) return;
                                  setState(() => focusedDay =
                                      DateTime(focusedDay.year, m, 1));
                                },
                              ),
                            ),
                          ),
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
                                value: focusedDay.year,
                                isExpanded: true,
                                items: List.generate(20, (i) {
                                  final y = 2015 + i;
                                  return DropdownMenuItem(
                                    value: y,
                                    child: Text("$y"),
                                  );
                                }),
                                onChanged: (y) {
                                  if (y == null) return;
                                  setState(() =>
                                  focusedDay = DateTime(y, focusedDay.month, 1));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * .015),

                      // CALENDAR
                      SizedBox(
                        height: 220,
                        child: TableCalendar(
                          firstDay: DateTime.utc(2010, 1, 1),
                          lastDay: DateTime.utc(2050, 1, 1),
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) =>
                          isSameDay(startDate, day) || isSameDay(endDate, day),
                          rangeStartDay: startDate,
                          rangeEndDay: endDate,
                          onDaySelected: (selected, focused) {
                            setState(() {
                              // if no start selected or both selected already -> new range
                              if (startDate == null ||
                                  (startDate != null && endDate != null)) {
                                startDate = selected;
                                endDate = null;
                                selectingEnd = true;
                              } else if (selectingEnd) {
                                // choose end
                                if (selected.isBefore(startDate!)) {
                                  endDate = startDate;
                                  startDate = selected;
                                } else {
                                  endDate = selected;
                                }
                                selectingEnd = false;
                              }
                              focusedDay = focused;
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
                            rangeStartDecoration: BoxDecoration(
                              color: Colors.cyan,
                              shape: BoxShape.circle,
                            ),
                            rangeEndDecoration: BoxDecoration(
                              color: Colors.cyan,
                              shape: BoxShape.circle,
                            ),
                            withinRangeDecoration: BoxDecoration(
                              color: Colors.cyanAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// APPLY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: startDate != null && endDate != null
                        ? () {
                      Navigator.pop(ctx, {
                        'from': startDate!,
                        'to': endDate!,
                      });
                    }
                        : null,
                    child: const Text(
                      "Apply Filter",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Helper for month label
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
