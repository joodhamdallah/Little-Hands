import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Home/online_meetings_page.dart';
import 'package:flutter_app/Parent/Home/payment_booking_page.dart';
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

  String selectedStatusFilter = 'الكل';
  final Map<String, Map<String, dynamic>> statusStyles = {
    'pending': {
      'label': 'بانتظار الرد',
      'color': Colors.orange,
      'icon': Icons.hourglass_empty,
    },
    'accepted': {
      'label': 'تم القبول',
      'color': Colors.lightBlue,
      'icon': Icons.check_circle,
    },
    'meeting_booked': {
      'label': 'تم حجز اجتماع',
      'color': Colors.teal,
      'icon': Icons.video_call,
    },
    'confirmed': {
      'label': 'حجز مؤكد',
      'color': Colors.green,
      'icon': Icons.verified,
    },
    'rejected': {'label': 'مرفوض', 'color': Colors.red, 'icon': Icons.cancel},
  };

  final Map<String, String?> statusMap = {
    'الكل': null,
    'بانتظار الرد': 'pending',
    'تم القبول': 'accepted',
    'تم حجز اجتماع': 'meeting_booked',
    'تم التأكيد': 'confirmed',
  };
  String selectedServiceType = 'كل الخدمات';

  final Map<String, String?> serviceMap = {
    'كل الخدمات': null,
    'جليسة الأطفال': 'babysitter',
    'المعلم الظل': 'special_needs',
    'الخبير': 'expert',
  };

  // final Map<String, List<String>> statusOptionsByService = {
  //   'babysitter': ['pending', 'accepted', 'meeting_booked', 'confirmed'],
  //   'special_needs': ['pending', 'accepted'],
  //   'expert': ['pending', 'confirmed'],
  // };

  final Map<String, String> statusLabels = {
    'pending': 'بانتظار الرد',
    'accepted': 'تم القبول',
    'meeting_booked': 'تم حجز اجتماع',
    'confirmed': 'تم التأكيد',
    'rejected': 'مرفوض',
  };
  final Map<String, String> serviceTypeLabels = {
    'babysitter': ' مجالسة أطفال',
    'special_needs': 'معلم ظل',
    'expert': 'خبير',
  };

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

      List<Map<String, dynamic>> allBookings = List<Map<String, dynamic>>.from(
        data,
      );

      allBookings.sort((a, b) {
        final aDate = DateTime.parse(a['session_start_date']);
        final bDate = DateTime.parse(b['session_start_date']);
        return bDate.compareTo(aDate); // descending order
      });

      setState(() {
        currentBookings =
            allBookings.where((b) {
              final date = DateTime.parse(b['session_start_date']);
              return b['status'] != 'rejected' && date.isAfter(now);
            }).toList();

        bookingHistory =
            allBookings.where((b) {
              final date = DateTime.parse(b['session_start_date']);
              return b['status'] == 'rejected' || date.isBefore(now);
            }).toList();

        isLoading = false;
      });
    }
  }

  // List<String> getStatusOptions(String? serviceType) {
  //   if (serviceType == null) return statusLabels.keys.toList();
  //   return statusOptionsByService[serviceType] ?? [];
  // }

  String _translateStatus(String status) {
    return statusStyles[status]?['label'] ?? 'غير معروف';
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
            tabs: const [Tab(text: 'الحجوزات الحالية'), Tab(text: 'السجل')],
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
    final filteredBookings =
        statusMap[selectedStatusFilter] == null
            ? bookings
            : bookings
                .where((b) => b['status'] == statusMap[selectedStatusFilter])
                .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedStatusFilter,
              onChanged: (value) {
                setState(() {
                  selectedStatusFilter = value!;
                });
              },
              items:
                  statusMap.keys.map((label) {
                    return DropdownMenuItem<String>(
                      value: label,
                      child: Text(label),
                    );
                  }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'العدد: ${filteredBookings.length}',
              style: const TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              filteredBookings.isEmpty
                  ? const Center(child: Text('لا توجد حجوزات بهذا الحالة'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      final caregiver = booking['caregiver_id'];
                      final status = booking['status'];

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
                                            ? NetworkImage(
                                              caregiver['profile_image'],
                                            )
                                            : null,
                                    child:
                                        caregiver['profile_image'] == null
                                            ? const Icon(Icons.person, size: 30)
                                            : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${caregiver['first_name']} ${caregiver['last_name']}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            serviceTypeLabels[booking['service_type']] ??
                                                'نوع غير معروف',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    avatar: Icon(
                                      statusStyles[status]?['icon'] ??
                                          Icons.help,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _translateStatus(status),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'NotoSansArabic',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor:
                                        statusStyles[status]?['color'] ??
                                        Colors.grey,
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
                              if (status == 'accepted') ...[
                                const SizedBox(height: 10),
                                const Text(
                                  '📌 إكمال الطلب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSansArabic',
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => OnlineMeetingsPage(
                                                    booking: booking,
                                                    caregiver:
                                                        booking['caregiver_id'],
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.video_call),
                                        label: const Text(' حجز اجتماع أولاً'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      BookingPaymentPage(
                                                        booking: booking,
                                                      ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.payment),
                                        label: const Text('إتمام الحجز الآن'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (status == 'meeting_booked') ...[
                                const SizedBox(height: 10),
                                const Text(
                                  '📌 إكمال الطلب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSansArabic',
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => OnlineMeetingsPage(
                                                    booking: booking,
                                                    caregiver:
                                                        booking['caregiver_id'],
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.video_call),
                                        label: const Text(' إلغاء الحجز '),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      BookingPaymentPage(
                                                        booking: booking,
                                                      ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.payment),
                                        label: const Text('إتمام الحجز الآن'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  '💡 يمكنك إتمام الحجز الآن، أو انتظار الاجتماع للإتفاق على التفاصيل .',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
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
                  ),
        ),
      ],
    );
  }
}
