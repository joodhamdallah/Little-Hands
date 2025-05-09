import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
      print("🚀 initState started ✅");
    fetchAppointments();
  }

 Future<void> fetchAppointments() async {
  final fullUrl = "${url}schedule/caregiver/${widget.babysitterId}";
  print("🔗 URL: $fullUrl");

  try {
    final response = await http.get(Uri.parse(fullUrl));

    print("📡 Status code: ${response.statusCode}");
    print("📥 Raw response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('data')) {
        final rawData = data['data'];
        print("📦 Decoded data['data']: $rawData");

        setState(() {
          appointments = (rawData as List)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          isLoading = false;
        });

        if (appointments.isEmpty) {
          print("⚠️ No appointments returned from server.");
        } else {
          print("✅ Loaded ${appointments.length} appointment(s).");
        }
      } else {
        print("❌ 'data' key not found in response!");
      }
    } else {
      print("❌ Failed to fetch appointments, status: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Exception during fetchAppointments: $e");
  }
}



  Future<void> confirmAppointment(Map<String, dynamic> slot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحجز"),
        content: Text("هل ترغب بحجز هذا الموعد؟\n${slot['day']} - ${slot['start_time']} إلى ${slot['end_time']}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("تأكيد"),
          ),
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
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء تسجيل الدخول أولاً")),
      );
      return;
    }

    final bookingData = {
      ...widget.jobDetails,
      'caregiver_id': widget.babysitterId,
      'service_type': 'babysitter',
      'schedule_id': slot['_id'], 
      'day': slot['day'],
      'date': slot['date'],
      'start_time': slot['start_time'],
      'end_time': slot['end_time'],
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
      print("❌ Booking error: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ فشل في إرسال الحجز")),
      );
    }
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
            : appointments.isEmpty
                ? const Center(child: Text('لا توجد مواعيد حالياً'))
                : ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final slot = appointments[index];
                      return Card(
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
