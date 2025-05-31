import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewExpertCardsPage extends StatefulWidget {
  const ViewExpertCardsPage({super.key});

  @override
  State<ViewExpertCardsPage> createState() => _ViewExpertCardsPageState();
}

class _ViewExpertCardsPageState extends State<ViewExpertCardsPage> {
  bool _isLoading = true;
  List<dynamic> _cards = [];

  final Color primaryColor = const Color(0xFFFF600A);

  @override
  void initState() {
    super.initState();
    fetchMyExpertPosts();
  }

  Future<void> fetchMyExpertPosts() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse("${url}expert-posts/mine"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        _cards = json['posts'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل البطاقات')),
      );
    }
  }

  void openPdf(String pdfUrl) async {
  final fullUrl = '$baseUrl$pdfUrl';
  final uri = Uri.parse(fullUrl);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعذر فتح ملف PDF')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('🧠 جارٍ تحويل النص إلى بطاقة... شكراً لصبرك')
                ],
              ),
            )
          : _cards.isEmpty
              ? const Center(
                  child: Text(
                    'لم يتم نشر أي بطاقات بعد',
                    style: TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final imageUrl = card['image_url'] != null && card['image_url'] != ''
                        ? '$baseUrl${card['image_url']}'
                        : null;

                    return GestureDetector(
                        onTap: () => openPdf(card['pdf_url']),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                          child: Column(
                            children: [
                              if (imageUrl != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(card['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 8),
                                    Text(card['summary'], style: const TextStyle(fontSize: 15)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );

                  },
                ),
    );
  }
}
