import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewExpertCardsPage extends StatefulWidget {
  const ViewExpertCardsPage({super.key});

  @override
  State<ViewExpertCardsPage> createState() => _ViewExpertCardsPageState();
}

class _ViewExpertCardsPageState extends State<ViewExpertCardsPage> {
  bool _isLoading = true;
  List<dynamic> _cards = [];

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
      headers: {
        'Authorization': 'Bearer $token'
      },
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
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
            ? const Center(child: Text('لم يتم نشر أي بطاقات بعد'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final imageUrl = card['image_url'] != null && card['image_url'] != ''
                      ? '$baseUrl${card['image_url']}'
                      : null;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            card['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansArabic'
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card['summary'] ?? '',
                            style: const TextStyle(fontSize: 15, fontFamily: 'NotoSansArabic'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}