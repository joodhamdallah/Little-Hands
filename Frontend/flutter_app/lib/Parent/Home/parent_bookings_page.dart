import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/socket_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/config.dart';

class ParentBookingsPage extends StatefulWidget {
  const ParentBookingsPage({Key? key}) : super(key: key);

  @override
  State<ParentBookingsPage> createState() => _ParentBookingsPageState();
}

class _ParentBookingsPageState extends State<ParentBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> currentBookings = [];
  List<Map<String, dynamic>> bookingHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBookings();
    initSocket();
  }

  Future<void> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${url}bookings/parent'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final now = DateTime.now();

      setState(() {
        currentBookings =
            data
                .where((b) {
                  final date = DateTime.parse(b['session_start_date']);
                  return b['status'] != 'rejected' && date.isAfter(now);
                })
                .cast<Map<String, dynamic>>()
                .toList();

        bookingHistory =
            data
                .where((b) {
                  final date = DateTime.parse(b['session_start_date']);
                  return b['status'] == 'rejected' || date.isBefore(now);
                })
                .cast<Map<String, dynamic>>()
                .toList();

        isLoading = false;
      });
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending':
        return 'بانتظار الرد';
      case 'confirmed':
        return 'تم القبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  void initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final socket = SocketService();
      socket.connect(userId);
      socket.onNewNotification((data) {
        if (!mounted) return; // ✅ Check before using setState
        if (data['type'] == 'booking_status_updated') {
          print('📡 تحديث الحجز: $data');
          fetchBookings(); // 🔄 update list
        }
      });
    }
  }

  @override
  void dispose() {
    SocketService().removeListeners(); // ✅ Prevent double callback
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'الجلسات الحالية'), Tab(text: 'السجل')],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    buildBookingList(currentBookings),
                    buildBookingList(bookingHistory),
                  ],
                ),
      ),
    );
  }

  Widget buildBookingList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('لا توجد حجوزات'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final caregiver = booking['caregiver_id'];
        final status = booking['status'];

        Color statusColor = Colors.grey;
        if (status == 'accepted')
          statusColor = Colors.green;
        else if (status == 'pending')
          statusColor = Colors.orange;
        else if (status == 'rejected')
          statusColor = Colors.red;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          caregiver['profile_image'] != null
                              ? NetworkImage(caregiver['profile_image'])
                              : null,
                      child:
                          caregiver['profile_image'] == null
                              ? const Icon(Icons.person, size: 30)
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${caregiver['first_name']} ${caregiver['last_name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _translateStatus(status),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '📅 التاريخ: ${booking['session_start_date'].toString().split("T")[0]}',
                ),
                Text(
                  '⏰ الوقت: من ${booking['session_start_time']} حتى ${booking['session_end_time']}',
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to booking details page
                    },
                    child: const Text('عرض التفاصيل'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
