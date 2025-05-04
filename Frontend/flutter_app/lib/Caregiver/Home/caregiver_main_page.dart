import 'package:flutter/material.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart';

class CaregiverHomeMainPage extends StatelessWidget {
  final CaregiverProfileModel profile;

  const CaregiverHomeMainPage({super.key, required this.profile});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "صباح الخير";
    if (hour < 17) return "مساء الخير";
    return "مساء الخير";
  }

  @override
  Widget build(BuildContext context) {
    final String caregiverName = "${profile.firstName} ${profile.lastName}";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ تحية مخصصة
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "${getGreeting()}, $caregiverName",
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF600A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ وصف ترحيبي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "يمكنك من هنا إدارة مواعيد عملك، مراجعة حجوزاتك، وتحديث معلوماتك الشخصية.",
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ صورة مقدم الرعاية (إن وجدت)
            if (profile.image != null && profile.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  profile.image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
