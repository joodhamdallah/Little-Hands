import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart';

class FallbackOffersPage extends StatefulWidget {
  const FallbackOffersPage({super.key});

  @override
  State<FallbackOffersPage> createState() => _FallbackOffersPageState();
}

class _FallbackOffersPageState extends State<FallbackOffersPage> {
  List<Map<String, dynamic>> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFallbackOffers();
  }

  Future<void> fetchFallbackOffers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('${url}fallbacks/unseen'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      setState(() {
        offers = decoded.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      print("❌ Failed to load fallback offers");
      setState(() => isLoading = false);
    }
  }

  Future<void> respondToFallback(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse('${url}fallbacks/respond'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'booking_id': bookingId,
        'message': 'أرغب بتنفيذ هذه الجلسة',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ تم إرسال الموافقة")));
      fetchFallbackOffers(); // refresh list
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ فشل في الإرسال")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الجلسات البديلة")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : offers.isEmpty
              ? const Center(child: Text("لا توجد جلسات بديلة حالياً"))
              : ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📅 التاريخ: ${offer['session_date']}"),
                          Text(
                            "🕒 من ${offer['start_time']} إلى ${offer['end_time']}",
                          ),
                          if (offer['city'] != null)
                            Text("📍 المدينة: ${offer['city']}"),
                          if (offer['children_ages'] != null)
                            Text(
                              "👶 أعمار الأطفال: ${offer['children_ages'].join(', ')}",
                            ),
                          if (offer['requirements'] != null)
                            Text(
                              "🧩 المتطلبات: ${offer['requirements'].join(', ')}",
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed:
                                () => respondToFallback(offer['booking_id']),
                            child: const Text("قبول الجلسة"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
