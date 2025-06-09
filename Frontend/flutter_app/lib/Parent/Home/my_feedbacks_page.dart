// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:lottie/lottie.dart';

class ParentMyFeedbacksPage extends StatefulWidget {
  @override
  State<ParentMyFeedbacksPage> createState() => _ParentMyFeedbacksPageState();
}

class _ParentMyFeedbacksPageState extends State<ParentMyFeedbacksPage> {
  List<dynamic> feedbacks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyFeedbacks();
  }

  Future<void> fetchMyFeedbacks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse('${url}feedback/mine'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          feedbacks = decoded['feedbacks'] ?? [];
          isLoading = false;
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
    return Scaffold(
      appBar: AppBar(title: const Text("تقييماتي")),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : feedbacks.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lottie.asset(
                      //   'assets/animations/no_feedback.json',
                      //   width: 200,
                      // ),
                      const SizedBox(height: 16),
                      const Text("لا يوجد تقييمات حتى الآن!"),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbacks.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Row(
                        children: const [
                          Icon(Icons.rate_review, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            " تقييماتك السابقة",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    } else if (index == feedbacks.length + 1) {
                      return _buildContactUsBanner();
                    }
                    final f = feedbacks[index - 1];
                    final ratingsMap = f['ratings'] ?? {};
                    final commentsMap = f['comments'] ?? {};

                    return TweenAnimationBuilder(
                      tween: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ),
                      duration: Duration(milliseconds: 400 + index * 100),
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: offset,
                          child: AnimatedOpacity(
                            opacity: 1,
                            duration: const Duration(milliseconds: 500),
                            child: _buildFeedbackCard(
                              f,
                              ratingsMap,
                              commentsMap,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildFeedbackCard(dynamic f, Map ratingsMap, Map commentsMap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "لمقدم/ة الرعاية: ${f['caregiver_name'] ?? 'غير معروف'}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            if (f['overall_rating'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Text(
                      "التقييم العام: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildStarRating(f['overall_rating']),
                  ],
                ),
              ),
            Text(
              "تاريخ التقييم: ${f['created_at']?.substring(0, 10) ?? '---'}",
            ),
            if (f['session_start_date'] != null)
              Text(
                "تاريخ الجلسة: ${f['session_start_date'].toString().substring(0, 10)}",
              ),
            const Divider(),
            if (f['type'] == 'completed') ...[
              ...ratingsMap.entries.map<Widget>((entry) {
                final key = entry.key;
                final value = entry.value;
                final comment = commentsMap[key];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("${_translateRatingKey(key)}: "),
                        (value == null || value == 0)
                            ? const Text(
                              "غير مُقيّم",
                              style: TextStyle(color: Colors.grey),
                            )
                            : _buildStarRating(value),
                      ],
                    ),
                    if (comment != null && comment.toString().trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0, top: 4),
                        child: Text("💬 $comment"),
                      ),
                  ],
                );
              }),
            ],
            if (f['type'] == 'cancelled') ...[
              const Text(
                'تقييمات حول إلغاء الجلسة:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 6),
              ...f['ratings'].entries.map<Widget>((entry) {
                final key = entry.key;
                final value = entry.value == 1;
                return Row(
                  children: [
                    Text(
                      '${_translateCancellationKey(key)}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      value ? 'نعم ✅' : 'لا ❌',
                      style: TextStyle(
                        color: value ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
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

  String _translateCancellationKey(String key) {
    switch (key) {
      case 'late_cancel':
        return 'ألغى في اللحظة الأخيرة';
      case 'committed_then_cancelled':
        return 'أظهر التزامًا ثم ألغى';
      case 'explained_reason':
        return 'شرح سبب الإلغاء بوضوح';
      default:
        return key;
    }
  }

  Widget _buildStarRating(num value) {
    Color getColor(num val) {
      // if (val >= 4) return Colors.green;
      // if (val >= 3) return Colors.orange;
      return Colors.orange;
    }

    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          size: 20,
          color: getColor(value),
        );
      }),
    );
  }

  Widget _buildContactUsBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF600A), width: 2),
      ),
      child: Column(
        children: const [
          Icon(Icons.support_agent, color: Color(0xFFFF600A), size: 48),
          SizedBox(height: 10),
          Text(
            "تواصل معنا لأي استفسار أو حالة طارئة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android, color: Colors.green),
              SizedBox(width: 10),
              Text("+970 599 000 123"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("support@littlehands.com"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.purple),
              SizedBox(width: 10),
              Text("@littlehandsapp"),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook, color: Color(0xFF1877F2)),
              SizedBox(width: 10),
              Text("littlehandsapp"),
            ],
          ),
        ],
      ),
    );
  }
}
