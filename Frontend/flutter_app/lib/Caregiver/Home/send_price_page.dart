import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_home_page.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class SendPricePage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final CaregiverProfileModel babysitter;

  const SendPricePage({
    super.key,
    required this.booking,
    required this.babysitter,
  });

  @override
  State<SendPricePage> createState() => _SendPricePageState();
}

class _SendPricePageState extends State<SendPricePage> {
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _fixedPriceController = TextEditingController();
  final Map<String, TextEditingController> _requirementControllers = {};
  double? total;
  double? subtotal;
  late bool hasRateRange;
  late double sessionHours;
  late double? minRate;
  late double? maxRate;

  final List<String> readonlyExcluded = [];

  final List<String> excludedRequirements = [
    "غير مدخنة",
    "تمتلك سيارة",
    "رعاية التوائم",
    "تتحدث لغات متعددة",
  ];

  @override
  void initState() {
    super.initState();
    minRate = (widget.babysitter.ratePerHour?['min'] ?? 0).toDouble();
    maxRate = (widget.babysitter.ratePerHour?['max'] ?? 0).toDouble();
    hasRateRange = minRate != maxRate;

    print("🔹 Raw start time: ${widget.booking['session_start_time']}");
    print("🔹 Raw end time: ${widget.booking['session_end_time']}");

    sessionHours = _calculateDuration(
      widget.booking['session_start_time'],
      widget.booking['session_end_time'],
    );

    final supportedByBabysitter = widget.babysitter.skillsAndServices;

    for (var req in widget.booking['additional_requirements'] ?? []) {
      if (supportedByBabysitter.contains(req)) {
        if (excludedRequirements.contains(req)) {
          readonlyExcluded.add(req); // 🌟 Show but not editable
        } else {
          _requirementControllers[req] = TextEditingController(); // 🌟 Editable
        }
      }
    }
  }

  double _calculateDuration(String start, String end) {
    final startTime = _parseTime(start);
    final endTime = _parseTime(end);
    if (endTime == null) return 0.0;

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final durationMinutes = endMinutes - startMinutes;

    double hours = durationMinutes / 60.0;

    // Round to the nearest 0.5 (e.g., 1.25 → 1.5, 2.74 → 2.5)
    return (hours * 2).roundToDouble() / 2;
  }

  TimeOfDay _parseTime(String rawTime) {
    final cleaned =
        rawTime
            .replaceAll(RegExp(r'\s+|\u202F|\u00A0|\u2007|\uFEFF'), ' ')
            .trim();
    final parts = cleaned.split(' ');
    final timePart = parts[0];
    final period = parts[1].toUpperCase(); // AM or PM

    final hourMinute = timePart.split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  void calculateTotal() {
    double rate;
    if (hasRateRange) {
      rate = double.tryParse(_hourlyRateController.text) ?? 0;
    } else {
      rate = minRate ?? 0;
    }

    double base = rate * sessionHours;

    double extra = 0;
    for (var ctrl in _requirementControllers.values) {
      extra += double.tryParse(ctrl.text) ?? 0;
    }

    setState(() {
      subtotal = base;
      total = base + extra;
    });
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _fixedPriceController.dispose();
    for (var ctrl in _requirementControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final profile = widget.babysitter;
    // ignore: unused_local_variable
    final unsupported =
        (booking['additional_requirements'] ?? [])
            .where((req) => !profile.skillsAndServices.contains(req))
            .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تحديد سعر الجلسة"),
          backgroundColor: const Color(0xFFFF600A),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSectionTitle("📅 تفاصيل الجلسة"),
              _infoRow(
                "اسم ولي الأمر:",
                "${booking['parent_id']['firstName']} ${booking['parent_id']['lastName']}",
              ),
              _infoRow(
                "التاريخ:",
                booking['session_start_date']?.substring(0, 10),
              ),
              _infoRow(
                "الوقت:",
                "${booking['session_start_time']} - ${booking['session_end_time']}",
              ),
              _infoRow("المدة:", "${sessionHours.toStringAsFixed(1)} ساعة"),
              _infoRow("المدينة:", booking['city']),
              _infoRow("عدد الأطفال:", "${booking['children_ages'].length}"),
              _infoRow(
                "أعمار الأطفال:",
                (booking['children_ages'] ?? []).join(', '),
              ),
              if ((booking['additional_notes'] ?? '').isNotEmpty)
                _infoRow("ملاحظات:", booking['additional_notes']),
              const Divider(),

              _buildSectionTitle("🧠 المهام التي طلبها ولي الأمر"),
              Wrap(
                spacing: 8,
                children:
                    (booking['additional_requirements'] ?? [])
                        .map<Widget>(
                          (req) => Chip(
                            label: Text(req),
                            backgroundColor: Colors.orange.shade100,
                          ),
                        )
                        .toList(),
              ),

              const Divider(),
              _buildSectionTitle(
                "📌 المهام أو المتطلبات الإضافية التي تقدمها الجليسة",
              ),

              if (_requirementControllers.isEmpty && readonlyExcluded.isEmpty)
                const Text("لا توجد مهام إضافية مدعومة من قبل الجليسة"),

              // Input fields for editable requirements
              ..._requirementControllers.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "${entry.key} (سعر إضافي بالشيكل)",
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    onChanged: (_) => calculateTotal(),
                  ),
                ),
              ),

              // Visual only: readonly excluded requirements
              if (readonlyExcluded.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),

                    Wrap(
                      spacing: 10,
                      children:
                          readonlyExcluded
                              .map(
                                (req) => Chip(
                                  label: Text(req),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),

              const Divider(),

              _buildSectionTitle("💰 السعر المطلوب"),
              hasRateRange
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "أدخل السعر بالساعة (بين ₪${minRate?.toStringAsFixed(2)} و ₪${maxRate?.toStringAsFixed(2)}):",
                      ),
                      TextField(
                        controller: _hourlyRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "مثلاً: 25",
                        ),
                        onChanged: (_) => calculateTotal(),
                      ),
                    ],
                  )
                  : _infoRow(
                    " السعر الثابت للجلسة/الساعة:",
                    "₪${minRate?.toStringAsFixed(2)}",
                  ),

              if (total != null) ...[
                const SizedBox(height: 10),
                _buildSectionTitle("💵 تفاصيل الحساب"),
                _infoRow(
                  "الإجمالي الفرعي:",
                  "₪ ${intl.NumberFormat('#,##0.00').format(subtotal)} "
                      "(المدة: ${sessionHours.toStringAsFixed(1)} ساعة × السعر: ₪${_getRateText()})",
                ),

                _infoRow(
                  "رسوم المهام الإضافية:",
                  "₪ ${intl.NumberFormat('#,##0.00').format(total! - subtotal!)}",
                ),
                const Divider(),
                _infoRow(
                  "المبلغ النهائي:",
                  "₪ ${intl.NumberFormat('#,##0.00').format(total)}",
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await sendPriceToBackend();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ تم إرسال السعر إلى ولي الأمر"),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CaregiverHomePage(
                              profile: profile,
                              initialTabIndex:
                                  2, // 👈 Open "accepted bookings" tab
                            ), // ✅ make sure profile is not null
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "إرسال السعر",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getRateText() {
    if (hasRateRange) {
      return _hourlyRateController.text.isNotEmpty
          ? _hourlyRateController.text
          : '0';
    } else {
      return minRate?.toStringAsFixed(2) ?? '0';
    }
  }

  Future<void> sendPriceToBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final uri = Uri.parse('${url}setPrice/${widget.booking['_id']}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final double hourlyRate =
        hasRateRange
            ? double.tryParse(_hourlyRateController.text) ?? 0
            : (minRate ?? 0);

    final body = {
      'is_hourly': hasRateRange,
      'hourly_rate': hourlyRate, // ✅ always send this
      'fixed_rate': !hasRateRange ? subtotal : null,
      'session_hours': sessionHours,
      'subtotal': subtotal,
      'total': total,
      'additional_fees':
          _requirementControllers.entries
              .map(
                (e) => {
                  'label': e.key,
                  'amount': double.tryParse(e.value.text) ?? 0,
                },
              )
              .toList(),
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      print("✅ Price sent successfully");
    } else {
      print("❌ Failed to send price: ${response.body}");
    }
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _infoRow(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value ?? 'غير متوفر')),
      ],
    ),
  );
}
