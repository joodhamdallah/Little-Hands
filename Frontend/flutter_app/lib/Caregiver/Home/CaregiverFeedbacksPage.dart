import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaregiverFeedbacksPage extends StatefulWidget {
  const CaregiverFeedbacksPage({super.key});

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
    final urll = Uri.parse('${url}feedback/caregiver');

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

  Widget _buildFeedbackCard(Map<String, dynamic> f) {
    final parent = f['from_user_id'];
    final parentName =
        parent != null
            ? "${parent['firstName']} ${parent['lastName'][0]}."
            : "ولي أمر";

    final createdAt = f['created_at'];
    final formattedDate =
        createdAt != null
            ? DateFormat(
              'y/MM/dd – hh:mm a',
              'ar',
            ).format(DateTime.parse(createdAt).toLocal())
            : '';

    final generalComment = f['comments']?['general'];
    final ratings = Map<String, dynamic>.from(f['ratings'] ?? {});
    final overallRating = (f['overall_rating'] ?? 0).toDouble();

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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ Overall Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 💬 General comment
            if (generalComment != null &&
                generalComment.toString().trim().isNotEmpty)
              Text(generalComment, style: const TextStyle(fontSize: 15))
            else
              const Text(
                "لا يوجد تعليق عام.",
                style: TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 12),

            // 🌟 Category Ratings
            ...ratings.entries.map((e) {
              final key = e.key;
              final value = e.value ?? 0;
              final translated = _translateRatingKey(key);
              final commentText = f['comments']?[key];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(translated, style: const TextStyle(fontSize: 14)),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < value ? Icons.star : Icons.star_border,
                            size: 18,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ),
                  if (commentText != null &&
                      commentText.toString().trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        commentText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
              );
            }),

            const SizedBox(height: 12),
            Divider(),

            // 👤 Parent & 📅 Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      parentName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
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
