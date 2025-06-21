import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Home/online_meetings_page.dart';
import 'package:flutter_app/Parent/Home/parent_feedback_page.dart';
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
  Set<String> ratedBookings = {};

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
    'cancelled': {
      'label': 'تم الإلغاء',
      'color': Colors.grey,
      'icon': Icons.cancel_schedule_send, // or Icons.block or Icons.close
    },
    'completed': {
      'label': 'تمت الجلسة',
      'color': Colors.green, // ✅ Indicates success/completion
      'icon': Icons.check_circle_outline, // ✅ Clear and positive
    },
  };

  final Map<String, String?> statusMap = {
    'الكل': null,
    'بانتظار الرد': 'pending',
    'تم القبول': 'accepted',
    'تم حجز اجتماع': 'meeting_booked',
    'تم التأكيد': 'confirmed',
    'مرفوض': 'rejected',
    'تم الإلغاء': 'cancelled',
    'تمت الجلسة': 'completed',
  };
  String selectedServiceType = 'كل الخدمات';

  final Map<String, String?> serviceMap = {
    'كل الخدمات': null,
    'جليسة الأطفال': 'babysitter',
    'المعلم الظل': 'special_needs',
    'الخبير': 'expert',
  };

  final Map<String, String> statusLabels = {
    'pending': 'بانتظار الرد',
    'accepted': 'تم القبول',
    'meeting_booked': 'تم حجز اجتماع',
    'confirmed': 'تم التأكيد',
    'rejected': 'مرفوض',
    'cancelled': 'تم الإلغاء',
    'completed': 'تمت الجلسة',
  };
  final Map<String, String> serviceTypeLabels = {
    'babysitter': ' مجالسة أطفال',
    'special_needs': 'معلم ظل',
    'expert': 'خبير',
  };

  get data => null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBookings();
    fetchRatedBookings(); // ✅ Add this if not already

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

      List<Map<String, dynamic>> allBookings = List<Map<String, dynamic>>.from(
        data,
      );

      allBookings.sort((a, b) {
        final aDate = DateTime.parse(a['session_start_date']);
        final bDate = DateTime.parse(b['session_start_date']);
        return bDate.compareTo(aDate); // descending order
      });

      setState(() {
        final now = DateTime.now();

        currentBookings =
            allBookings.where((b) {
              final sessionDate = DateTime.parse(b['session_start_date']);
              final status = b['status'];

              return [
                    'pending',
                    'accepted',
                    'meeting_booked',
                    'confirmed',
                  ].contains(status) &&
                  !sessionDate.isBefore(now);
            }).toList();

        bookingHistory =
            allBookings.where((b) {
              final status = b['status'];
              return status == 'completed' ||
                  status == 'cancelled' ||
                  status == 'rejected';
            }).toList();

        isLoading = false;
      });
    }
  }

  Future<void> fetchRatedBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('${url}feedback/my-rated-bookings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final bookingIds = decoded['booking_ids'] as List<dynamic>;

      setState(() {
        ratedBookings = bookingIds.whereType<String>().toSet();
      });
    }
  }

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
                      final bookingId = booking['_id'];

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
                                    backgroundColor: Colors.orange.shade100,
                                    backgroundImage:
                                        (caregiver['image'] != null &&
                                                caregiver['image']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? NetworkImage(
                                              '$baseUrl/${caregiver['image'].toString().replaceAll('\\', '/')}',
                                            )
                                            : null,
                                    child:
                                        (caregiver['image'] == null ||
                                                caregiver['image']
                                                    .toString()
                                                    .isEmpty)
                                            ? const Icon(
                                              Icons.person,
                                              size: 30,
                                              color: Colors.white,
                                            )
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
                              const SizedBox(height: 12),
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
                                        label: const Text(
                                          ' حجز اجتماع أولاً',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          iconColor: Colors.white,
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
                                        label: const Text(
                                          'إتمام الحجز الآن',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          iconColor: Colors.white,
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
                                        label: const Text(' تغيير الموعد '),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          iconColor: Colors.white,
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
                                          foregroundColor: Colors.white,
                                          iconColor: Colors.white,
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
                                const SizedBox(height: 10),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if ([
                                    'pending',
                                    'accepted',
                                    'meeting_booked',
                                    'confirmed',
                                  ].contains(status))
                                    TextButton.icon(
                                      onPressed:
                                          () => _confirmCancel(
                                            booking['_id'],
                                            status,
                                          ),
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'إلغاء الحجز',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              if (status == 'cancelled') ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    booking['cancelled_by'] == 'parent'
                                        ? '🛑 تم الإلغاء من قبلك'
                                        : '🛑 تم الإلغاء من قبل مقدم الرعاية',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                                if (booking['cancellation_reason'] != null &&
                                    booking['cancellation_reason']
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '📋 السبب: ${booking['cancellation_reason']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),

                                // ✅ Show "إيجاد بديل" button only if cancelled by caregiver
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        243,
                                        192,
                                        116,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Navigator.pop(context);
                                      Navigator.pushNamed(
                                        context,
                                        '/fallback-candidates',
                                        arguments:
                                            booking['_id'] is Map
                                                ? booking['_id']['\$oid']
                                                : booking['_id'],
                                      );
                                    },
                                    child: const Text(
                                      'إيجاد بديل',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              if ((status == 'completed') ||
                                  (status == 'cancelled' &&
                                      booking['cancelled_by'] == 'caregiver'))
                                Align(
                                  alignment: Alignment.centerRight,
                                  child:
                                      ratedBookings.contains(bookingId)
                                          ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.orange,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'تم التقييم',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : TextButton.icon(
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        _,
                                                      ) => BabysitterFeedbackPage(
                                                        babysitterName:
                                                            caregiver['first_name'] ??
                                                            'بدون اسم',
                                                        sessionDate: DateTime.parse(
                                                          booking['session_start_date'],
                                                        ),
                                                        bookingId: bookingId,
                                                        caregiverId:
                                                            caregiver['_id'],
                                                        isCancelledByCaregiver:
                                                            status ==
                                                                'cancelled' &&
                                                            booking['cancelled_by'] ==
                                                                'caregiver',
                                                      ),
                                                ),
                                              );
                                              if (result != null &&
                                                  result is String) {
                                                setState(() {
                                                  ratedBookings.add(result);
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.star_rate,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              'قيّم مقدم الرعاية',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
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

  void _confirmCancel(String bookingId, String status) async {
    final shouldAskForReason = [
      'accepted',
      'meeting_booked',
      'confirmed',
    ].contains(status);
    final bool showWarning = ['meeting_booked', 'confirmed'].contains(status);

    if (!shouldAskForReason) {
      await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('تأكيد الإلغاء'),
              content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('لا'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    _cancelBooking(bookingId, 'تم الإلغاء بدون تحديد سبب');
                  },
                  child: const Text(
                    'نعم، إلغاء',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      return;
    }

    String selectedReason = 'ظروف طارئة';
    TextEditingController otherReasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder:
                  (context, setState) => AlertDialog(
                    title: const Text('سبب الإلغاء'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showWarning)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status == 'confirmed'
                                    ? '⚠️ \nتم تأكيد هذا الحجز، وقد يكون مدفوعًا. لن تسترد المبلغ إذا ألغيت الآن\n🔴تكرار الإلغاء في هذه المرحلة يؤثر على تقييم موثوقيتك في النظام،ويقلل من ظهور طلباتك في المستقبل.'
                                    : '⚠️ لقد حجزت اجتماعًا مع مقدم الرعاية. إذا ألغيت الآن، سيتم إعلامه فورًا.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const Text('يرجى اختيار سبب الإلغاء:'),
                          const SizedBox(height: 8),
                          RadioListTile<String>(
                            title: const Text('ظروف طارئة'),
                            value: 'ظروف طارئة',
                            groupValue: selectedReason,
                            onChanged:
                                (value) =>
                                    setState(() => selectedReason = value!),
                          ),
                          RadioListTile<String>(
                            title: const Text('لم أعد بحاجة للخدمة'),
                            value: 'لم أعد بحاجة للخدمة',
                            groupValue: selectedReason,
                            onChanged:
                                (value) =>
                                    setState(() => selectedReason = value!),
                          ),
                          RadioListTile<String>(
                            title: const Text('أخرى'),
                            value: 'أخرى',
                            groupValue: selectedReason,
                            onChanged:
                                (value) =>
                                    setState(() => selectedReason = value!),
                          ),
                          if (selectedReason == 'أخرى')
                            TextField(
                              controller: otherReasonController,
                              decoration: const InputDecoration(
                                hintText: 'اكتب السبب...',
                              ),
                            ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          final reason =
                              selectedReason == 'أخرى'
                                  ? otherReasonController.text.trim()
                                  : selectedReason;
                          Navigator.pop(context, true);
                          _cancelBooking(bookingId, reason);
                        },
                        child: const Text(
                          'تأكيد الإلغاء',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
    );

    if (confirmed != true) return;
  }

  Future<void> _cancelBooking(String bookingId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.patch(
      Uri.parse('${url}bookings/$bookingId/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cancelledBy': 'parent', // ✅ Correct field name
        'reason': reason, // ✅ Correct field name
      }),
    );
    print(jsonEncode({'cancelledBy': 'parent', 'reason': reason}));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إلغاء الحجز بنجاح')));
      fetchBookings();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل في إلغاء الحجز')));
    }
  }
}
