import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/pdf_viewer_page.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;

class ViewAllExpertCardsPage extends StatefulWidget {
  const ViewAllExpertCardsPage({super.key});

  @override
  State<ViewAllExpertCardsPage> createState() => _ViewAllExpertCardsPageState();
}

class _ViewAllExpertCardsPageState extends State<ViewAllExpertCardsPage> {
  bool _isLoading = true;
  List<dynamic> _cards = [];

  final Color primaryColor = const Color(0xFFFF600A);

  @override
  void initState() {
    super.initState();
    fetchAllExpertPosts();
  }

  Future<void> fetchAllExpertPosts() async {
    setState(() => _isLoading = true);
    final response = await http.get(Uri.parse("${url}expert-posts/all"));

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

  void openPdf(String pdfUrl) {
    final fullUrl = '$baseUrl$pdfUrl';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfViewerPage(pdfUrl: fullUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'نصائح الخبراء',
            style: TextStyle(fontFamily: 'NotoSansArabic'),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('جارٍ تحميل النصائح...')
                  ],
                ),
              )
            : _cards.isEmpty
                ? const Center(child: Text('لا توجد نصائح حتى الآن'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      final imageUrl = card['image_url'] != null && card['image_url'] != ''
                          ? '$baseUrl${card['image_url']}'
                          : null;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => openPdf(card['pdf_url']),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: primaryColor,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    card['summary'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'NotoSansArabic',
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: TextButton.icon(
                                      onPressed: () => openPdf(card['pdf_url']),
                                      icon: const Icon(Icons.picture_as_pdf, color: Colors.grey),
                                      label: const Text(
                                        'عرض PDF',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    },
                  ),
      ),
    );
  }
}
