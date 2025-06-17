import 'package:flutter/material.dart';
import 'package:flutter_app/pages/WebViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingPaymentPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingPaymentPage({super.key, required this.booking});

  @override
  State<BookingPaymentPage> createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage> {
  String? paymentMethod;

  @override
  Widget build(BuildContext context) {
    final priceDetails = widget.booking['price_details'] ?? {};
    final additionalFees = priceDetails['additional_fees'] ?? [];
    final isHourly = priceDetails['is_hourly'] == true;
    final sessionHours = priceDetails['session_hours'] ?? 0;
    final pricePerHour = priceDetails['hourly_rate'] ?? '-';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('تفاصيل الدفع'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                size: 32,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ملخص الفاتورة',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo_without_bg.png',
                                height: 50,
                              ),
                              // const SizedBox(width: 8),
                              const Text(
                                'Little Hands',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF600A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _infoRow(
                        "نوع التسعير:",
                        isHourly ? 'بالساعة' : 'سعر ثابت',
                      ),
                      if (isHourly) _infoRow("السعر للساعة:", "₪$pricePerHour"),
                      if (isHourly)
                        _infoRow(
                          "عدد ساعات الجلسة:",
                          "$sessionHours ${_pluralHour(sessionHours)}",
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            "المبلغ الأساسي:",
                            "₪${priceDetails['subtotal'] ?? 0}",
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, top: 4),
                            child: Text(
                              "عدد الساعات: $sessionHours ساعة \n  السعر للساعة: $pricePerHour شيكل",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      if (additionalFees.isNotEmpty) ...[
                        const Text(
                          "📋 رسوم إضافية:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...additionalFees.map<Widget>(
                          (fee) => _infoRow(
                            "- ${fee['label']}",
                            "₪${fee['amount']}",
                          ),
                        ),
                      ],
                      const Divider(thickness: 1.5),
                      _infoRow(
                        "الإجمالي:",
                        "₪${priceDetails['total'] ?? 0}",
                        bold: true,
                        color: Colors.green.shade700,
                        large: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openEditRequirementsDialog,
                      icon: const Icon(Icons.edit_note),
                      label: const Text("تعديل المهام الإضافية"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final currentUserId = prefs.getString('userId');
                        print("🔹 Current User ID: $currentUserId");

                        final caregiverRaw = widget.booking['caregiver_id'];
                        print("🔹 Raw Caregiver: $caregiverRaw");

                        final caregiverId = caregiverRaw['_id'];
                        print("🔹 Extracted Caregiver ID: $caregiverId");

                        final caregiverName =
                            "${caregiverRaw['first_name'] ?? 'مقدم الرعاية'} ${caregiverRaw['last_name'] ?? ''}";
                        print("🔹 Caregiver Name: $caregiverName");

                        if (currentUserId != null && caregiverId != null) {
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {
                              'myId': currentUserId,
                              'otherId': caregiverId,
                              'otherUserName': caregiverName,
                            },
                          );
                        } else {
                          print("❌ Failed to load chat data");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تعذر تحميل بيانات المحادثة"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("تحدث مع الجليسة"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Color.fromARGB(255, 255, 96, 10),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختر طريقة الدفع:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _paymentOption(
                      label: 'الدفع نقدًا عند الجلسة',
                      value: 'cash',
                      icon: Icons.money,
                    ),
                    _paymentOption(
                      label: 'الدفع عبر البطاقة الائتمانية',
                      value: 'online',
                      icon: Icons.credit_card,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            paymentMethod == null ? null : _handlePayment,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'إتمام الحجز وثبيت طريقة الدفع',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF600A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditRequirementsDialog() async {
    final priceDetails = widget.booking['price_details'] ?? {};
    final additionalFees = List<Map<String, dynamic>>.from(
      priceDetails['additional_fees'] ?? [],
    );

    final selectedFees = Map.fromIterable(
      additionalFees,
      key: (fee) => fee['label'],
      value: (_) => true,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل المهام الإضافية'),
          content: StatefulBuilder(
            builder:
                (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      additionalFees.map((fee) {
                        return CheckboxListTile(
                          title: Text(fee['label']),
                          value: selectedFees[fee['label']],
                          onChanged: (val) {
                            setState(() => selectedFees[fee['label']] = val!);
                          },
                        );
                      }).toList(),
                ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('حفظ'),
              onPressed: () {
                final newFees =
                    additionalFees
                        .where((fee) => selectedFees[fee['label']] == true)
                        .toList();

                setState(() {
                  widget.booking['price_details']['additional_fees'] = newFees;
                  final subtotal = priceDetails['subtotal'] ?? 0.0;
                  final total =
                      subtotal +
                      newFees.fold<double>(
                        0.0,
                        (sum, fee) => sum + (fee['amount'] ?? 0),
                      );
                  widget.booking['price_details']['total'] = total;
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String _pluralHour(int hours) {
    if (hours == 1) return 'ساعة';
    if (hours == 2) return 'ساعتين';
    if (hours >= 3 && hours <= 10) return 'ساعات';
    return 'ساعة';
  }

  Widget _infoRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
    bool large = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 18 : 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: large ? 18 : 16,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _paymentOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              paymentMethod == value
                  ? const Color(0xFFFF600A)
                  : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        value: value,
        groupValue: paymentMethod,
        onChanged: (val) => setState(() => paymentMethod = val),
        activeColor: const Color(0xFFFF600A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handlePayment() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final bookingId = widget.booking['_id'];
    print("bookingId: $bookingId");
    if (paymentMethod == 'cash') {
      final res = await http.patch(
        Uri.parse('${url}bookings/$bookingId/payment-method'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'method': 'cash'}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ تم تأكيد الحجز واختيار الدفع نقدًا بنجاح!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // or navigate to another page if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ حدث خطأ أثناء معالجة الدفع النقدي."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (paymentMethod == 'online') {
      final res = await http.post(
        Uri.parse('${url}booking-checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'booking_id': bookingId}),
      );

      final json = jsonDecode(res.body);
      final stripeurl = json['url'];

      if (stripeurl != null) {
        // 🚀 Launch the Stripe payment page using `url_launcher`
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WebViewPage(url: stripeurl)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ فشل في بدء الدفع')));
      }
    }
  }
}
