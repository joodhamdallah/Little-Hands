import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_profile_parent.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BabysitterResultsPage extends StatefulWidget {
  final Map<String, dynamic> jobDetails;

  const BabysitterResultsPage({super.key, required this.jobDetails});

  @override
  State<BabysitterResultsPage> createState() => _BabysitterResultsPageState();
}

class _BabysitterResultsPageState extends State<BabysitterResultsPage> {
  List<Map<String, dynamic>> babysitters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBabysitters();
  }

  Future<void> fetchBabysitters() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse("${url}match/babysitters"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "city": widget.jobDetails["city"],
          "childrenAges": widget.jobDetails["children_ages"] ?? [],
          "rateMin": widget.jobDetails["rate_min"] ?? 0,
          "rateMax": widget.jobDetails["rate_max"] ?? 999,
          "additionalRequirements":
              widget.jobDetails["additional_requirements"] ?? [],
          "isNegotiable":
              widget.jobDetails["is_negotiable"] ?? false, // ✅ أضفناها
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          babysitters = List<Map<String, dynamic>>.from(data['data']);
          isLoading = false;
        });
      } else {
        print("❌ Failed to load babysitters: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('نتائج البحث عن جليسات الأطفال'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF600A)),
                  )
                  : babysitters.isEmpty
                  ? const Center(
                    child: Text(
                      "لم يتم العثور على جليسات أطفال مطابقة للشروط.",
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                      ),
                    ),
                  )
                  : ListView.builder(
                    itemCount: babysitters.length,
                    itemBuilder: (context, index) {
                      final sitter = babysitters[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✨ نسبة التطابق
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E8),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "تطابق ${sitter['matchingPercentage'] ?? 0}%",
                                    style: const TextStyle(
                                      color: Color(0xFFFF600A),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        sitter['image'] != null
                                            ? NetworkImage(sitter['image'])
                                            : const AssetImage(
                                                  'assets/images/default_avatar.png',
                                                )
                                                as ImageProvider,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sitter['fullName'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${sitter['city'] ?? ''} • ${sitter['yearsExperience'] ?? 0} سنوات خبرة",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        Row(
                                          children: List.generate(
                                            5,
                                            (starIndex) => const Icon(
                                              Icons.star,
                                              size: 18,
                                              color: Color(0xFFFFA726),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "الأجر بالساعة:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                sitter['rateText'] ?? 'لم يتم تحديد الأجر بعد',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "نبذة عنها:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                sitter['shortBio'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "المهارات:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: List<Widget>.from(
                                  (sitter['skills'] ?? []).map<Widget>(
                                    (skill) => Chip(
                                      label: Text(
                                        skill,
                                        style: const TextStyle(
                                          fontFamily: 'NotoSansArabic',
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFFFF3E8),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => BabysitterProfilePage(
                                              babysitterId: sitter['id'],
                                            ),
                                        transitionsBuilder: (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          final tween = Tween(
                                            begin: const Offset(1, 0),
                                            end: Offset.zero,
                                          );
                                          final curveTween = CurveTween(
                                            curve: Curves.easeInOut,
                                          );

                                          return SlideTransition(
                                            position: animation
                                                .drive(curveTween)
                                                .drive(tween),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF600A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    "عرض الملف الشخصي",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'NotoSansArabic',
                                      fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
