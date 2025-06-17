import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CaregiverFeedbacksPage extends StatefulWidget {
  final String caregiverId;
  const CaregiverFeedbacksPage({super.key, required this.caregiverId});

  @override
  State<CaregiverFeedbacksPage> createState() => _CaregiverFeedbacksPageState();
}

class _CaregiverFeedbacksPageState extends State<CaregiverFeedbacksPage> {
  List<Map<String, dynamic>> feedbacks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final urll = Uri.parse('$url/feedback/caregiver/${widget.caregiverId}');

    final res = await http.get(
      urll,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        feedbacks = List<Map<String, dynamic>>.from(data['feedbacks']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _translateRatingKey(String key) {
    switch (key) {
      case 'punctuality':
        return 'الالتزام بالوقت';
      case 'communication':
        return 'التواصل';
      case 'safety':
        return 'السلامة';
      case 'price_fairness':
        return 'الأسعار';
      case 'additional_reqs':
        return 'تنفيذ المتطلبات';
      case 'satisfaction':
        return 'الرضا العام';
      default:
        return key;
    }
  }

  Widget _buildFeedbackCard(Map<String, dynamic> f) {
    final rating = f['overall_rating']?.toDouble() ?? 0.0;
    final comments = Map<String, dynamic>.from(f['comments'] ?? {});
    final ratings = Map<String, dynamic>.from(f['ratings'] ?? {});
    final type = f['type'] == 'cancelled' ? 'إلغاء' : 'جلسة مكتملة';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '⭐ ${rating.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(type, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            if (comments['general'] != null)
              Text(comments['general'], style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            ...ratings.entries.map(
              (e) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _translateRatingKey(e.key),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < (e.value ?? 0) ? Icons.star : Icons.star_border,
                        size: 18,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقييمات')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : feedbacks.isEmpty
              ? const Center(child: Text('لا توجد تقييمات بعد.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: feedbacks.length,
                itemBuilder:
                    (context, index) => _buildFeedbackCard(feedbacks[index]),
              ),
    );
  }
}
