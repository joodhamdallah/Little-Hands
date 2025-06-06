import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BabysitterFeedbacks extends StatefulWidget {
  final Map<String, dynamic> sitter;
  const BabysitterFeedbacks({required this.sitter, super.key});

  @override
  State<BabysitterFeedbacks> createState() => _BabysitterFeedbacksState();
}

class _BabysitterFeedbacksState extends State<BabysitterFeedbacks> {
  List allFeedbacks = [];

  @override
  void initState() {
    super.initState();
    fetchFeedbacks(widget.sitter['user_id']);
  }

  Future<void> fetchFeedbacks(String caregiverId) async {
    final response = await http.get(
      Uri.parse("${url}feedback/about/caregiver/$caregiverId"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final feedbacks = data['feedbacks'] ?? [];

      // // ✅ Sort by rating (from highest to lowest)
      // feedbacks.sort(
      //   (a, b) =>
      //       (b['overall_rating'] ?? 0).compareTo(a['overall_rating'] ?? 0),
      // );

      // // ⬅️ أضف هذا السطر للترتيب من الأعلى للأقل
      // data.sort(
      //   (a, b) =>
      //       (b['overall_rating'] ?? 0).compareTo(a['overall_rating'] ?? 0),
      // );

      setState(() {
        allFeedbacks = data['feedbacks'] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text("تقييمات الجليسة"),
        ),
        body: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(child: _buildFeedbackList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF600A), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage:
                widget.sitter['image'] != null
                    ? NetworkImage(widget.sitter['image'])
                    : const AssetImage(
                          'assets/images/homepage/maha_test_pic.webp',
                        )
                        as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sitter['fullName'] ?? 'بدون اسم',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: (widget.sitter['average_rating'] ?? 0).toDouble(),
                      itemBuilder:
                          (context, index) =>
                              const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "(${(widget.sitter['average_rating'] ?? 0).toStringAsFixed(1)})",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                  ],
                ),
                Text(
                  "بناءً على ${widget.sitter['ratings_count'] ?? 0} تقييم",
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    if (allFeedbacks.isEmpty) {
      return const Center(child: Text("لا يوجد تقييمات لعرضها."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: allFeedbacks.length,
      itemBuilder: (context, index) {
        final feedback = allFeedbacks[index];
        final isCancel = feedback['type'] == 'cancelled';
        final rating = feedback['overall_rating'];
        final commentsMap = Map<String, dynamic>.from(
          feedback['comments'] ?? {},
        );
        final ratingsMap = Map<String, dynamic>.from(feedback['ratings'] ?? {});
        final fromUser = feedback['from_user_id'];
        final parentName =
            fromUser != null
                ? "${fromUser['firstName']} ${fromUser['lastName']?.substring(0, 1) ?? ''}."
                : "ولي أمر";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF8F3), Color.fromARGB(255, 236, 177, 125)],
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
              Text(
                feedback['created_at'] != null
                    ? DateTime.parse(
                      feedback['created_at'],
                    ).toLocal().toString().substring(0, 10)
                    : '',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "التقييم العام للجلسة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.black87,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: (rating ?? 0).toDouble(),
                        itemBuilder:
                            (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${(rating ?? 0).toStringAsFixed(1)})",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCancel
                              ? Colors.red.shade100
                              : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCancel ? "إلغاء الحجز" : "تجربة الجلسة",
                      style: TextStyle(
                        color: isCancel ? Colors.red : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...ratingsMap.entries
                  .where((e) => e.value != 0)
                  .map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _translateRatingKey(entry.key),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text("${entry.value}/5"),
                          ],
                        ),
                        RatingBarIndicator(
                          rating: (entry.value as num).toDouble(),
                          itemBuilder:
                              (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 18.0,
                        ),
                        if (commentsMap[entry.key]
                                ?.toString()
                                .trim()
                                .isNotEmpty ??
                            false)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            child: Text(
                              '💬 ${commentsMap[entry.key]}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                      ],
                    ),
                  ),

              if (commentsMap['general']?.toString().trim().isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '"${commentsMap['general']}"',
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage(
                      'assets/images/homepage/default_parent_avatar.webp',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _translateRatingKey(String key) {
    switch (key) {
      case 'satisfaction':
        return 'الرضا العام';
      case 'price_fairness':
        return 'عدالة السعر';
      case 'additional_reqs':
        return 'تنفيذ المتطلبات الإضافية';
      case 'communication':
        return 'التواصل';
      case 'punctuality':
        return 'الالتزام بالوقت';
      case 'interaction':
        return 'التفاعل مع الطفل';
      case 'safety':
        return 'الاهتمام بالسلامة';
      default:
        return key;
    }
  }
}
