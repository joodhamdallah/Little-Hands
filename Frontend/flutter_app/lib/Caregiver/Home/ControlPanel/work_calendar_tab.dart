import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart';

class WorkCalendarTab extends StatefulWidget {
  const WorkCalendarTab({super.key});

  @override
  State<WorkCalendarTab> createState() => _WorkCalendarTabState();
}

class _WorkCalendarTabState extends State<WorkCalendarTab> {
  Set<DateTime> disabledDates = {};
  Set<String> weeklyWorkDays = {};
  Set<DateTime> fullyBookedDates = {};
  Set<DateTime> partiallyBookedDates = {};
  List<Map<String, dynamic>> bookings = [];
  Map<String, dynamic> specificOverrides = {};
  Map<String, dynamic> weeklyPreferences = {};

  Set<DateTime> pendingBookings = {};
  Set<DateTime> acceptedBookings = {};
  Set<DateTime> confirmedBookings = {};

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    await loadPreferences(); // 🧠 Ensures weeklyPreferences is filled
    await fetchBookings(); // ✅ Now safe to use session_type from it
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final specificRes = await http.get(
      Uri.parse('${url}specific-date-preferences'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (specificRes.statusCode == 200) {
      final data = jsonDecode(specificRes.body)['data'];
      for (var item in data) {
        final date = DateTime.parse(item['date']).toLocal();
        final normalized = DateTime(date.year, date.month, date.day);

        final key = _dateKey(normalized);
        if (item['is_disabled'] == true) {
          disabledDates.add(normalized);
        } else {
          specificOverrides[key] = item;
        }
      }
    }

    final weeklyRes = await http.get(
      Uri.parse('${url}weekly-preferences'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (weeklyRes.statusCode == 200) {
      final decoded = jsonDecode(weeklyRes.body);
      final data = decoded['data'];
      if (data != null && data['preferences'] != null) {
        for (var p in data['preferences']) {
          weeklyPreferences[p['day']] = p;
          weeklyWorkDays.add(p['day']);
        }
      }
    }

    setState(() {});
  }

  Future<void> fetchBookings() async {
    fullyBookedDates.clear();
    partiallyBookedDates.clear();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final res = await http.get(
      Uri.parse('${url}caregiver/bookings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'] as List;
      bookings = data.cast<Map<String, dynamic>>();

      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var b in bookings) {
        final date = DateTime.parse(b['session_start_date']);
        final normalized = DateTime(date.year, date.month, date.day);
        switch (b['status']) {
          case 'pending':
            pendingBookings.add(normalized);
            break;
          case 'accepted':
            acceptedBookings.add(normalized);
            break;
          case 'confirmed':
            confirmedBookings.add(normalized);
            break;
        }
        final key = _dateKey(normalized);
        grouped.putIfAbsent(key, () => []).add(b);
      }

      grouped.forEach((key, list) {
        // Only count confirmed bookings
        final confirmedList =
            list.where((b) => b['status'] == 'confirmed').toList();
        if (confirmedList.isEmpty) return; // Skip if none confirmed

        final parts = key.split('-').map((e) => int.parse(e)).toList();
        final day = DateTime(parts[0], parts[1], parts[2]);
        final weekdayName = _getArabicWeekday(day.weekday);

        final sessionType = weeklyPreferences[weekdayName]?['session_type'];

        if (sessionType == 'single') {
          fullyBookedDates.add(day);
          print(
            '🔵 FULLY BOOKED (confirmed/single): $day — ${confirmedList.length}',
          );
        } else if (sessionType == 'multiple') {
          partiallyBookedDates.add(day);
          print(
            '🟡 PARTIALLY BOOKED (confirmed/multiple): $day — ${confirmedList.length}',
          );
        }
      });

      setState(() {});
    }
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "اضغط على أي يوم لتعطيله أو لتعديل المعلومات",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 12),
              TableCalendar(
                locale: 'ar_EG',
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: DateTime.now(),
                availableCalendarFormats: const {CalendarFormat.month: 'الشهر'},
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                onDaySelected: (selectedDay, _) {
                  final normalized = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );
                  _showDayOptionsDialog(normalized);
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    final normalized = DateTime(day.year, day.month, day.day);
                    if (pendingBookings.contains(normalized)) {
                      return _buildCircle(
                        day.day,
                        Colors.orange.shade300,
                        Colors.white,
                      );
                    } else if (acceptedBookings.contains(normalized)) {
                      return _buildCircle(
                        day.day,
                        Colors.blue.shade400,
                        Colors.white,
                      );
                    }
                    // else if (confirmedBookings.contains(normalized)) {
                    //   return _buildCircle(
                    //     day.day,
                    //     Colors.green.shade600,
                    //     Colors.white,
                    //   );
                    // }
                    if (disabledDates.contains(normalized)) {
                      return _buildCircle(day.day, Colors.red, Colors.white);
                    } else if (fullyBookedDates.contains(normalized)) {
                      return _buildCircle(day.day, Colors.green, Colors.white);
                    } else if (partiallyBookedDates.contains(normalized)) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      );
                    } else if (weeklyWorkDays.contains(
                      _getArabicWeekday(day.weekday),
                    )) {
                      return _buildCircle(
                        day.day,
                        Colors.orange.shade200,
                        Colors.black,
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _legendColorBox(Colors.orange.shade300, 'بانتظار ردك'),
                  _legendColorBox(
                    Colors.blue.shade400,
                    'مقبول بانتظار تأكيد الأهل',
                  ),
                  // _legendColorBox(Colors.green.shade600, 'مؤكد'),
                  _legendColorBox(Colors.red, 'يوم معطّل'),
                  _legendColorBox(Colors.green, 'محجوز بالكامل'),
                  _legendBorderBox(Colors.blue, 'محجوز جزئياً'),
                  _legendColorBox(
                    const Color.fromARGB(255, 241, 177, 93),
                    'يوم عمل أسبوعي',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(int day, Color bg, Color textColor) {
    return Container(
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('$day', style: TextStyle(color: textColor)),
    );
  }

  Widget _legendColorBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'NotoSansArabic')),
      ],
    );
  }

  Widget _legendBorderBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'NotoSansArabic')),
      ],
    );
  }

  DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  void _showDayOptionsDialog(DateTime date) async {
    final weekday = _getArabicWeekday(date.weekday);
    final normalized = DateTime(date.year, date.month, date.day);
    final key = _dateKey(normalized);
    final override = specificOverrides[key];
    final week = weeklyPreferences[weekday];

    bool isDisabled = disabledDates.contains(normalized);
    String sessionType =
        override?['session_type'] ?? week?['session_type'] ?? 'single';
    TimeOfDay startTime =
        _parseTime(override?['start_time'] ?? week?['start_time']) ??
        const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime =
        _parseTime(override?['end_time'] ?? week?['end_time']) ??
        const TimeOfDay(hour: 17, minute: 0);

    final sameDayBookings =
        bookings.where((b) {
          final dateObj = DateTime.parse(b['session_start_date']);
          return dateObj.year == date.year &&
              dateObj.month == date.month &&
              dateObj.day == date.day;
        }).toList();

    await showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder:
                  (context, setState) => AlertDialog(
                    title: Text(
                      'اليوم ${date.year}-${date.month}-${date.day}',
                      style: const TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isDisabled,
                              onChanged:
                                  (val) => setState(() => isDisabled = val!),
                            ),
                            const Text(
                              'تعطيل هذا اليوم',
                              style: TextStyle(fontFamily: 'NotoSansArabic'),
                            ),
                          ],
                        ),
                        if (!isDisabled) ...[
                          Row(
                            children: [
                              const Text(
                                'عدد الجلسات:',
                                style: TextStyle(fontFamily: 'NotoSansArabic'),
                              ),
                              const SizedBox(width: 10),
                              DropdownButton<String>(
                                value: sessionType,
                                items:
                                    ['single', 'multiple']
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(
                                              e == 'single'
                                                  ? 'جلسة واحدة'
                                                  : 'أكثر من جلسة',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (val) => setState(() => sessionType = val!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: startTime,
                                    );
                                    if (picked != null)
                                      setState(() => startTime = picked);
                                  },
                                  child: Text(
                                    'وقت البدء: ${startTime.format(context)}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: endTime,
                                    );
                                    if (picked != null)
                                      setState(() => endTime = picked);
                                  },
                                  child: Text(
                                    'وقت الانتهاء: ${endTime.format(context)}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (sameDayBookings.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'الحجوزات في هذا اليوم:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansArabic',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Column(
                            children:
                                sameDayBookings.map((booking) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.orange),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'من ${booking['session_start_time']} إلى ${booking['session_end_time']}',
                                          style: const TextStyle(
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (booking['children_ages'] != null)
                                          Text(
                                            'الأعمار: ${booking['children_ages'].join(', ')}',
                                            style: const TextStyle(
                                              fontFamily: 'NotoSansArabic',
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          final normalized = DateTime(
                            date.year,
                            date.month,
                            date.day,
                          );

                          // 🔴 Immediate visual update
                          setState(() {
                            if (isDisabled) {
                              disabledDates.add(normalized);
                            } else {
                              disabledDates.remove(normalized);
                            }
                          });

                          final data = {
                            'date':
                                DateTime.utc(
                                  date.year,
                                  date.month,
                                  date.day,
                                ).toIso8601String(),
                            'is_disabled': isDisabled,
                            'session_type': sessionType,
                            'start_time': startTime.format(context),
                            'end_time': endTime.format(context),
                          };

                          _saveDatePreference(data);
                          Navigator.pop(context);
                        },

                        child: const Text('حفظ التعديلات'),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }

  Future<void> _saveDatePreference(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    print('📤 Sending PUT: $data');

    final response = await http.put(
      Uri.parse('${url}specific-date-preferences'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    print('✅ Response status: ${response.statusCode}');
    print('✅ Response body: ${response.body}');

    if (response.statusCode == 200) {
      await loadAll(); // refresh prefs + bookings
    } else {
      print('❌ Failed to save date preference');
    }
  }

  String _getArabicWeekday(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return '';
    }
  }

  TimeOfDay? _parseTime(String? str) {
    if (str == null) return null;
    final parts = str.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute =
        int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final isPM = str.toLowerCase().contains('pm');
    return TimeOfDay(
      hour: isPM && hour < 12 ? hour + 12 : hour,
      minute: minute,
    );
  }
}
