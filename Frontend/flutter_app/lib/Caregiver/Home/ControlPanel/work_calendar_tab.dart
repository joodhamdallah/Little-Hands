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
  Set<DateTime> bookedDates = {};
  Set<String> weeklyWorkDays = {};

  Map<String, dynamic> specificOverrides = {};
  Map<String, dynamic> weeklyPreferences = {};

  @override
  void initState() {
    super.initState();
    loadPreferences();
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
        final date = DateTime.parse(item['date']);
        final key = _dateKey(date);
        if (item['is_disabled'] == true) {
          disabledDates.add(date);
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
        final prefsList = data['preferences'];
        if (prefsList is List) {
          for (var p in prefsList) {
            weeklyPreferences[p['day']] = p;
            weeklyWorkDays.add(p['day']); // ➕ Add the Arabic weekday
          }
        }
      }
    }

    setState(() {});
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              availableCalendarFormats: const {CalendarFormat.month: 'الشهر'},
              headerStyle: const HeaderStyle(formatButtonVisible: false),

              locale: 'ar_EG',
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: DateTime.now(),
              onDaySelected: (selectedDay, _) {
                _showDayOptionsDialog(selectedDay);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isDisabled = disabledDates.contains(day);
                  final isBooked = bookedDates.contains(day);
                  final isWeeklyWorkDay = weeklyWorkDays.contains(
                    _getArabicWeekday(day.weekday),
                  );

                  if (isDisabled) {
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
                  } else if (isBooked) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    );
                  } else if (isWeeklyWorkDay) {
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
            ),
            const SizedBox(height: 16),
            const Text(
              "ملاحظة:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'NotoSansArabic',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legendColorBox(Colors.red, 'يوم معطّل'),
                SizedBox(width: 12),
                _legendBorderBox(Colors.blue, 'يوم محجوز'),
                SizedBox(width: 12),
                _legendColorBox(Colors.orangeAccent, 'يوم عمل أسبوعي'),
              ],
            ),
          ],
        ),
      ),
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

  void _showDayOptionsDialog(DateTime date) async {
    final weekdayName = _getArabicWeekday(date.weekday);
    final key = _dateKey(date);
    final override = specificOverrides[key];
    final defaultWeek = weeklyPreferences[weekdayName];
    if (override == null && defaultWeek == null) {
      // Nothing defined for this date, show a message or just return
      return;
    }
    bool isDisabled = disabledDates.contains(date);
    String sessionType =
        override?['session_type'] ?? defaultWeek?['session_type'] ?? 'single';
    TimeOfDay startTime =
        _parseTime(override?['start_time'] ?? defaultWeek?['start_time']) ??
        const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime =
        _parseTime(override?['end_time'] ?? defaultWeek?['end_time']) ??
        const TimeOfDay(hour: 17, minute: 0);

    await showDialog(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder:
                  (context, setLocalState) => AlertDialog(
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
                                  (val) =>
                                      setLocalState(() => isDisabled = val!),
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
                              const SizedBox(width: 12),
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
                                              style: const TextStyle(
                                                fontFamily: 'NotoSansArabic',
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged:
                                    (val) =>
                                        setLocalState(() => sessionType = val!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                                      setLocalState(() => startTime = picked);
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
                                      setLocalState(() => endTime = picked);
                                  },
                                  child: Text(
                                    'وقت الانتهاء: ${endTime.format(context)}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(fontFamily: 'NotoSansArabic'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final body = {
                            'date': date.toIso8601String(),
                            'is_disabled': isDisabled,
                            'session_type': sessionType,
                            'start_time': startTime.format(context),
                            'end_time': endTime.format(context),
                          };
                          _saveDatePreference(body);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'حفظ التعديلات',
                          style: TextStyle(fontFamily: 'NotoSansArabic'),
                        ),
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
    await http.put(
      Uri.parse('${url}specific-date-preferences'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    loadPreferences();
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
    return TimeOfDay(hour: isPM ? hour + 12 : hour, minute: minute);
  }
}
