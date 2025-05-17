// ✅ Full working version with guided flexibility
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailableAppointmentsPage extends StatefulWidget {
  final String babysitterId;
  final Map<String, dynamic> jobDetails;

  const AvailableAppointmentsPage({
    Key? key,
    required this.babysitterId,
    required this.jobDetails,
  }) : super(key: key);

  @override
  State<AvailableAppointmentsPage> createState() =>
      _AvailableAppointmentsPageState();
}

class _AvailableAppointmentsPageState extends State<AvailableAppointmentsPage> {
  Set<DateTime> bookedDays = {};
  Map<String, dynamic> weeklyPreferences = {};
  Map<String, dynamic> specificOverrides = {};

  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  @override
  void initState() {
    super.initState();
    fetchAvailabilityData();
  }

  Future<void> fetchAvailabilityData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final weeklyRes = await http.get(
      Uri.parse('${url}weekly-preferences/${widget.babysitterId}'),
    );

    final specificRes = await http.get(
      Uri.parse('${url}specific-date-preferences/${widget.babysitterId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (weeklyRes.statusCode == 200) {
      final data = jsonDecode(weeklyRes.body)['data'];
      for (var pref in data['preferences']) {
        weeklyPreferences[pref['day']] = pref;
      }
    }

    if (specificRes.statusCode == 200) {
      final data = jsonDecode(specificRes.body)['data'];
      for (var pref in data) {
        final key = _dateKey(DateTime.parse(pref['date']));
        specificOverrides[key] = pref;
      }
    }

    setState(() {});
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  String _weekdayName(DateTime date) {
    const days = [
      '', // Placeholder for index 0 (Dart weekdays start at 1)
      'الإثنين', // 1
      'الثلاثاء', // 2
      'الأربعاء', // 3
      'الخميس', // 4
      'الجمعة', // 5
      'السبت', // 6
      'الأحد', // 7
    ];
    return days[date.weekday]; // weekday is from 1–7
  }

  bool isDateAvailable(DateTime date) {
    final key = _dateKey(date);
    if (specificOverrides.containsKey(key)) {
      return specificOverrides[key]['is_disabled'] != true;
    }
    return weeklyPreferences.containsKey(_weekdayName(date));
  }

  TimeOfDay? _parseTime(String? str) {
    if (str == null) return null;
    final parts = str.split(':');
    final hour = int.parse(parts[0]);
    final minute =
        int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool isOutsideWorkingHours(DateTime date, TimeOfDay start) {
    final key = _dateKey(date);
    final override = specificOverrides[key];
    final fallback = weeklyPreferences[_weekdayName(date)];

    final startTimeStr = override?['start_time'] ?? fallback?['start_time'];
    final endTimeStr = override?['end_time'] ?? fallback?['end_time'];

    if (startTimeStr == null || endTimeStr == null) return true;

    final startMinutes = start.hour * 60 + start.minute;
    final definedStart = _parseTime(startTimeStr)!;
    final definedEnd = _parseTime(endTimeStr)!;

    final windowStart = definedStart.hour * 60 + definedStart.minute;
    final windowEnd = definedEnd.hour * 60 + definedEnd.minute;

    return startMinutes < windowStart || startMinutes >= windowEnd;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('حجز جلسة'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TableCalendar(
                locale: 'ar_EG',
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: DateTime.now(),
                selectedDayPredicate:
                    (day) =>
                        selectedDate != null && isSameDay(selectedDate!, day),
                onDaySelected: (day, _) {
                  if (!isDateAvailable(day)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❗ هذا اليوم غير متاح')),
                    );
                    return;
                  }
                  setState(() {
                    selectedDate = day;
                    selectedStartTime = null;
                    selectedEndTime = null;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    final weekday = _weekdayName(day);
                    final isWeeklyWorkingDay = weeklyPreferences.containsKey(
                      weekday,
                    );
                    final isSpecificDisabled =
                        specificOverrides[_dateKey(day)]?['is_disabled'] ==
                        true;

                    if (isSpecificDisabled) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (isWeeklyWorkingDay) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }

                    return null;
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  weekendTextStyle: TextStyle(fontFamily: 'NotoSansArabic'),
                  defaultTextStyle: TextStyle(fontFamily: 'NotoSansArabic'),
                  todayDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFFF600A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ما معنى الألوان في التقويم؟',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _legendRow(Colors.red.shade300, 'يوم معطل من قبل المربية'),
                    _legendRow(
                      Colors.orange.shade200,
                      'يوم عمل محدد في الجدول الأسبوعي',
                    ),
                    _legendRow(Colors.blue, 'يوم محجوز مسبقاً'),
                    _legendRow(Colors.orange, 'اليوم الحالي'),
                    _legendRow(
                      const Color(0xFFFF600A),
                      'اليوم الذي قمت باختياره',
                    ),
                    if (weeklyPreferences.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'أيام العمل الأسبوعية:',
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          for (var day in weeklyPreferences.entries)
                            Text(
                              '• ${day.key}: من ${day.value['start_time']} إلى ${day.value['end_time']}',
                              style: const TextStyle(
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              if (selectedDate != null) ...[
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (picked != null) {
                      final warn = isOutsideWorkingHours(selectedDate!, picked);
                      setState(() => selectedStartTime = picked);
                      if (warn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ هذا الوقت خارج ساعات العمل'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    selectedStartTime == null
                        ? 'اختر وقت البدء'
                        : 'وقت البدء: ${selectedStartTime!.format(context)}',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      selectedStartTime == null
                          ? null
                          : () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: selectedStartTime!.hour + 1,
                                minute: 0,
                              ),
                            );
                            if (picked != null) {
                              setState(() => selectedEndTime = picked);
                            }
                          },
                  child: Text(
                    selectedEndTime == null
                        ? 'اختر وقت الانتهاء'
                        : 'وقت الانتهاء: ${selectedEndTime!.format(context)}',
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (selectedDate != null &&
                  selectedStartTime != null &&
                  selectedEndTime != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                  ),
                  onPressed: sendBookingRequest,
                  label: const Text('إرسال الطلب'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void sendBookingRequest() async {
    final bookingData = {
      ...widget.jobDetails,
      'caregiver_id': widget.babysitterId,
      'service_type': 'babysitter',
      'session_start_date':
          DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
          ).toUtc().toIso8601String(),
      'session_start_time': selectedStartTime!.format(context),
      'session_end_time': selectedEndTime!.format(context),
    };

    // Print for debug
    print("📤 Booking request: $bookingData");

    // Optionally send to backend here
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final res = await http.post(
      Uri.parse(saveBooking),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bookingData),
    );

    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📩 تم إرسال طلب الجلسة للمربية")),
      );
      // Navigate or reset state if needed
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ فشل في إرسال الطلب")));
    }
  }

  Widget _legendRow(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(label, style: const TextStyle(fontFamily: 'NotoSansArabic')),
        ],
      ),
    );
  }
}
