import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/SubscriptionPlanPage.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/caregiver_profile_model.dart';

class BabysitterProfilePage extends StatefulWidget {
  final String babysitterId;
  final Map<String, dynamic> jobDetails;

  const BabysitterProfilePage({
    super.key,
    required this.babysitterId,
    required this.jobDetails,
  });

  @override
  State<BabysitterProfilePage> createState() => _BabysitterProfilePageState();
}

class _BabysitterProfilePageState extends State<BabysitterProfilePage> {
  CaregiverProfileModel? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBabysitterProfile();
  }

  Future<void> fetchBabysitterProfile() async {
    try {
      final response = await http.get(
        Uri.parse("${url}babysitter/${widget.babysitterId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profile = CaregiverProfileModel.fromJson(data['data']);
          isLoading = false;
        });
      } else {
        print('❌ Failed to load babysitter profile');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error: $e');
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
          title: const Text('ملف الجليسة'),
        ),
        body:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF600A)),
                )
                : profile == null
                ? const Center(child: Text('لم يتم العثور على البيانات'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.orange.shade100,
                                    backgroundImage:
                                        (profile!.image != null &&
                                                profile!.image!.isNotEmpty)
                                            ? NetworkImage(profile!.image!)
                                            : null,
                                    child:
                                        (profile!.image == null ||
                                                profile!.image!.isEmpty)
                                            ? const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${profile!.firstName} ${profile!.lastName.isNotEmpty ? profile!.lastName[0] : ''}.",
                                          style: const TextStyle(
                                            fontFamily: 'NotoSansArabic',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${profile!.city} • ${profile!.yearsExperience} سنوات خبرة",
                                          style: const TextStyle(
                                            fontFamily: 'NotoSansArabic',
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (index) => const Icon(
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
                              const SizedBox(height: 20),
                              infoRow('المدينة:', profile!.city),
                              const SizedBox(height: 10),
                              infoRow(
                                'سنوات الخبرة:',
                                "${profile!.yearsExperience} سنوات",
                              ),
                              const SizedBox(height: 10),

                              infoRow('الأجر بالساعة:', profile!.rateText),
                              const SizedBox(height: 10),
                              infoRow(
                                'التدخين:',
                                profile!.isSmoker == true
                                    ? 'مدخنة 🚬'
                                    : 'غير مدخنة 🚭',
                              ),
                              const SizedBox(height: 20),
                              sectionTitle('المهارات والخدمات:'),
                              skillsSection(),
                              const SizedBox(height: 20),
                              sectionTitle('الشهادات:'),
                              certificationsSection(),
                              const SizedBox(height: 20),
                              sectionTitle('نبذة تعريفية:'),
                              Text(
                                profile!.bio,
                                style: const TextStyle(
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        final token = prefs.getString(
                                          'accessToken',
                                        );

                                        if (token == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'الرجاء تسجيل الدخول أولاً',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        // ✅ Safely prepare and convert jobData
                                        final jobData = {
                                          ...widget.jobDetails,
                                          'caregiver_id': widget.babysitterId,
                                          'service_type': 'babysitter',
                                        };

                                        // ✅ Convert DateTime values to ISO strings
                                        final sanitizedData = jobData.map((
                                          key,
                                          value,
                                        ) {
                                          if (value is DateTime) {
                                            return MapEntry(
                                              key,
                                              value.toIso8601String(),
                                            );
                                          }
                                          return MapEntry(key, value);
                                        });

                                        try {
                                          final response = await http.post(
                                            Uri.parse(saveBooking),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization': 'Bearer $token',
                                            },
                                            body: jsonEncode(sanitizedData),
                                          );

                                          if (response.statusCode == 201) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '✅ تم إرسال طلب الحجز إلى الجليسة',
                                                ),
                                              ),
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const SubscriptionPlanPage(),
                                              ),
                                            );
                                          } else {
                                            print(
                                              "❌ Booking failed: ${response.body}",
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '❌ فشل في إرسال طلب الحجز',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          print("❌ Exception: $e");
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '⚠️ حدث خطأ أثناء الحجز',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFF600A,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'احجز جلسة',
                                        style: TextStyle(
                                          fontFamily: 'NotoSansArabic',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
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
                                        'ارسل رسالة',
                                        style: TextStyle(
                                          fontFamily: 'NotoSansArabic',
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF600A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          '$title ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansArabic',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'NotoSansArabic'),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'NotoSansArabic',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget skillsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          profile!.skillsAndServices.map((skill) {
            return Chip(
              backgroundColor: Colors.orange.shade100,
              label: Text(
                skill,
                style: const TextStyle(fontFamily: 'NotoSansArabic'),
              ),
            );
          }).toList(),
    );
  }

  Widget certificationsSection() {
    return Column(
      children:
          profile!.trainingCertification.map((cert) {
            return Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFFF600A),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cert,
                    style: const TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
