import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
final randomCode = DateTime.now().millisecondsSinceEpoch;
final meetLink = "https://meet.google.com/lookup/$randomCode";

class AvailableAppointmentsPage extends StatefulWidget {
  final String babysitterId;
  final Map<String, dynamic> jobDetails;

  const AvailableAppointmentsPage({
    Key? key,
    required this.babysitterId,
    required this.jobDetails,
  }) : super(key: key);

  @override
  State<AvailableAppointmentsPage> createState() => _AvailableAppointmentsPageState();
}

class _AvailableAppointmentsPageState extends State<AvailableAppointmentsPage> {
  List<Map<String, dynamic>> meetingAppointments = [];
  Set<DateTime> workDays = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final fullUrl = "${url}schedule/caregiver/${widget.babysitterId}";
    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawData = data['data'];

        List<Map<String, dynamic>> meetings = [];
        Set<DateTime> workDates = {};

        for (var item in rawData) {
          if (item['type'] == 'meeting') {
            meetings.add(Map<String, dynamic>.from(item));
          } else if (item['type'] == 'work') {
            DateTime workDate = DateTime.parse(item['date']).toLocal();
            workDates.add(DateTime(workDate.year, workDate.month, workDate.day));
          }
        }

        setState(() {
          meetingAppointments = meetings;
          workDays = workDates;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching appointments: $e");
    }
  }

  Future<void> confirmAppointment(Map<String, dynamic> slot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحجز"),
        content: Text("هل ترغب بحجز هذا الموعد؟\n${slot['day']} - ${slot['start_time']} إلى ${slot['end_time']}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("تأكيد")),
        ],
      ),
    );

    if (confirm == true) {
      await sendBooking(slot);
    }
  }

  Future<void> sendBooking(Map<String, dynamic> slot) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

          final bookingData = {
          ...widget.jobDetails,
          'caregiver_id': widget.babysitterId,
          'service_type': 'babysitter',
          'schedule_id': slot['_id'],
          'day': slot['day'],
          'date': slot['date'],
          'start_time': slot['start_time'],
          'end_time': slot['end_time'],
          'meeting_link': meetLink, // ✅ رابط الاجتماع
        };

    final sanitized = bookingData.map((key, value) {
      if (value is DateTime) return MapEntry(key, value.toIso8601String());
      return MapEntry(key, value);
    });

    final response = await http.post(
      Uri.parse(saveBooking),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(sanitized),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم إرسال طلب الحجز")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ فشل في إرسال الحجز")),
      );
    }
  }

  bool isWorkDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return workDays.contains(d);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المواعيد المتاحة'),
          backgroundColor: const Color(0xFFFF600A),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF600A)))
            : Column(
                children: [
                 Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: const Text(
                            "أيام العمل",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF600A),
                              fontFamily: 'NotoSansArabic',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TableCalendar(
                          locale: 'ar_EG',
                          firstDay: DateTime.now().subtract(const Duration(days: 30)),
                          lastDay: DateTime.now().add(const Duration(days: 60)),
                          focusedDay: DateTime.now(),
                          calendarStyle: CalendarStyle(
                            markerDecoration: const BoxDecoration(
                              color: Color(0xFFFF600A),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, date, _) {
                              if (isWorkDay(date)) {
                                return Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSansArabic',
                                    ),
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
                        ),
                      ],
                    ),
                  ),

                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("إحجز موعد للقاء", style: TextStyle(   fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF600A),)),
                  ),
                  Expanded(
                    child: meetingAppointments.isEmpty
                        ? const Center(child: Text('لا توجد مواعيد لقاء متاحة حالياً'))
                        : ListView.builder(
                            itemCount: meetingAppointments.length,
                            itemBuilder: (context, index) {
                              final slot = meetingAppointments[index];
                              return Card(
                                margin: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    "${slot['day']} - ${slot['date']?.substring(0, 10) ?? ''}",
                                    style: const TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "${slot['start_time']} إلى ${slot['end_time']}",
                                    style: const TextStyle(fontFamily: 'NotoSansArabic'),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF600A)),
                                  onTap: () => confirmAppointment(slot),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
