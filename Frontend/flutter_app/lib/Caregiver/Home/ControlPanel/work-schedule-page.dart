
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart' as intl;

class WorkSchedulePage extends StatefulWidget {
  const WorkSchedulePage({super.key});

  @override
  State<WorkSchedulePage> createState() => _WorkSchedulePageState();
}

class _WorkSchedulePageState extends State<WorkSchedulePage> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String selectedType = 'work';
  List<Map<String, dynamic>> schedules = [];
  Map<String, dynamic> weeklyPreferences = {};
  List<Map<String, dynamic>> confirmedBookings = [];
  bool showBookings = false;

  @override
  void initState() {
    super.initState();
    fetchSchedules();
    fetchWeeklyPreferences();
    fetchConfirmedBookings();
  }

  Future<void> fetchSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.get(
      Uri.parse(saveWorkSchedule),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        schedules = List<Map<String, dynamic>>.from(data['schedules']);
      });
    }
  }

  Future<void> fetchWeeklyPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${url}weekly-preferences'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        weeklyPreferences = Map<String, dynamic>.from(data['preferences']);
      });
    }
  }

  Future<void> fetchConfirmedBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${url}caregiver/bookings'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        confirmedBookings = List<Map<String, dynamic>>.from(
          data['data'].where((b) => b['status'] == 'confirmed'),
        );
      });
    }
  }

  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  TimeOfDay parseTimeOfDay(String timeString) {
    final format = intl.DateFormat.jm();
    final dt = format.parse(timeString);
    return TimeOfDay.fromDateTime(dt);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayString =
        selectedDate != null
            ? intl.DateFormat('EEEE', 'ar').format(selectedDate!)
            : '';
    final weeklyInfo =
        selectedDayString.isNotEmpty
            ? weeklyPreferences[selectedDayString]
            : null;

    final dateBookings =
        selectedDate != null
            ? confirmedBookings
                .where(
                  (b) => (b['session_start_date'] ?? '').startsWith(
                    intl.DateFormat('yyyy-MM-dd').format(selectedDate!),
                  ),
                )
                .toList()
            : [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('إدارة جدول العمل'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TableCalendar(
                locale: 'ar',
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: selectedDate ?? DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                onDaySelected: (day, _) async {
                  setState(() => selectedDate = day);
                  final dayName = intl.DateFormat('EEEE', 'ar').format(day);
                  final weekly = weeklyPreferences[dayName];
                  final bookings =
                      confirmedBookings
                          .where(
                            (b) => (b['session_start_date'] ?? '').startsWith(
                              intl.DateFormat('yyyy-MM-dd').format(day),
                            ),
                          )
                          .toList();

                  await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(
                            'تفاصيل ${intl.DateFormat('dd-MM-yyyy').format(day)}',
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (weekly != null)
                                  Text(
                                    '🕒 ساعات العمل: ${weekly['start_time']} - ${weekly['end_time']}',
                                  ),
                                const SizedBox(height: 10),
                                if (bookings.isNotEmpty) ...[
                                  const Text(
                                    '📌 الحجوزات المؤكدة:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  for (var b in bookings)
                                    Text(
                                      'من ${b['session_start_time']} إلى ${b['session_end_time']}',
                                    ),
                                ] else
                                  const Text('لا توجد حجوزات في هذا اليوم.'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إغلاق'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final pickedStart = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedStart == null) return;

                                final pickedEnd = await showTimePicker(
                                  context: context,
                                  initialTime: pickedStart.replacing(
                                    hour: pickedStart.hour + 1,
                                  ),
                                );
                                if (pickedEnd == null) return;

                                final newMeeting = {
                                  "date": intl.DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(day),
                                  "day": intl.DateFormat(
                                    'EEEE',
                                    'ar',
                                  ).format(day),
                                  "start_time": pickedStart.format(context),
                                  "end_time": pickedEnd.format(context),
                                  "type": 'meeting',
                                };
                                final dayStr = intl.DateFormat(
                                  'yyyy-MM-dd',
                                ).format(day);
                                final startMin =
                                    pickedStart.hour * 60 + pickedStart.minute;
                                final endMin =
                                    pickedEnd.hour * 60 + pickedEnd.minute;
                                final overlap = confirmedBookings.any((b) {
                                  if ((b['session_start_date'] ?? '')
                                      .startsWith(dayStr)) {
                                    final bStart = parseTimeOfDay(
                                      b['session_start_time'],
                                    );
                                    final bEnd = parseTimeOfDay(
                                      b['session_end_time'],
                                    );
                                    final bStartMin =
                                        bStart.hour * 60 + bStart.minute;
                                    final bEndMin =
                                        bEnd.hour * 60 + bEnd.minute;
                                    return startMin < bEndMin &&
                                        endMin > bStartMin;
                                  }
                                  return false;
                                });

                                if (overlap) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '⚠️ هذا الموعد يتداخل مع جلسة محجوزة بالفعل.',
                                      ),
                                    ),
                                  );
                                }

                                setState(() => schedules.add(newMeeting));
                                Navigator.pop(context);
                              },
                              child: const Text('➕ إضافة موعد لقاء'),
                            ),
                          ],
                        ),
                  );
                },
                calendarFormat: CalendarFormat.week,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFFFF600A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (selectedDate != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📅 ${intl.DateFormat('dd-MM-yyyy').format(selectedDate!)}',
                    ),
                    Switch(
                      value: showBookings,
                      onChanged: (val) => setState(() => showBookings = val),
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (weeklyInfo != null)
                  Text(
                    '🕒 ساعات العمل: ${weeklyInfo['start_time']} - ${weeklyInfo['end_time']}',
                  ),
                if (showBookings && dateBookings.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  const Text(
                    '📌 حجوزات هذا اليوم:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  for (var b in dateBookings)
                    Text(
                      'من ${b['session_start_time']} إلى ${b['session_end_time']}',
                    ),
                ],
              ],
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final s = schedules[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          '${s['day']} - ${s['date']} | ${s['start_time']} - ${s['end_time']} (${s['type'] == 'meeting' ? 'لقاء' : 'عمل'})',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteSchedule(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: saveSchedules,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF600A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'حفظ الجدول',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteSchedule(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final schedule = schedules[index];
    if (schedule.containsKey('_id')) {
      final id = schedule['_id'];
      final response = await http.delete(
        Uri.parse('$deleteWorkSchedule/$id'),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في حذف الموعد من الباكند')),
        );
        return;
      }
    }
    setState(() => schedules.removeAt(index));
  }

  void saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    try {
      for (var schedule in schedules) {
        if (schedule.containsKey('_id')) continue;
        final response = await http.post(
          Uri.parse(saveWorkSchedule),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: json.encode({
            "day": schedule["day"],
            "date": schedule["date"],
            "start_time": schedule["start_time"],
            "end_time": schedule["end_time"],
            "type": schedule["type"],
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final saved = json.decode(response.body)['data'];
          schedule['_id'] = saved['_id'];
        } else {
          throw Exception("خطأ في الحفظ");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ جميع المواعيد بنجاح')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
    }
  }
}
