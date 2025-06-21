import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import '../../models/caregiver_profile_model.dart';

class CaregiverProfilePage extends StatefulWidget {
  final CaregiverProfileModel profile;

  const CaregiverProfilePage({super.key, required this.profile});

  @override
  State<CaregiverProfilePage> createState() => _CaregiverProfilePageState();
}

class _CaregiverProfilePageState extends State<CaregiverProfilePage> {
  late CaregiverProfileModel profile;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    String displayName = "${profile.firstName} ${profile.lastName}";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          if (profile.image != null && profile.image!.isNotEmpty)
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.orange.shade100,
                backgroundImage: NetworkImage(
                  profile.image!.replaceAll('\\', '/').startsWith('http')
                      ? profile.image!
                      : '$baseUrl/${profile.image!.replaceAll('\\', '/')}',
                ),
              ),
            ),
          const SizedBox(height: 15),
          Text(
            displayName,
            style: const TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          _buildInfoCard(),
          const SizedBox(height: 20),
          if (profile.skillsAndServices.isNotEmpty) _buildSkillsCard(),
          const SizedBox(height: 20),
          if (profile.trainingCertification.isNotEmpty)
            _buildCertificationsCard(),
          const SizedBox(height: 20),
          _buildBioCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFFF600A)),
                const SizedBox(width: 8),
                Text(
                  'المدينة: ${profile.city}',
                  style: const TextStyle(fontFamily: 'NotoSansArabic'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFFF600A)),
                const SizedBox(width: 8),
                Text(
                  'سنوات الخبرة: ${profile.yearsExperience} سنوات',
                  style: const TextStyle(fontFamily: 'NotoSansArabic'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (profile.isSmoker != null)
              Row(
                children: [
                  const Icon(Icons.smoking_rooms, color: Color(0xFFFF600A)),
                  const SizedBox(width: 8),
                  Text(
                    profile.isSmoker! ? 'مدخن 🚬' : 'غير مدخن 🚭',
                    style: const TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المهارات والخدمات:',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  profile.skillsAndServices.map((skill) {
                    return Chip(
                      backgroundColor: Colors.orange.shade100,
                      label: Text(
                        skill,
                        style: const TextStyle(fontFamily: 'NotoSansArabic'),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الشهادات:',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children:
                  profile.trainingCertification.map((cert) {
                    return Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFFFF600A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cert,
                            style: const TextStyle(
                              fontFamily: 'NotoSansArabic',
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نبذة تعريفية:',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              profile.bio,
              style: const TextStyle(fontFamily: 'NotoSansArabic'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFFFF600A)),
                const SizedBox(width: 8),
                if (profile.ratePerHour != null)
                  Text(
                    profile.ratePerHour!['min'] == profile.ratePerHour!['max']
                        ? "الأجر بالساعة: ${profile.ratePerHour!['min']} شيكل"
                        : "الأجر بالساعة: من ${profile.ratePerHour!['min']} إلى ${profile.ratePerHour!['max']} شيكل",
                    style: const TextStyle(fontFamily: 'NotoSansArabic'),
                  )
                else
                  Text(
                    "الأجر للجلسة: ${profile.rateText}",
                    style: const TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
