import 'package:flutter/material.dart';

class SelectRolePage extends StatelessWidget {
  const SelectRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF600A); // Orange theme

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF6F0),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text(
            'اختر نوع المستخدم',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              _buildRoleCard(
                context,
                title: 'ولي أمر',
                subtitle:
                    'هل أنت والد/ة لطفل وتبحث عن خدمات لرعاية طفلك؟ انضم إلينا الآن وابدأ بالحجز بسهولة.',
                icon: Icons.family_restroom,
                color: Colors.teal,
                route: '/register',
              ),

              const SizedBox(height: 30),
              _buildRoleCard(
                context,
                title: 'مقدم رعاية',
                subtitle:
                    'هل أنت مقدم/ة رعاية وتبحث عن فرصة للعمل؟ سجّل الآن وابدأ باستقبال الحجوزات.',
                icon: Icons.volunteer_activism,
                color: Colors.deepPurple,
                route: '/registerCaregivers',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 30,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
