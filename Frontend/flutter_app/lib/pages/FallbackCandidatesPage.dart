import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/feedbacks.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FallbackCandidatesPage extends StatefulWidget {
  const FallbackCandidatesPage({super.key});

  @override
  State<FallbackCandidatesPage> createState() => _FallbackCandidatesPageState();
}

class _FallbackCandidatesPageState extends State<FallbackCandidatesPage> {
  late String bookingId;
  List<Map<String, dynamic>> candidates = [];
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookingId = ModalRoute.of(context)!.settings.arguments as String;
    fetchCandidates();
  }

  Future<void> fetchCandidates() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final response = await http.get(
      Uri.parse('${url}fallbacks/candidates/$bookingId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final rawList = List<Map<String, dynamic>>.from(
        jsonDecode(response.body)['candidates'],
      );

      for (final sitter in rawList) {
        if (sitter['location'] != null) {
          final lat = sitter['location']['lat'];
          final lng = sitter['location']['lng'];
          sitter['locationLabel'] = await getLocationLabel(lat, lng);
        } else {
          sitter['locationLabel'] = 'موقع غير معروف';
        }
      }

      rawList.sort(
        (a, b) =>
            (b['average_rating'] ?? 0).compareTo(a['average_rating'] ?? 0),
      );

      setState(() {
        candidates = rawList;
        loading = false;
      });
    } else {
      print('❌ Failed to load candidates');
      setState(() => loading = false);
    }
  }

  Future<String> getLocationLabel(double lat, double lng) async {
    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['address']['suburb'] ??
          data['address']['neighbourhood'] ??
          'موقع غير معروف';
    } else {
      return 'موقع غير معروف';
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
          title: const Text("المرشحون كبدائل"),
        ),
        body:
            loading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF600A)),
                )
                : candidates.isEmpty
                ? const Center(child: Text("لا يوجد بدائل حالياً"))
                : ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final sitter = candidates[index];
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        sitter['image'] != null
                                            ? NetworkImage(sitter['image'])
                                            : const AssetImage(
                                                  'assets/images/homepage/maha_test_pic.webp',
                                                )
                                                as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),
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
                                          "${sitter['city']} • ${sitter['yearsExperience']} سنوات خبرة",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                        if (sitter['locationLabel'] != null)
                                          Text(
                                            "المنطقة: ${sitter['locationLabel']}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'NotoSansArabic',
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      size: 18,
                                      color:
                                          i <
                                                  (sitter['average_rating'] ??
                                                          0)
                                                      .round()
                                              ? const Color(0xFFFFA726)
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(${sitter['ratings_count'] ?? 0})",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "الأجر بالساعة:",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                sitter['rateText'] ?? 'غير محدد',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "نبذة عنها:",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                sitter['shortBio'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "المهارات والميّزات الإضافية:",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
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
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
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
                                      child: const Text("عرض التقييمات"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final confirmed = await showDialog<
                                          bool
                                        >(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text("تأكيد"),
                                                content: const Text(
                                                  "هل أنت متأكد من اختيار هذه الجليسة كبديل؟",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text("إلغاء"),
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                  ),
                                                  TextButton(
                                                    child: const Text("تأكيد"),
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                        );

                                        if (confirmed != true) return;

                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        final token = prefs.getString(
                                          'accessToken',
                                        );

                                        final response = await http.post(
                                          Uri.parse('${url}fallback-booking'),
                                          headers: {
                                            'Authorization': 'Bearer $token',
                                            'Content-Type': 'application/json',
                                          },
                                          body: jsonEncode({
                                            'originalBookingId':
                                                bookingId, // ✅ Set this variable from parent
                                            'newCaregiverId':
                                                sitter['user_id'], // sitter from the fallback card
                                          }),
                                        );

                                        if (response.statusCode == 201) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '✅ تم حجز الجلسة بنجاح!',
                                              ),
                                            ),
                                          );
                                          Navigator.pop(
                                            context,
                                          ); // Go back or navigate to booking details
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '❌ حدث خطأ أثناء الحجز',
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFF600A,
                                        ),
                                      ),
                                      child: const Text(
                                        "اختيار كبديل",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
