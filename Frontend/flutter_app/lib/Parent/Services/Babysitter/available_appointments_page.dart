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

  Set<DateTime> fullyBookedDays = {};
  Set<DateTime> partiallyBookedDays = {};
  Map<String, String> dailySessionType = {}; // e.g., { 'الإثنين': 'single' }

  Map<String, dynamic> weeklyPreferences = {};
  Map<String, dynamic> specificOverrides = {};

  Map<String, List<Map<String, String>>> existingBookings = {};

  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  bool showTimeSelector = false;

  @override
  void initState() {
    super.initState();
    fetchAvailabilityData();
  }

  Future<void> fetchAvailabilityData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    print("📨 Fetching bookings for caregiver ID: ${widget.babysitterId}");

    // 1. Fetch bookings
    final bookingRes = await http.get(
      Uri.parse('${url}bookings/caregiver/${widget.babysitterId}'),
    );

    // 2. Fetch weekly preferences
    final weeklyRes = await http.get(
      Uri.parse('${url}weekly-preferences/${widget.babysitterId}'),
    );

    // 3. Fetch specific date overrides
    final specificRes = await http.get(
      Uri.parse('${url}specific-date-preferences/${widget.babysitterId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // ✅ Handle weekly preferences
    if (weeklyRes.statusCode == 200) {
      final data = jsonDecode(weeklyRes.body)['data'];
      for (var pref in data['preferences']) {
        weeklyPreferences[pref['day']] = pref;
        dailySessionType[pref['day']] = pref['session_type'] ?? 'single';
      }
    }

    // ✅ Handle specific date overrides
    if (specificRes.statusCode == 200) {
      final data = jsonDecode(specificRes.body)['data'];
      for (var pref in data) {
        final key = _dateKey(DateTime.parse(pref['date']));
        specificOverrides[key] = pref;
      }
    }

    // ✅ Handle bookings
    if (bookingRes.statusCode == 200) {
      final data = jsonDecode(bookingRes.body)['data'];
      for (var booking in data) {
        if (booking['session_start_date'] != null &&
            booking['session_start_time'] != null &&
            booking['session_end_time'] != null) {
          final date = DateTime.parse(booking['session_start_date']);
          final key = _dateKey(date);
          final weekday = _weekdayName(date);
          final type = dailySessionType[weekday];

          // Track booked time ranges
          existingBookings.putIfAbsent(key, () => []);
          existingBookings[key]!.add({
            'start': booking['session_start_time'],
            'end': booking['session_end_time'],
          });

          if (type == 'single') {
            fullyBookedDays.add(DateTime(date.year, date.month, date.day));
          } else {
            partiallyBookedDays.add(DateTime(date.year, date.month, date.day));
          }
        }

        if (booking['session_days'] != null &&
            booking['session_end_date'] != null) {
          final end = DateTime.parse(booking['session_end_date']);
          final days = List<String>.from(booking['session_days']);
          for (int i = 0; i <= end.difference(DateTime.now()).inDays; i++) {
            final d = DateTime.now().add(Duration(days: i));
            final name = _weekdayName(d);
            if (days.contains(name)) {
              final type = dailySessionType[name];
              if (type == 'single') {
                fullyBookedDays.add(DateTime(d.year, d.month, d.day));
              } else {
                partiallyBookedDays.add(DateTime(d.year, d.month, d.day));
              }
            }
          }
        }
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

    try {
      final timeParts = str.split(' ');
      if (timeParts.length != 2) return null;

      final hourMinute = timeParts[0].split(':');
      if (hourMinute.length != 2) return null;

      int hour = int.parse(hourMinute[0]);
      int minute = int.parse(hourMinute[1]);
      String period = timeParts[1].toUpperCase();

      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("❌ Error parsing time string: $str");
      return null;
    }
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
                onDaySelected: onDaySelected,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    final dateKey = _dateKey(day);
                    final weekday = _weekdayName(day);
                    final isWeeklyWorkingDay = weeklyPreferences.containsKey(
                      weekday,
                    );
                    final isSpecificDisabled =
                        specificOverrides[dateKey]?['is_disabled'] == true;

                    final normalizedDay = DateTime(
                      day.year,
                      day.month,
                      day.day,
                    );
                    final isFullyBooked = fullyBookedDays.contains(
                      normalizedDay,
                    );

                    final isPartiallyBooked = partiallyBookedDays.contains(
                      DateTime(day.year, day.month, day.day),
                    );

                    if (isSpecificDisabled) {
                      return _buildDayCell(day, Colors.red, Colors.white);
                    }

                    if (isFullyBooked) {
                      return _buildDayCell(
                        day,
                        Colors.blue,
                        Colors.white,
                      ); // ✅ fully booked = blue
                    }

                    if (isPartiallyBooked) {
                      return _buildDayCell(
                        day,
                        Colors.lightBlueAccent,
                        Colors.black,
                      ); // ✅ partially booked = light blue
                    }

                    if (isWeeklyWorkingDay) {
                      return _buildDayCell(
                        day,
                        Colors.orange.shade200,
                        Colors.black,
                      ); // working day = orange
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
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFFF600A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (showTimeSelector && selectedDate != null)
                _buildTimePickerCard(),
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
                    _legendRow(Colors.red, 'يوم معطل من قبل المربية'),
                    _legendRow(
                      Colors.orange.shade200,
                      'يوم عمل محدد في الجدول الأسبوعي',
                    ),
                    _legendRow(Colors.blue, 'يوم محجوز مسبقاً'),
                    _legendRow(
                      Colors.lightBlueAccent,
                      'يوم متاح جزئياً – توجد أوقات متبقية للحجز',
                    ),

                    _legendRow(Colors.grey, 'اليوم الحالي'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('${day.day}', style: TextStyle(color: textColor)),
    );
  }

  void onDaySelected(DateTime day, DateTime _) {
    final key = _dateKey(day);
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final isFullyBooked = fullyBookedDays.contains(normalizedDay);
    final isPartiallyBooked = partiallyBookedDays.contains(normalizedDay);
    final isSpecificallyDisabled =
        specificOverrides[key]?['is_disabled'] == true;
    final isAvailable = isDateAvailable(day);

    if (isSpecificallyDisabled) {
      setState(() {
        showTimeSelector = false;
        selectedDate = null;
        selectedStartTime = null;
        selectedEndTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❗ هذا اليوم غير متاح (معطل من قبل المربية)'),
        ),
      );
      return;
    }

    if (!isAvailable) {
      setState(() {
        showTimeSelector = false;
        selectedDate = null;
        selectedStartTime = null;
        selectedEndTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ هذا اليوم غير متاح للحجز')),
      );
      return;
    }

    if (isFullyBooked) {
      setState(() {
        showTimeSelector = false;
        selectedDate = null;
        selectedStartTime = null;
        selectedEndTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ هذا اليوم محجوز بالكامل')),
      );
      return;
    }

    // If partially booked — show current and remaining time slots
    if (isPartiallyBooked) {
      final slots = existingBookings[key] ?? [];

      final fallback = weeklyPreferences[_weekdayName(day)];
      final override = specificOverrides[key];
      final startStr = override?['start_time'] ?? fallback?['start_time'];
      final endStr = override?['end_time'] ?? fallback?['end_time'];

      List<Widget> contentWidgets = [];

      contentWidgets.add(const Text("الحجوزات الحالية في هذا اليوم:"));
      if (slots.isEmpty) {
        contentWidgets.add(const Text("لا توجد حجوزات حالياً"));
      } else {
        contentWidgets.addAll(
          slots.map(
            (b) => Text(
              'من ${formatTimeArabic(b['start']!)} إلى ${formatTimeArabic(b['end']!)}',
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }

      // 🧠 Add available slots if schedule info is defined
      if (startStr != null && endStr != null) {
        final startTime = _parseTime(startStr)!;
        final endTime = _parseTime(endStr)!;
        final gaps = calculateAvailableSlots(
          start: startTime,
          end: endTime,
          booked: slots,
        );
        if (gaps.isNotEmpty) {
          print(
            "🕐 Available booking slots for ${day.year}-${day.month}-${day.day}:",
          );
          for (var slot in gaps) {
            print(
              slot,
            ); // ✅ Prints each slot like "من 12:00 مساءً إلى 6:00 مساءً"
          }
        }

        if (gaps.isNotEmpty) {
          contentWidgets.add(const SizedBox(height: 12));
          contentWidgets.add(
            const Text(
              "أوقات الحجوزات المتبقية:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          contentWidgets.addAll(
            gaps.map((s) => Text(s, textDirection: TextDirection.rtl)),
          );
        }
      }

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Directionality(
                textDirection: TextDirection.rtl,
                child: Text("تفاصيل هذا اليوم"),
              ),
              content: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contentWidgets,
                ),
              ),
              actions: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("حسناً"),
                  ),
                ),
              ],
            ),
      );
    }

    // ✅ Allow date selection
    setState(() {
      selectedDate = day;
      selectedStartTime = null;
      selectedEndTime = null;
      showTimeSelector = true;
    });
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
      Navigator.pop(context);
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

  String formatTimeArabic(String time) {
    final parts = time.split(' ');
    final clock = parts[0];
    final suffix = parts[1];
    return suffix == 'AM' ? '$clock صباحاً' : '$clock مساءً';
  }

  List<String> calculateAvailableSlots({
    required TimeOfDay start,
    required TimeOfDay end,
    required List<Map<String, String>> booked,
  }) {
    List<String> available = [];

    int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
    TimeOfDay fromMinutes(int m) => TimeOfDay(hour: m ~/ 60, minute: m % 60);

    int startMin = toMinutes(start);
    int endMin = toMinutes(end);

    // Sort bookings
    booked.sort((a, b) {
      final aTime = _parseTime(a['start']!)!;
      final bTime = _parseTime(b['start']!)!;
      return aTime.hour != bTime.hour
          ? aTime.hour.compareTo(bTime.hour)
          : aTime.minute.compareTo(bTime.minute);
    });

    for (int i = 0; i <= booked.length; i++) {
      int gapStart =
          i == 0 ? startMin : toMinutes(_parseTime(booked[i - 1]['end']!)!);
      int gapEnd =
          i < booked.length
              ? toMinutes(_parseTime(booked[i]['start']!)!)
              : endMin;

      if (gapEnd > gapStart) {
        final from = formatTimeArabic(fromMinutes(gapStart).format(context));
        final to = formatTimeArabic(fromMinutes(gapEnd).format(context));
        available.add("من $from إلى $to");
      }
    }

    return available;
  }

  Widget _buildTimePickerCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
        color: Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🕒 حدد وقت الجلسة:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'NotoSansArabic',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedStartTime == null
                      ? 'وقت البدء: غير محدد'
                      : 'وقت البدء: ${selectedStartTime!.format(context)}',
                  style: const TextStyle(fontFamily: 'NotoSansArabic'),
                ),
              ),
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
                          content: Text(
                            '⚠️ الوقت الذي اخترته خارج ساعات العمل المحددة. يمكن إرسال الطلب ولكن قد يتم رفضه.',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('اختر وقت البدء'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedEndTime == null
                      ? 'وقت الانتهاء: غير محدد'
                      : 'وقت الانتهاء: ${selectedEndTime!.format(context)}',
                  style: const TextStyle(fontFamily: 'NotoSansArabic'),
                ),
              ),
              ElevatedButton(
                onPressed:
                    selectedStartTime == null
                        ? null
                        : () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: selectedStartTime!.hour + 1,
                              minute: selectedStartTime!.minute,
                            ),
                          );
                          if (picked != null) {
                            final warn = isOutsideWorkingHours(
                              selectedDate!,
                              picked,
                            );
                            setState(() => selectedEndTime = picked);
                            if (warn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '⚠️ الوقت الذي اخترته خارج ساعات العمل المحددة. يمكن إرسال الطلب ولكن قد يتم رفضه.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                child: const Text('اختر وقت الانتهاء'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedStartTime != null && selectedEndTime != null)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF600A),
                  foregroundColor:
                      Colors.white, // 👈 makes label (and icon) white
                ),
                onPressed: () async {
                  final start = selectedStartTime?.format(context);
                  final end = selectedEndTime?.format(context);
                  final date = selectedDate;

                  if (date == null || start == null || end == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("❗ يرجى اختيار التاريخ والوقت أولاً"),
                      ),
                    );
                    return;
                  }

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text("تأكيد الحجز"),
                          ),
                          content: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              "هل تريد إرسال الطلب في هذا الموعد؟\n📅 ${date.year}-${date.month}-${date.day}\n🕒 من $start إلى $end",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("إلغاء"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("تأكيد"),
                            ),
                          ],
                        ),
                  );

                  if (confirmed == true) {
                    sendBookingRequest();
                  }
                },
                label: const Text('إرسال الطلب'),
              ),
            ),
        ],
      ),
    );
  }
}
