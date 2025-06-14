import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/available_appointments_page.dart';
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
  String locationLabel = 'جارٍ التحميل...';
  double? distanceInKm;

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

        final parsedProfile = CaregiverProfileModel.fromJson(data['data']);

        // ✅ Now safe to access parsedProfile.location
        if (parsedProfile.location != null) {
          final lat = parsedProfile.location!['lat'];
          final lng = parsedProfile.location!['lng'];
          locationLabel = await getLocationLabel(lat, lng);
        }

        distanceInKm = parsedProfile.distanceInKm;

        setState(() {
          profile = parsedProfile;
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
    final String? imagePath = profile?.image;
    final String? imageUrl =
        (imagePath != null && imagePath.isNotEmpty)
            ? '$baseUrl/${imagePath.replaceAll('\\', '/')}'
            : null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          automaticallyImplyLeading: false, // Disable default back
          title: const Text(
            'ملف الجليسة',
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
                                        imageUrl != null
                                            ? NetworkImage(imageUrl)
                                            : null,
                                    child:
                                        imageUrl == null
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
                                          children: [
                                            Row(
                                              children: List.generate(5, (
                                                index,
                                              ) {
                                                double rating =
                                                    profile!.averageRating;
                                                return Icon(
                                                  index < rating.round()
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 18,
                                                  color: const Color(
                                                    0xFFFFA726,
                                                  ),
                                                );
                                              }),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              profile!.averageRating
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              infoRow('المدينة:', profile!.city),

                              const SizedBox(height: 10),
                              if (locationLabel.isNotEmpty)
                                infoRow('المنطقة:', locationLabel),

                              if (distanceInKm != null)
                                infoRow(
                                  'تبعد عنك:',
                                  "${distanceInKm!.toStringAsFixed(1)} كم",
                                ),
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
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    AvailableAppointmentsPage(
                                                      babysitterId:
                                                          widget.babysitterId,
                                                      jobDetails:
                                                          widget.jobDetails,
                                                    ),
                                          ),
                                        );
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
                                      onPressed: () async {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        final currentUserId = prefs.getString(
                                          'userId',
                                        );
                                        final otherUserName =
                                            "${profile!.firstName} ${profile!.lastName}";

                                        if (currentUserId != null &&
                                            widget.babysitterId.isNotEmpty) {
                                          Navigator.pushNamed(
                                            context,
                                            '/chat',
                                            arguments: {
                                              'myId': currentUserId,
                                              'otherId': widget.babysitterId,
                                              'otherUserName':
                                                  otherUserName, // 👈 Add name here
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "حدث خطأ في تحميل بيانات المستخدم أو الجليسة",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
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
}
