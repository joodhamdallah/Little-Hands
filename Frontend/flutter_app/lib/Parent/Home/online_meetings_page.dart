import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/config.dart';

class OnlineMeetingsPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final Map<String, dynamic> caregiver;

  const OnlineMeetingsPage({
    super.key,
    required this.booking,
    required this.caregiver,
  });

  @override
  State<OnlineMeetingsPage> createState() => _OnlineMeetingsPageState();
}

class _OnlineMeetingsPageState extends State<OnlineMeetingsPage> {
  List<Map<String, dynamic>> availableMeetings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableMeetings();
  }

  Future<void> fetchAvailableMeetings() async {
    print('📣 Received caregiver object:');
    print(widget.caregiver);
    final caregiverId =
        widget.caregiver['_id'] ?? widget.caregiver['caregiver_id']?['_id'];
    print("caregiver id=$caregiverId");
    final sessionDate = DateTime.parse(widget.booking['session_start_date']);

    final response = await http.get(
      Uri.parse('${url}schedule/caregiver/$caregiverId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final allSchedules = List<Map<String, dynamic>>.from(data['data'] ?? []);

      final filtered =
          allSchedules.where((s) {
            try {
              return s['type'] == 'meeting' &&
                  DateTime.parse(
                    s['date'],
                  ).isBefore(sessionDate.subtract(const Duration(days: 1))) &&
                  DateTime.parse(s['date']).isAfter(DateTime.now());
            } catch (_) {
              return false;
            }
          }).toList();

      setState(() {
        print('✅ Loaded meetings:');
        print(filtered);
        availableMeetings = filtered;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> bookMeeting(String scheduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final bookingId = widget.booking['_id'];
    print('📤 Sending meeting booking request with:');
    print('bookingId: $bookingId');
    print('meeting_schedule_id: $scheduleId');

    final response = await http.patch(
      Uri.parse('${url}bookings/$bookingId/book-meeting'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'meeting_schedule_id': scheduleId}),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ تم حجز الموعد بنجاح')));
    } else {
      print('❌ Response status: ${response.statusCode}');
      print('❌ Response body: ${response.body}');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ فشل في حجز الموعد')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final caregiver = widget.caregiver;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختيار موعد لقاء'),
          backgroundColor: const Color(0xFFFF600A),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                caregiver['profile_image'] != null
                                    ? NetworkImage(caregiver['profile_image'])
                                    : null,
                            child:
                                caregiver['profile_image'] == null
                                    ? const Icon(Icons.person, size: 32)
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${caregiver['first_name']} ${caregiver['last_name']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (caregiver['bio'] != null)
                                  Text(
                                    caregiver['bio'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '🗓️ مواعيد اللقاء المتاحة:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (availableMeetings.isEmpty)
                        const Text('لا توجد مواعيد لقاء متاحة قبل وقت الجلسة.')
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: availableMeetings.length,
                            itemBuilder: (context, index) {
                              final m = availableMeetings[index];
                              final date =
                                  intl.DateFormat(
                                    'yyyy-MM-dd',
                                  ).parse(m['date']).toLocal();
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 3,
                                child: ListTile(
                                  title: Text(
                                    '${intl.DateFormat.yMMMMEEEEd('ar').format(date)}',
                                  ),
                                  subtitle: Text(
                                    '🕒 من ${m['start_time']} إلى ${m['end_time']}',
                                  ),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF600A),
                                    ),
                                    onPressed: () => bookMeeting(m['_id']),
                                    child: const Text('احجز'),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
      ),
    );
  }
}
