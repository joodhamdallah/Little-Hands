import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class WorkSchedulePage extends StatefulWidget {
  const WorkSchedulePage({super.key});

  @override
  State<WorkSchedulePage> createState() => _WorkSchedulePageState();
}

class _WorkSchedulePageState extends State<WorkSchedulePage> {
  String? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final List<String> weekDays = [
    'السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'
  ];

  List<Map<String, String>> schedules = [];

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
    if (selectedDay != null && startTime != null && endTime != null) {
      schedules.add({
        "day": selectedDay!,
        "start_time": startTime!.format(context),
        "end_time": endTime!.format(context),
      });
      setState(() {
        startTime = null;
        endTime = null;
      });
    }
  }

  void deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

void saveSchedules() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('المستخدم غير مسجل الدخول')),
    );
    return;
  }

  try {
    for (var schedule in schedules) {
      final response = await http.post(
        Uri.parse(saveWorkSchedule),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "day": schedule["day"],
          "start_time": schedule["start_time"],
          "end_time": schedule["end_time"],
        }),
      );

if (response.statusCode != 200 && response.statusCode != 201) {
         print("Response body: ${response.body}");
        throw Exception("فشل في حفظ موعد: ${schedule["day"]}");
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم حفظ جميع المواعيد بنجاح')),
    );

    setState(() {
      schedules.clear(); // افرغ القائمة بعد الحفظ
    });
  } catch (e) {
    print("خطأ أثناء الحفظ: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ خطأ أثناء الحفظ: $e')),
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
              // ✅ اختيار اليوم
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDays.length,
                  itemBuilder: (context, index) {
                    final day = weekDays[index];
                    final isSelected = selectedDay == day;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = day;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF600A) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontFamily: 'NotoSansArabic',
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ✅ اختيار الأوقات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => pickTime(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF600A),
                    ),
                    child: Text(
                      startTime == null ? 'وقت البدء' : 'من: ${startTime!.format(context)}',
                      style: const TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => pickTime(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF600A),
                    ),
                    child: Text(
                      endTime == null ? 'وقت الانتهاء' : 'إلى: ${endTime!.format(context)}',
                      style: const TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('إضافة الموعد', style: TextStyle(fontFamily: 'NotoSansArabic')),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ✅ قائمة المواعيد
              Expanded(
                child: ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          '${schedule['day']} | ${schedule['start_time']} - ${schedule['end_time']}',
                          style: const TextStyle(fontFamily: 'NotoSansArabic'),
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

              // ✅ زر حفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveSchedules,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'حفظ الجدول',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
