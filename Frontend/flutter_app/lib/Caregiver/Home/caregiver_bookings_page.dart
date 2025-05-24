import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CaregiverBookingsPage extends StatefulWidget {
  const CaregiverBookingsPage({super.key});

  @override
  State<CaregiverBookingsPage> createState() => _CaregiverBookingsPageState();
}

class _CaregiverBookingsPageState extends State<CaregiverBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${url}caregiver/bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          allBookings = data['data'];
          isLoading = false;
        });
      } else {
        print('❌ Error fetching bookings');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Exception: $e');
      setState(() => isLoading = false);
    }
  }

  List<dynamic> filterBookingsByStatus(String status) {
    return allBookings
        .where((b) => (b['status'] ?? 'pending') == status)
        .toList();
  }

  // داخل buildBookingCard:
  Widget buildBookingCard(Map<String, dynamic> booking) {
    final isPending = booking['status'] == 'pending';
    final isAccepted = booking['status'] == 'accepted';
    final isConfirmed = booking['status'] == 'confirmed';

    return GestureDetector(
      onTap: () {
        if (isConfirmed) {
          Navigator.pushNamed(context, '/send_price', arguments: booking);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.orange.shade100),
        ),
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.orange.shade200,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "نوع الخدمة: ${booking['service_type']}",
                style: boldOrangeTitle(),
              ),
              const SizedBox(height: 6),
              Text(
                "📅 التاريخ: ${booking['session_start_date']?.substring(0, 10) ?? 'غير محدد'}",
              ),
              Text(
                "⏰ الوقت: ${booking['session_start_time']} - ${booking['session_end_time']}",
              ),
              Text(
                "📍 العنوان: ${booking['city']} - ${booking['neighborhood']}",
              ),
              const Divider(thickness: 0.8),
              if (booking['children_ages'] != null)
                Text(
                  "👶 أعمار الأطفال: ${booking['children_ages'].join(', ')}",
                ),
              Text(
                "💊 حالة طبية: ${booking['has_medical_condition'] == true ? 'نعم' : 'لا'}",
              ),
              Text(
                "💉 يتناول دواء: ${booking['takes_medicine'] == true ? 'نعم' : 'لا'}",
              ),
              if (booking['additional_requirements'] != null)
                Text(
                  "🧩 الخدمات الإضافية: ${booking['additional_requirements'].join(', ')}",
                ),
              if ((booking['additional_notes'] ?? '').isNotEmpty)
                Text("📝 ملاحظات: ${booking['additional_notes']}"),
              Text(
                "💰 الأجر المقترح: ₪${booking['rate_min']} - ₪${booking['rate_max']}",
              ),
              const SizedBox(height: 10),
              if (isPending)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => acceptBooking(booking['_id'], booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("قبول"),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => rejectBooking(booking['_id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text("رفض"),
                    ),
                  ],
                )
              else
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isAccepted
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAccepted ? "مقبول" : "مرفوض",
                      style: TextStyle(
                        color: isAccepted ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> acceptBooking(String id, Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.patch(
      Uri.parse('${url}bookings/$id/accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await fetchBookings();
      _tabController.animateTo(1); // ✅ انتقل إلى تبويب "مؤكد"
      Navigator.pushNamed(context, '/send_price', arguments: booking);
    } else {
      print("❌ فشل في تأكيد الحجز");
    }
  }

  Future<void> rejectBooking(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.patch(
      Uri.parse('${url}bookings/$id/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await fetchBookings();
    } else {
      print("❌ فشل في رفض الحجز");
    }
  }

  TextStyle boldOrangeTitle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFF600A),
    fontFamily: 'NotoSansArabic',
  );

  TextStyle bold() => const TextStyle(
    fontWeight: FontWeight.bold,
    fontFamily: 'NotoSansArabic',
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text("الحجوزات"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "قيد الانتظار"),
              Tab(text: "مقبول"),
              Tab(text: "مرفوض"),
              Tab(text: "مؤكد"),
              // Tab(text: "ملغي"),
              // Tab(text: "مكتمل"),
            ],
            labelStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
            indicatorColor: Colors.white,
          ),
        ),
        body:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF600A)),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    bookingsList(filterBookingsByStatus('pending')),
                    bookingsList(filterBookingsByStatus('accepted')),
                    bookingsList(filterBookingsByStatus('rejected')),
                  ],
                ),
      ),
    );
  }

  Widget bookingsList(List<dynamic> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          "لا توجد حجوزات في هذه الحالة.",
          style: TextStyle(fontFamily: 'NotoSansArabic'),
        ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) => buildBookingCard(bookings[index]),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
