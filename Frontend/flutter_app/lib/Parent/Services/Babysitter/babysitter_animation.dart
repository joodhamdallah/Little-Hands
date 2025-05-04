import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_results.dart';

class BabysitterSearchAnimationPage extends StatefulWidget {
  final Map<String, dynamic> jobDetails;

  const BabysitterSearchAnimationPage({super.key, required this.jobDetails});

  @override
  State<BabysitterSearchAnimationPage> createState() =>
      _BabysitterSearchAnimationPageState();
}

class _BabysitterSearchAnimationPageState
    extends State<BabysitterSearchAnimationPage> {
  double _progress = 0.0;
  List<Map<String, String>> shownBabysitters = [];

  final List<Map<String, String>> dummyBabysitters = [
    {
      "name": "رنا ح.",
      "skills": "تحضير وجبات، مساعدة بالواجبات",
      "experience": "3 سنوات",
      'image': 'assets/images/homepage/sarah_test_pic.jpg',
    },
    {
      "name": "سلمى خ.",
      "skills": "رعاية توائم، إسعافات أولية",
      "experience": "5 سنوات",
      "image": "assets/images/homepage/maha_test_pic.webp",
    },
    {
      "name": "فرح س.",
      "skills": "توصيل أطفال، غير مدخنة",
      "experience": "2 سنوات",
      "image": "assets/images/homepage/sarah_test_pic.jpg",
    },
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        _goToResultsPage();
      } else {
        setState(() {
          _progress += 0.05;

          // كل ما تقدم التحميل شوي نضيف Babysitter جديد
          if ((_progress >= 0.2 && currentIndex == 0) ||
              (_progress >= 0.5 && currentIndex == 1) ||
              (_progress >= 0.8 && currentIndex == 2)) {
            if (currentIndex < dummyBabysitters.length) {
              shownBabysitters.add(dummyBabysitters[currentIndex]);
              currentIndex++;
            }
          }
        });
      }
    });
  }

  void _goToResultsPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => BabysitterResultsPage(jobDetails: widget.jobDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                "جاري البحث عن جليسات الأطفال الأنسب لك...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: const Color(0xFFFF600A),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: shownBabysitters.length,
                  itemBuilder: (context, index) {
                    final sitter = shownBabysitters[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(sitter["image"]!),
                        ),
                        title: Text(
                          sitter["name"]!,
                          style: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              sitter["skills"]!,
                              style: const TextStyle(
                                fontFamily: 'NotoSansArabic',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "خبرة: ${sitter["experience"]}",
                              style: const TextStyle(
                                fontFamily: 'NotoSansArabic',
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ⭐⭐⭐⭐ النجوم هنا
                            Row(
                              children: List.generate(
                                5,
                                (starIndex) => ShaderMask(
                                  shaderCallback:
                                      (bounds) => const LinearGradient(
                                        colors: [
                                          Color(0xFFFFA726),
                                          Color(0xFFFFEB3B),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds),
                                  child: const Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "الرجاء الانتظار قليلاً...",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
