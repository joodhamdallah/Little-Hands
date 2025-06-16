import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_profile_parent.dart';
import 'package:flutter_app/Parent/Services/Babysitter/feedbacks.dart';
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
          "location": widget.jobDetails["location"],
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

        final rawList = List<Map<String, dynamic>>.from(data['data']);
        print("👀 Raw sitter list: ${jsonEncode(rawList)}");

        for (final sitter in rawList) {
          if (sitter['location'] != null) {
            final lat = sitter['location']['lat'];
            final lng = sitter['location']['lng'];
            sitter['locationLabel'] = await getLocationLabel(lat, lng);
          } else {
            sitter['locationLabel'] = 'موقع غير معروف';
          }
        }

        setState(() {
          babysitters = rawList;
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
          automaticallyImplyLeading: false, // Disable default back
          title: const Text(
            'نتائج البحث عن جليسات الأطفال',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/parentHome', // or '/caregiverHome'
                  (route) => false,
                );
              },
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
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
                                            ? NetworkImage(
                                                  '$baseUrl/${sitter['image'].toString().replaceAll('\\', '/')}',
                                                )
                                                as ImageProvider
                                            : const AssetImage(
                                              'assets/images/homepage/maha_test_pic.webp',
                                            ),
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
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                        if (sitter['locationLabel'] != null)
                                          Text(
                                            "المنطقة: ${sitter['locationLabel']}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontFamily: 'NotoSansArabic',
                                            ),
                                          ),
                                        if (sitter['distanceInKm'] != null)
                                          Text(
                                            "تبعد عنك: ${sitter['distanceInKm']} كم",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontFamily: 'NotoSansArabic',
                                            ),
                                          ),

                                        const SizedBox(height: 8),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (starIndex) => Icon(
                                              Icons.star,
                                              size: 18,
                                              color:
                                                  starIndex <
                                                          (sitter['average_rating'] ??
                                                                  0)
                                                              .round()
                                                      ? Color(0xFFFFA726)
                                                      : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                        if ((sitter['ratings_count'] ?? 0) == 0)
                                          const Text(
                                            "لم يتم التقييم بعد",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontFamily: 'NotoSansArabic',
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final userId = sitter['user_id'];
                                          if (userId == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "حدث خطأ: لا يمكن تحديد الجليسة",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => BabysitterProfilePage(
                                                    babysitterId:
                                                        userId is String
                                                            ? userId
                                                            : userId['\$oid'],
                                                    jobDetails:
                                                        widget.jobDetails,
                                                  ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFFF600A),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          " عرض ملف الجليسة",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'NotoSansArabic',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      BabysitterFeedbacks(
                                                        sitter: sitter,
                                                      ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFFFF600A),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "قراءة التقييمات",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'NotoSansArabic',
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF600A),
                                          ),
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
      ),
    );
  }

  Future<String> getLocationLabel(double lat, double lng) async {
    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data['address'];
      if (address != null) {
        return address['suburb'] ??
            address['neighbourhood'] ??
            address['village'] ??
            address['town'] ??
            address['city'] ??
            address['road'] ??
            'موقع غير معروف';
      } else {
        return 'موقع غير معروف';
      }
    } else {
      return 'موقع غير معروف';
    }
  }
}
