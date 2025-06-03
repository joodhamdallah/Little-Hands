import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../pages/config.dart'; // make sure this contains the API base URL
import 'package:shared_preferences/shared_preferences.dart';

class BabysitterFeedbackPage extends StatefulWidget {
  final String babysitterName;
  final DateTime sessionDate;
  final bool isCancelledByCaregiver;
  final String bookingId;
  final String caregiverId;

  const BabysitterFeedbackPage({
    super.key,
    required this.babysitterName,
    required this.sessionDate,
    required this.bookingId,
    required this.caregiverId,
    this.isCancelledByCaregiver = false,
  });

  @override
  State<BabysitterFeedbackPage> createState() => _BabysitterFeedbackPageState();
}

class _BabysitterFeedbackPageState extends State<BabysitterFeedbackPage> {
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _improvementController = TextEditingController();

  final Map<String, int> _ratings = {
    'punctuality': 0,
    'communication': 0,
    'interaction': 0,
    'safety': 0,
    'satisfaction': 0,
    'price_fairness': 0,
    'additional_reqs': 0, // ✅ New
  };

  final Map<String, TextEditingController> _sectionComments = {
    'punctuality': TextEditingController(),
    'communication': TextEditingController(),
    'interaction': TextEditingController(),
    'safety': TextEditingController(),
    'additional_reqs': TextEditingController(), // ✅ New
    'satisfaction': TextEditingController(),
    'price_fairness': TextEditingController(),
  };
  final Map<String, bool?> _cancelledAnswers = {
    'late_cancel': null,
    'committed_then_cancelled': null,
    'explained_reason': null,
  };
  void _submitFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final feedbackType =
        widget.isCancelledByCaregiver ? 'cancelled' : 'completed';
    final ratings =
        widget.isCancelledByCaregiver ? _cancelledAnswers : _ratings;

    final comments = <String, String>{};
    _sectionComments.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) {
        comments[key] = controller.text.trim();
      }
    });

    final body = {
      "booking_id": widget.bookingId,
      "to_user_id": widget.caregiverId,
      "from_role": "parent",
      "to_role": "caregiver",
      "type": feedbackType,
      "ratings": ratings,
      "comments": {
        ...comments,
        if (_commentsController.text.trim().isNotEmpty)
          "general": _commentsController.text.trim(),
        if (_improvementController.text.trim().isNotEmpty)
          "improvement": _improvementController.text.trim(),
      },
    };

    // 🔍 Debug print for backend submission
    print("📤 Submitting feedback to backend:");
    print(jsonEncode(body));

    final response = await http.post(
      Uri.parse("${url}feedback/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 تم إرسال التقييم بنجاح. شكراً لملاحظاتك!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } else {
      print("❌ Feedback submission failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إرسال التقييم. حاول لاحقاً.')),
      );
    }
  }

  Widget _buildYesNoQuestion({
    required String key,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('نعم'),
                    value: true,
                    groupValue: _cancelledAnswers[key],
                    onChanged:
                        (val) => setState(() => _cancelledAnswers[key] = val),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('لا'),
                    value: false,
                    groupValue: _cancelledAnswers[key],
                    onChanged:
                        (val) => setState(() => _cancelledAnswers[key] = val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(String title, String description, String key) {
    return FadeInUp(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: const Color.fromARGB(255, 247, 224, 199),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 14.0),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      return Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          size: 30,
                          color:
                              _ratings[key]! >= starIndex
                                  ? Colors.orange
                                  : Colors.grey[400],
                        ),
                        onPressed:
                            () => setState(() => _ratings[key] = starIndex),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sectionComments[key],
                maxLines: 2,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'ملاحظات إضافية (اختياري)',
                  hintStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        widget.sessionDate.toLocal().toString().split(" ")[0];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقييم الجلسة', style: TextStyle(fontSize: 22)),
          backgroundColor: const Color(0xFFFF600A),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: const Color.fromARGB(255, 250, 235, 220),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'شكراً لك على استخدامك لمنصتنا! نرجو منك تقييم الجلسة لمساعدتنا على تحسين الخدمة.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '👩‍🍼 مقدم/ة الرعاية: ${widget.babysitterName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📅 تاريخ الجلسة: $formattedDate',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.isCancelledByCaregiver) ...[
                  _buildYesNoQuestion(
                    key: 'late_cancel',
                    title: '📅 إلغاء متأخر',
                    subtitle: 'هل تم إلغاء الجلسة في اللحظة الأخيرة؟',
                  ),
                  _buildYesNoQuestion(
                    key: 'committed_then_cancelled',
                    title: '📉 عدم الالتزام',
                    subtitle: 'هل تم إلغاء الجلسة بعد الاتفاق على التفاصيل؟',
                  ),
                  _buildYesNoQuestion(
                    key: 'explained_reason',
                    title: '📣 التواصل عند الإلغاء',
                    subtitle: 'هل قام مقدم الرعاية بتوضيح سبب الإلغاء؟',
                  ),
                ] else ...[
                  _buildRatingCard(
                    '⏰ الالتزام بالمواعيد',
                    'هل حضرت مقدمة الرعاية في الوقت المحدد؟',
                    'punctuality',
                  ),
                  _buildRatingCard(
                    '💬 التواصل معك كولي أمر',
                    'هل كانت وسيلة التواصل معك واضحة وفعّالة طوال فترة التنسيق أو الجلسة؟',
                    'communication',
                  ),
                  _buildRatingCard(
                    '🧸 التفاعل مع الطفل (اختياري)',
                    'هل تفاعلت مع طفلك بشكل إيجابي؟ استخدم هذا التقييم فقط إذا كنت حاضراً.',
                    'interaction',
                  ),
                  _buildRatingCard(
                    '🛡️ السلامة والمسؤولية (اختياري)',
                    'هل شعرت أن طفلك كان في بيئة آمنة؟',
                    'safety',
                  ),
                  _buildRatingCard(
                    '🧾 تنفيذ المتطلبات الإضافية',
                    'هل قامت مقدمة الرعاية بتنفيذ ما طلبته من متطلبات إضافية بالشكل المطلوب؟',
                    'additional_reqs',
                  ),
                  // _buildRatingCard(
                  //   '🧾 تنفيذ المتطلبات الإضافية',
                  //   'هل قامت مقدمة الرعاية بتنفيذ ما طلبته من متطلبات إضافية (مثل إعطاء دواء، أنشطة، تعليمات خاصة) بالشكل المطلوب؟',
                  //   'additional_reqs',
                  // ),
                  _buildRatingCard(
                    '😊 الرضا العام (إجباري)',
                    'تقييمك العام للتجربة.',
                    'satisfaction',
                  ),
                ],

                const SizedBox(height: 24),
                const Text(
                  '📝 ملاحظات إضافية عامة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentsController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'اكتب ملاحظاتك هنا...',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '💡 ما الذي يمكن تحسينه؟',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _improvementController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'هل لديك اقتراح لتحسين جودة الخدمة؟',
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF600A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'إرسال التقييم',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.send, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
