import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SendPricePage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const SendPricePage({super.key, required this.booking});

  @override
  State<SendPricePage> createState() => _SendPricePageState();
}

class _SendPricePageState extends State<SendPricePage> {
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _extraFeeController = TextEditingController();

  double? total;

  void calculateTotal() {
    final days = int.tryParse(_daysController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final extra = double.tryParse(_extraFeeController.text) ?? 0;

    setState(() {
      total = (days * 8 * rate) + extra;
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    _rateController.dispose();
    _extraFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Directionality(
      textDirection: Directionality.of(context),   //doooooooooo it if u can \
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('إرسال السعر'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Text(
                "معلومات الحجز",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF600A),
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 8),
              Text("تاريخ الجلسة: ${booking['session_start_date']?.substring(0, 10) ?? ''}"),
              Text("الوقت: ${booking['session_start_time']} - ${booking['session_end_time']}"),
              const Divider(height: 30),

              const Text("عدد الأيام:"),
              TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "مثلاً: 3",
                ),
              ),
              const SizedBox(height: 10),

              const Text("السعر لكل ساعة:"),
              TextField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "مثلاً: 25",
                ),
              ),
              const SizedBox(height: 10),

              const Text("رسوم إضافية (اختياري):"),
              TextField(
                controller: _extraFeeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "مثلاً: 30",
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: calculateTotal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF600A),
                ),
                child: const Text("احسب المبلغ الكلي"),
              ),

              const SizedBox(height: 20),
              if (total != null)
                Column(
                  children: [
                    const Text(
                      "المبلغ النهائي:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₪ ${NumberFormat('#,##0.00').format(total)}",
                      style: const TextStyle(fontSize: 24, color: Colors.green),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ تم إرسال السعر بنجاح")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("إرسال السعر إلى ولي الأمر"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
