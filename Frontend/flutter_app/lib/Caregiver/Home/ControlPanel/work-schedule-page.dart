import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    fetchSchedules(); // جلب المواعيد المحفوظة عند الفتح
  }

  Future<void> fetchSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return;

    final response = await http.get(
      Uri.parse(saveWorkSchedule),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        schedules = List<Map<String, dynamic>>.from(data['schedules']);
      });
    } else {
      print("❌ فشل في جلب المواعيد");
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

  void addSchedule() {
    if (selectedDate != null && startTime != null && endTime != null) {
      schedules.add({
        "date": DateFormat('yyyy-MM-dd').format(selectedDate!),
        "day": DateFormat('EEEE', 'ar').format(selectedDate!),
        "start_time": startTime!.format(context),
        "end_time": endTime!.format(context),
        "type": selectedType,
      });
      setState(() {
        startTime = null;
        endTime = null;
      });
    }
  }

  void deleteSchedule(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final schedule = schedules[index];

    // إذا كان الموعد يحتوي على id نحذفه من الباكند
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

    setState(() {
      schedules.removeAt(index);
    });
  }

  void saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    try {
      for (var schedule in schedules) {
        if (schedule.containsKey('_id')) continue; // تم حفظه مسبقًا

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
          schedule['_id'] = saved['_id']; // أضف المعرف
        } else {
          throw Exception("خطأ في الحفظ");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ جميع المواعيد بنجاح')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('إدارة جدول العمل'),
          centerTitle: true,
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TableCalendar(
                locale: 'ar',
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: selectedDate ?? DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                onDaySelected: (day, _) {
                  setState(() {
                    selectedDate = day;
                  });
                },
                calendarFormat: CalendarFormat.week,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(color: Color(0xFFFF600A), shape: BoxShape.circle),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("نوع الموعد:"),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedType,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                    items: const [
                      DropdownMenuItem(value: 'work', child: Text('عمل')),
                      DropdownMenuItem(value: 'meeting', child: Text('لقاء')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => pickTime(true),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF600A)),
                    child: Text(startTime == null ? 'وقت البدء' : 'من: ${startTime!.format(context)}'),
                  ),
                  ElevatedButton(
                    onPressed: () => pickTime(false),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF600A)),
                    child: Text(endTime == null ? 'وقت الانتهاء' : 'إلى: ${endTime!.format(context)}'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: addSchedule,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('إضافة الموعد'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final s = schedules[index];
                     String readableDate;
                      try {
                       if (s['date'] != null && s['date'] is String) {
                          try {
                            final parsedDate = DateTime.parse(s['date']);
                            readableDate = DateFormat('dd-MM-yyyy').format(parsedDate);
                          } catch (_) {
                            readableDate = s['date'].toString(); // إذا كان التاريخ غير قابل للقراءة
                          }
                        } else {
                          readableDate = 'غير معروف';
                        }

                      } catch (_) {
                        readableDate = s['date']; // في حال لم يكن نصًا بصيغة صحيحة
                      }
                   return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          '${s['day']} - $readableDate | ${s['start_time']} - ${s['end_time']} (${s['type'] == 'meeting' ? 'لقاء' : 'عمل'})',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'حفظ الجدول',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
