import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_feedback_page.dart';
import 'package:flutter_app/Caregiver/Home/feedbacks_about_parent.dart';
import 'package:flutter_app/Caregiver/Home/send_price_page.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

class CaregiverBookingsPage extends StatefulWidget {
  final CaregiverProfileModel profile;

  const CaregiverBookingsPage({super.key, required this.profile});
  @override
  State<CaregiverBookingsPage> createState() => _CaregiverBookingsPageState();
}

class _CaregiverBookingsPageState extends State<CaregiverBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allBookings = [];
  bool isLoading = true;
  String dropdownStatus = 'meeting_booked';
  Set<String> ratedBookings = {};

  final Map<String, Color> statusColors = {
    'pending': Colors.orange,
    'accepted': Colors.blue,
    'rejected': Colors.red,
    'meeting_booked': Colors.teal,
    'confirmed': Colors.green,
    'cancelled': Colors.grey,
    'completed': Colors.teal,
  };

  final Map<String, String> statusLabels = {
    'pending': 'قيد الانتظار',
    'accepted': 'تم القبول',
    'rejected': 'مرفوض',
    'meeting_booked': 'تم حجز اجتماع',
    'confirmed': 'مؤكد',
    'cancelled': 'ملغي',
    'completed': ' جلسات مكتملة',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    fetchBookings();
    fetchRatedBookings();
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

  Future<void> fetchRatedBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${url}feedback/my-rated-bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final bookingIds = decoded['booking_ids'] as List<dynamic>;

        print("📥 Rated Bookings Received: $bookingIds"); // 🔍 Debug Print

        setState(() {
          ratedBookings = bookingIds.whereType<String>().toSet();
        });
      } else {
        print("❌ Failed to fetch rated bookings");
      }
    } catch (e) {
      print("❌ Error fetching rated bookings: $e");
    }
  }

  List<dynamic> filterBookingsByStatus(String status) {
    return allBookings
        .where((b) => (b['status'] ?? 'pending') == status)
        .toList();
  }

  Widget buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';
    final isCompleted = status == 'completed';
    final isCancelledByParent =
        status == 'cancelled' &&
        booking['cancelled_by'] == 'parent' &&
        booking['cancelled_at_stage'] == 'confirmed';

    final isRated = ratedBookings.contains(booking['_id'].toString());
    print("👤 isRated: $isRated");

    final parent = booking['parent_id'];
    print("👤 Parent Info: $parent");

    bool showExtraDetails = false;

    return StatefulBuilder(
      builder:
          (context, setState) => Card(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "نوع الخدمة: ${booking['service_type']}",
                        style: boldOrangeTitle(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColors[status] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusLabels[status] ?? status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "📅 تاريخ الجلسة: ${booking['session_start_date']?.substring(0, 10) ?? 'غير محدد'}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RichText(
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'وقت الجلسة: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        WidgetSpan(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              "${formatTime(booking['session_start_time'])} - ${formatTime(booking['session_end_time'])}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "📍 العنوان: ${booking['city']} - ${booking['neighborhood']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    (booking['rate_min'] == null || booking['rate_max'] == null)
                        ? "💰 الأجر: قابل للتفاوض"
                        : "💰 الأجر: ₪${booking['rate_min']} - ₪${booking['rate_max']}",
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed:
                        () => setState(
                          () => showExtraDetails = !showExtraDetails,
                        ),
                    icon: Icon(
                      showExtraDetails ? Icons.expand_less : Icons.expand_more,
                    ),
                    label: Text(
                      showExtraDetails
                          ? "إخفاء تفاصيل الطلب الإضافية"
                          : "عرض تفاصيل الطلب الإضافية",
                    ),
                  ),
                  if (showExtraDetails) ...[
                    if (booking['children_ages'] != null)
                      Text(
                        "👶 أعمار الأطفال: ${booking['children_ages'].join(', ')}",
                      ),
                    Text(
                      "💊 حالة طبية: ${booking['has_medical_condition'] == true ? 'نعم' : 'لا'}",
                    ),
                    if (booking['medical_condition_details'] != null)
                      Text(
                        "🩺 تفاصيل الحالة الطبية: ${booking['medical_condition_details']}",
                      ),
                    Text(
                      "💉 يتناول دواء: ${booking['takes_medicine'] == true ? 'نعم' : 'لا'}",
                    ),
                    if (booking['medicine_details'] != null)
                      Text("💊 تفاصيل الدواء: ${booking['medicine_details']}"),
                    if (booking['additional_requirements'] != null)
                      Text(
                        "🧩 الخدمات الإضافية: ${booking['additional_requirements'].join(', ')}",
                      ),
                    if ((booking['additional_notes'] ?? '').isNotEmpty)
                      Text("📝 ملاحظات إضافية: ${booking['additional_notes']}"),
                  ],
                  const Divider(thickness: 0.8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("👤 معلومات ولي الأمر", style: boldOrangeTitle()),
                        Text(
                          "الاسم: ${parent?['firstName'] ?? 'غير معروف'} ${parent?['lastName'] ?? ''}",
                        ),
                        Text("📞 الهاتف: ${parent?['phone'] ?? 'غير متوفر'}"),
                        Text(
                          "📧 البريد الإلكتروني: ${parent?['email'] ?? 'غير متوفر'}",
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: () {
                            final parent = booking['parent_id'];
                            if (parent != null && parent['_id'] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FeedbackAboutParentPage(
                                        parentId: parent['_id'],
                                      ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.reviews),
                          label: const Text("عرض التقييمات"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade100,
                            foregroundColor: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (status == 'cancelled') ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        booking['cancelled_by'] == 'caregiver'
                            ? '🛑 تم الإلغاء من قبلك'
                            : '🛑 تم الإلغاء من قبل الأهل ',
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
                          '📋 السبب: ${booking['cancellation_reason']}\n',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                  if (isPending)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed:
                              () => showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("تأكيد القبول"),
                                      content: const Text(
                                        "هل أنت متأكد أنك تريد قبول هذا الحجز؟",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("إلغاء"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => SendPricePage(
                                                      booking: booking,
                                                      babysitter:
                                                          widget.profile,
                                                    ),
                                              ),
                                            );
                                            await acceptBooking(
                                              booking['_id'],
                                              booking,
                                            );
                                          },
                                          child: const Text("نعم"),
                                        ),
                                      ],
                                    ),
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("قبول"),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed:
                              () => showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("تأكيد الرفض"),
                                      content: const Text(
                                        "هل أنت متأكد أنك تريد رفض هذا الحجز؟",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("إلغاء"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            rejectBooking(booking['_id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text("نعم"),
                                        ),
                                      ],
                                    ),
                              ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("رفض"),
                        ),
                      ],
                    ),
                  if (isAccepted)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => SendPricePage(
                                  booking: booking,
                                  babysitter: widget.profile,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_money),
                      label: const Text("تعديل السعر"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if ([
                    'accepted',
                    'confirmed',
                    'meeting_booked',
                  ].contains(status))
                    ElevatedButton.icon(
                      onPressed:
                          () => showCancelDialog(
                            context,
                            booking['_id'],
                            status: booking['status'],
                          ),
                      icon: const Icon(Icons.cancel),
                      label: const Text("إلغاء الحجز"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  if ((isCompleted || isCancelledByParent) && isRated)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.orange,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "تم التقييم",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if ((isCompleted || isCancelledByParent) && !isRated)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RateParentPage(booking: booking),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review, color: Colors.white),
                      label: const Text(
                        "قيّم هذه التجربة",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          247,
                          202,
                          56,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  void showCancelDialog(
    BuildContext context,
    String bookingId, {
    String status = '',
  }) {
    final TextEditingController reasonController = TextEditingController();
    String selectedReason = '';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("سبب الإلغاء"),
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status == 'confirmed') ...[
                    const Text(
                      '⚠️ هذا الحجز مؤكد. تكرار الإلغاء في هذه المرحلة يؤدي إلى:',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '– تقليل تقييمك وموثوقيتك داخل النظام\n– تقليل فرص ظهورك في نتائج البحث للأهل مؤقتًا',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "اختر سببًا"),
                    items:
                        [
                              'الوقت غير مناسب',
                              'ظرف طارئ',
                              'الطلب غير مناسب',
                              'سبب آخر',
                            ]
                            .map(
                              (reason) => DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedReason = value ?? '',
                  ),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: "سبب إضافي (اختياري)",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () {
                  final reason =
                      selectedReason.isNotEmpty
                          ? selectedReason
                          : reasonController.text.trim();
                  if (reason.isEmpty) return;
                  cancelBooking(bookingId, reason);
                  Navigator.pop(context);
                },
                child: const Text("تأكيد الإلغاء"),
              ),
            ],
          ),
    );
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.patch(
      Uri.parse('${url}bookings/$bookingId/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'cancelledBy': 'caregiver', 'reason': reason}),
    );

    if (response.statusCode == 200) {
      await fetchBookings();
    } else {
      print("❌ فشل في إلغاء الحجز");
    }
  }

  String formatTime(String timeStr) {
    try {
      final inputFormat = intl.DateFormat.jm();
      final time = inputFormat.parse(timeStr);
      final outputFormat = intl.DateFormat('hh:mm a');
      return outputFormat.format(time);
    } catch (e) {
      return timeStr;
    }
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
      _tabController.animateTo(1);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  SendPricePage(booking: booking, babysitter: widget.profile),
        ),
      );
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
              Tab(text: "أخرى"),
            ],
            labelStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
            indicatorColor: Colors.white,
            isScrollable: true,
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
                    bookingsList(filterBookingsByStatus('confirmed')),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "اختر الحالة:",
                                style: TextStyle(fontFamily: 'NotoSansArabic'),
                              ),
                              DropdownButton<String>(
                                value: dropdownStatus,
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  fontFamily: 'NotoSansArabic',
                                  color: Colors.black,
                                ),
                                items:
                                    ['meeting_booked', 'cancelled', 'completed']
                                        .map(
                                          (status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(
                                              statusLabels[status] ?? status,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => dropdownStatus = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: bookingsList(
                            filterBookingsByStatus(dropdownStatus),
                          ),
                        ),
                      ],
                    ),
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
