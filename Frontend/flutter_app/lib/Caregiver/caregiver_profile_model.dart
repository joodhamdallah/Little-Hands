import 'package:flutter/material.dart';
import '../models/caregiver_profile_model.dart';

class CaregiverProfilePage extends StatelessWidget {
  final CaregiverProfileModel profile;

  const CaregiverProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    String displayName = "${profile.firstName} ${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}.";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // صورة البروفايل
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange.shade100,
            backgroundImage: profile.image != null && profile.image!.isNotEmpty
              ? NetworkImage(profile.image!)
              : null,
            child: profile.image == null || profile.image!.isEmpty
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
          ),

          const SizedBox(height: 15),

          // الاسم
          Text(
            displayName,
            style: const TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // 🏙️ كارد المعلومات الأساسية
          _buildInfoCard(),

          const SizedBox(height: 20),

          // 🌟 كارد المهارات والخدمات
          if (profile.skillsAndServices.isNotEmpty) _buildSkillsCard(),

          const SizedBox(height: 20),

          // 🎓 كارد الشهادات
          if (profile.trainingCertification.isNotEmpty) _buildCertificationsCard(),

          const SizedBox(height: 20),

          // 📝 كارد النبذة التعريفية
          _buildBioCard(),
        ],
      ),
    );
  }

  // ➡️ كارد معلومات أساسية
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

  // ➡️ كارد المهارات والخدمات
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
              children: profile.skillsAndServices.map((skill) {
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

  // ➡️ كارد الشهادات
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
              children: profile.trainingCertification.map((cert) {
                return Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFFFF600A)),
                    const SizedBox(width: 8),
                    Text(
                      cert,
                      style: const TextStyle(fontFamily: 'NotoSansArabic'),
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

  // ➡️ كارد النبذة التعريفية
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
          ],
        ),
      ),
    );
  }
}
