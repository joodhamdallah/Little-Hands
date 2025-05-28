import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    assert(widget.profile != null, "CaregiverProfileModel was not passed!");

    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
  // Updated CaregiverBookingsPage with parent info, toggle details, confirmation dialogs, and تحديد السعر button for accepted

  Widget buildBookingCard(Map<String, dynamic> booking) {
    final isPending = booking['status'] == 'pending';
    final isAccepted = booking['status'] == 'accepted';
    final isConfirmed = booking['status'] == 'confirmed';
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
                  Text(
                    "نوع الخدمة: ${booking['service_type']}",
                    style: boldOrangeTitle(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "📅 تاريخ الجلسة: ${booking['session_start_date']?.substring(0, 10) ?? 'غير محدد'}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  RichText(
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
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
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                        Text("الاسم: ${booking['parent_name'] ?? 'غير معروف'}"),
                        Text(
                          "رقم الهاتف: ${booking['parent_phone'] ?? 'غير متوفر'}",
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: () {},
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
                                          onPressed: () {
                                            Navigator.pop(context);
                                            acceptBooking(
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
                      label: const Text("تحديد السعر"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  String formatTime(String timeStr) {
    try {
      final inputFormat = intl.DateFormat.jm(); // e.g., 9:00 AM
      final time = inputFormat.parse(timeStr);
      final outputFormat = intl.DateFormat(
        'hh:mm a',
      ); // or 'HH:mm' for 24h format
      return outputFormat.format(time);
    } catch (e) {
      return timeStr; // fallback if parsing fails
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
      _tabController.animateTo(1); // ✅ انتقل إلى تبويب "مؤكد"
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
