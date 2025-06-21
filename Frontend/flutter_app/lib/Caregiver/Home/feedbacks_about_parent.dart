import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackAboutParentPage extends StatefulWidget {
  final String parentId;
  const FeedbackAboutParentPage({super.key, required this.parentId});

  @override
  State<FeedbackAboutParentPage> createState() =>
      _FeedbackAboutParentPageState();
}

class _FeedbackAboutParentPageState extends State<FeedbackAboutParentPage> {
  List<dynamic> feedbacks = [];
  bool isLoading = true;
  String parentName = '';
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  Future<void> fetchFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse('${url}feedback/about/parent/${widget.parentId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allFeedbacks = data['feedbacks'] ?? [];

        final completed =
            allFeedbacks.where((f) => f['type'] == 'completed').toList();

        double sum = 0.0;
        for (var f in completed) {
          sum += (f['overall_rating'] ?? 0).toDouble();
        }

        setState(() {
          feedbacks = completed;
          isLoading = false;
          parentName = data['parent_name'] ?? 'ولي الأمر';
          averageRating = completed.isNotEmpty ? sum / completed.length : 0.0;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text("تقييمات ولي الأمر"),
        ),
        body:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF600A)),
                )
                : feedbacks.isEmpty
                ? const Center(child: Text("لا توجد تقييمات مكتملة حالياً."))
                : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildParentHeader(),
                    const SizedBox(height: 12),
                    ...feedbacks.map((f) => _buildFeedbackCard(f)),
                  ],
                ),
      ),
    );
  }

  Widget _buildParentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF600A), width: 1),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFFFE4C9),
            child: Icon(Icons.person, size: 32, color: Color(0xFFFF600A)),
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: averageRating,
                      itemBuilder:
                          (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                    const SizedBox(width: 6),
                    Text("(${averageRating.toStringAsFixed(1)})"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(dynamic f) {
    final ratings = Map<String, dynamic>.from(f['ratings'] ?? {});
    final rating = f['overall_rating'] ?? 0.0;
    final sessionDate =
        f['booking']?['session_start_date']?.substring(0, 10) ?? '';

    final caregiver = f['from_user_id'];
    final caregiverName =
        caregiver != null
            ? "${caregiver['first_name']} ${caregiver['last_name']}"
            : "مقدم الخدمة";
    final caregiverImage = caregiver?['image'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8F3), Color(0xFFFFE4C9)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔶 Date & Session Info
          Text(
            f['created_at'] != null
                ? DateTime.parse(
                  f['created_at'],
                ).toLocal().toString().substring(0, 10)
                : '',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (sessionDate.isNotEmpty)
            Text(
              "📅 تاريخ الجلسة: $sessionDate",
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          const SizedBox(height: 8),

          // 🔶 Overall Rating
          Row(
            children: [
              RatingBarIndicator(
                rating: (rating).toDouble(),
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20.0,
              ),
              const SizedBox(width: 8),
              Text("(${rating.toStringAsFixed(1)})"),
            ],
          ),
          const SizedBox(height: 10),

          // 🔶 Ratings and Comments
          ...ratings.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            final comment = f['comments']?[key];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _translateRatingKey(key),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text("$value/5"),
                  ],
                ),
                RatingBarIndicator(
                  rating: (value as num).toDouble(),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 18.0,
                ),
                if (comment != null && comment.toString().trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      comment,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            );

          }).toList(),

          // 🔶 Divider
          const SizedBox(height: 12),
          const Divider(),

          const SizedBox(height: 12),
          const SizedBox(height: 16),

          // Line with label
          const Text(
            "تم التقييم بواسطة الجليسة",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // Row with image + name
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.orange.shade100,
                backgroundImage:
                    caregiverImage != null && caregiverImage.isNotEmpty
                        ? NetworkImage(
                          caregiverImage
                                  .replaceAll('\\', '/')
                                  .startsWith('http')
                              ? caregiverImage
                              : '$baseUrl/${caregiverImage.replaceAll('\\', '/')}',
                        )
                        : const AssetImage(
                              'assets/images/homepage/default_user.png',
                            )
                            as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  caregiverName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),


        ],
      ),
    );
  }

  String _translateRatingKey(String key) {
    switch (key) {
      case 'timing':
        return 'الالتزام بالوقت';
      case 'respect':
        return 'الاحترام والتقدير';
      case 'communication':
        return 'التواصل';
      case 'payment':
        return 'الالتزام بالدفع';
      case 'overall':
        return 'التقييم العام';
      default:
        return key;
    }
  }
}
