import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/config.dart'; // Replace with your actual config file path

class RateParentPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const RateParentPage({super.key, required this.booking});

  @override
  State<RateParentPage> createState() => _RateParentPageState();
}

class _RateParentPageState extends State<RateParentPage> {
  final Map<String, dynamic> ratings = {};
  final Map<String, TextEditingController> comments = {};
  Map<String, dynamic>? parentData;
  bool isLoading = true;
  List<Map<String, String>> questions = [];
  bool isCancelledByParent = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    determineQuestionType();
    fetchParentData();
  }

  void submitFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;
    final feedbackType = isCompleted ? 'completed' : 'cancelled';

    final body = {
      "booking_id": widget.booking['_id'],
      "to_user_id": widget.booking['parent_id'],
      "from_role": "caregiver",
      "to_role": "parent",
      "type": feedbackType,
      "ratings": ratings,
      "comments": {
        for (var key in comments.keys)
          if (comments[key]!.text.trim().isNotEmpty)
            key: comments[key]!.text.trim(),
      },
    };

    final response = await http.post(
      Uri.parse("${url}feedback/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ تم إرسال التقييم بنجاح')));
      Navigator.pop(context);
    } else {
      print("❌ Feedback submission failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ فشل في إرسال التقييم. حاول لاحقاً.')),
      );
    }
  }

  void determineQuestionType() {
    final status = widget.booking['status'];
    final cancelledBy = widget.booking['cancelled_by'];

    isCompleted = status == 'completed';
    isCancelledByParent = status == 'cancelled' && cancelledBy == 'parent';

    if (isCompleted) {
      questions = [
        {
          'key': 'timing',
          'title': '⏰ الالتزام بالوقت',
          'desc':
              'هل التزم ولي الأمر في بدأالجلسة في وقتها المحدد؟هل كان حاضرًا لاستقبال الجليسة عند الوصول، وإنهاء الجلسة في وقتها؟',
        },
        {
          'key': 'communication',
          'title': '📞 التواصل',
          'desc':
              'هل كان ولي الأمر متاحًا للتواصل قبل وأثناء الجلسة؟ (مثلاً: الرد على المكالمات, الرسائل للطوارئ أو التغييرات)',
        },

        // {
        //   'key': 'respect',
        //   'title': '🤝 الاحترام والتقدير',
        //   'desc': 'هل كان ولي الأمر محترمًا ومتعاونًا أثناء التعامل؟',
        // },
        {
          'key': 'payment',
          'title': '💰 الالتزام بالدفع',
          'desc':
              'هل تم دفع الأجر المتفق عليه دون تأخير أو تفاوض؟ (ينطبق فقط على الدفع النقدي)',
        },
        {
          'key': 'overall',
          'title': '😊 التقييم العام',
          'desc': 'تقييمك العام للتجربة مع هذا ولي الأمر.',
        },
      ];
    } else if (isCancelledByParent) {
      questions = [
        {
          'key': 'late_cancel',
          'title': '📅 إلغاء متأخر',
          'desc': 'هل قام ولي الأمر بإلغاء الجلسة في اللحظة الأخيرة؟',
        },
        {
          'key': 'commitment',
          'title': '📉 عدم الالتزام',
          'desc': 'هل تم إلغاء الجلسة بعد الاتفاق على التفاصيل؟',
        },
        {
          'key': 'cancel_reason',
          'title': '📣 التواصل عند الإلغاء',
          'desc': 'هل قام ولي الأمر بالتواصل معك قبل الإلغاء؟',
        },
      ];
    }
    for (var q in questions) {
      ratings[q['key']!] = isCompleted ? 0.0 : false;
      comments[q['key']!] = TextEditingController();
    }
  }

  Future<void> fetchParentData() async {
    final parent = widget.booking['parent_id'];

    // Safely extract the ID whether it's a Map or already a String
    final parentId = parent is Map ? parent['_id'] : parent;

    print("🧠 Fetching parent data for ID: $parentId");

    if (parentId == null) {
      print("❌ parentId is null — cannot fetch data");
      return;
    }

    try {
      final response = await http.get(Uri.parse('${url}parentprof/$parentId'));

      print("📡 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("✅ Parent data loaded: $decoded");

        setState(() {
          parentData = decoded;
          isLoading = false;
        });
      } else {
        print("❌ Failed to fetch parent data — status: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception while fetching parent data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    for (var c in comments.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || parentData == null) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final String parentName =
        "${parentData?['firstName'] ?? ''} ${parentData?['lastName'] ?? ''}"
            .trim();
    final String date =
        (widget.booking['session_start_date'] ?? '')
            .toString()
            .split('T')
            .first;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('تقييم ولي الأمر'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.orange.shade50,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧑‍🍼 تقييم الجلسة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('اسم ولي الأمر: $parentName'),
                      Text('تاريخ الجلسة: $date'),
                    ],
                  ),
                ),
              ),
              ...questions.map((q) {
                final key = q['key']!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.orange.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            q['desc']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          isCompleted
                              ? Center(
                                child: RatingBar.builder(
                                  initialRating: 0,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemSize: 32,
                                  itemBuilder:
                                      (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      ratings[key] = rating;
                                    });
                                  },
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ChoiceChip(
                                    label: const Text('نعم'),
                                    selected: ratings[key] == true,
                                    onSelected: (_) {
                                      setState(() => ratings[key] = true);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  ChoiceChip(
                                    label: const Text('لا'),
                                    selected: ratings[key] == false,
                                    onSelected: (_) {
                                      setState(() => ratings[key] = false);
                                    },
                                  ),
                                ],
                              ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: comments[key],
                            decoration: const InputDecoration(
                              labelText: 'ملاحظات إضافية (اختياري)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'إرسال التقييم',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
