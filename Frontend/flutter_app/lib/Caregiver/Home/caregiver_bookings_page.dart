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

class _CaregiverBookingsPageState extends State<CaregiverBookingsPage> with SingleTickerProviderStateMixin {
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
        headers: {
          'Authorization': 'Bearer $token',
        },
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
    return allBookings.where((b) => (b['status'] ?? 'pending') == status).toList();
  }

    Widget buildBookingCard(Map<String, dynamic> booking) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "نوع الخدمة: ${booking['service_type'] ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic'),
              ),
              const SizedBox(height: 6),
              Text("التاريخ: ${booking['session_start_date']?.toString().substring(0, 10) ?? 'غير محدد'}"),
              Text("الوقت: ${booking['session_start_time']} - ${booking['session_end_time']}"),
              Text("العنوان: ${booking['city'] ?? ''} - ${booking['neighborhood'] ?? ''}"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: booking['status'] == 'confirmed' ? Colors.green.shade100
                      : booking['status'] == 'rejected' ? Colors.red.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  booking['status'] == 'confirmed'
                      ? "مؤكد"
                      : booking['status'] == 'rejected'
                          ? "مرفوض"
                          : "قيد الانتظار",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: booking['status'] == 'confirmed'
                        ? Colors.green
                        : booking['status'] == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }


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
              Tab(text: "مؤكد"),
              Tab(text: "مرفوض"),
            ],
            labelStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
            indicatorColor: Colors.white,
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF600A)))
            : TabBarView(
                controller: _tabController,
                children: [
                  bookingsList(filterBookingsByStatus('pending')),
                  bookingsList(filterBookingsByStatus('confirmed')),
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
