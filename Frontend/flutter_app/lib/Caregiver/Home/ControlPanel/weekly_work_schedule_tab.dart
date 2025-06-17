import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart';

class WeeklyWorkScheduleTab extends StatefulWidget {
  const WeeklyWorkScheduleTab({super.key});

  @override
  State<WeeklyWorkScheduleTab> createState() => _WeeklyWorkScheduleTabState();
}

class _WeeklyWorkScheduleTabState extends State<WeeklyWorkScheduleTab> {
  bool showInstructions = true;

  List<String> weekDays = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  List<Map<String, dynamic>> weeklySchedule = [];

  @override
  void initState() {
    super.initState();
    weeklySchedule = List.generate(7, (index) {
      return {
        'day': weekDays[index],
        'enabled': false,
        'sessionType': 'single',
        'startTime': null,
        'endTime': null,
      };
    });
    _loadFromAPI();
  }

  Future<void> _loadFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${url}weekly-preferences'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List fetchedPrefs = data['data']?['preferences'] ?? [];

      for (var pref in fetchedPrefs) {
        int index = weekDays.indexOf(pref['day']);
        if (index != -1) {
          weeklySchedule[index] = {
            'day': pref['day'],
            'enabled': true,
            'sessionType': pref['session_type'],
            'startTime': _parseTime(pref['start_time']),
            'endTime': _parseTime(pref['end_time']),
          };
        }
      }
      setState(() {});
    }
  }

  TimeOfDay? _parseTime(String? str) {
    if (str == null) return null;
    final parts = str.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(' ')[0]);
    if (str.contains('PM') && hour < 12) hour += 12;
    if (str.contains('AM') && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _handleSaveSchedule() async {
    final enabledDays =
        weeklySchedule.where((day) => day['enabled'] == true).map((day) {
          if (day['startTime'] == null || day['endTime'] == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى تحديد الوقت لجميع الأيام المُفعلة'),
              ),
            );
            throw Exception("Missing time for ${day['day']}");
          }

          return {
            'day': day['day'],
            'session_type': day['sessionType'],
            'start_time': day['startTime'].format(context),
            'end_time': day['endTime'].format(context),
          };
        }).toList();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return;

    final response = await http.post(
      Uri.parse('${url}weekly-preferences'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'preferences': enabledDays}),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ تم حفظ الجدول بنجاح')));
    } else {
      print('❌ Error: ${response.body}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء حفظ الجدول')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showInstructions) ...[
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'يرجى تحديد الأيام التي ترغب في العمل بها أسبوعياً. يمكنك تفعيل أو تعطيل اليوم، اختيار عدد الجلسات في هذا اليوم وتحديد وقت البدء والانتهاء للعمل',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansArabic',
                color: Color(0xFFFF600A),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إرشادات إضافية:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => showInstructions = false),
                  icon: const Icon(Icons.expand_less, color: Color(0xFFFF600A)),
                  label: const Text(
                    'إخفاء',
                    style: TextStyle(
                      color: Color(0xFFFF600A),
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '• لتفعيل اليوم، اضغط على زر "تفعيل" بجانب اليوم الذي ترغب بالعمل فيه.\n'
              '• بعد التفعيل، يمكنك اختيار عدد الجلسات التي ترغب في تقديمها في ذلك اليوم (جلسة واحدة أو أكثر).\n'
              '• ثم حدد وقت البدء والانتهاء للعمل في ذلك اليوم.',
              style: TextStyle(
                fontSize: 13,
                height: 1.7,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => showInstructions = true),
                icon: const Icon(Icons.expand_more, color: Color(0xFFFF600A)),
                label: const Text(
                  'عرض الإرشادات',
                  style: TextStyle(
                    color: Color(0xFFFF600A),
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
            ),
          ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = weeklySchedule[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        activeColor: const Color(0xFFFF600A),
                        title: Text(
                          day['day'],
                          style: const TextStyle(fontFamily: 'NotoSansArabic'),
                        ),
                        value: day['enabled'],
                        onChanged:
                            (val) => setState(() => day['enabled'] = val),
                      ),
                      if (day['enabled']) ...[
                        Row(
                          children: [
                            const Text(
                              'عدد الجلسات:',
                              style: TextStyle(fontFamily: 'NotoSansArabic'),
                            ),
                            const SizedBox(width: 10),
                            DropdownButton<String>(
                              value: day['sessionType'],
                              items:
                                  ['single', 'multiple'].map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type == 'single'
                                            ? 'جلسة واحدة'
                                            : 'أكثر من جلسة',
                                        style: const TextStyle(
                                          fontFamily: 'NotoSansArabic',
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => day['sessionType'] = val),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() => day['startTime'] = picked);
                                }
                              },
                              child: Text(
                                day['startTime'] != null
                                    ? 'وقت البدء: ${day['startTime'].format(context)}'
                                    : 'وقت البدء',
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  final start = day['startTime'];
                                  if (start != null &&
                                      (picked.hour * 60 + picked.minute) <=
                                          (start.hour * 60 + start.minute)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'وقت الانتهاء يجب أن يكون بعد وقت البدء في ${day['day']}',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => day['endTime'] = picked);
                                }
                              },
                              child: Text(
                                day['endTime'] != null
                                    ? 'وقت الانتهاء: ${day['endTime'].format(context)}'
                                    : 'وقت الانتهاء',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              onPressed: _handleSaveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF600A),
                padding: const EdgeInsets.all(12),
                iconColor: Colors.white,
              ),
              label: const Text(
                'حفظ الجدول',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
