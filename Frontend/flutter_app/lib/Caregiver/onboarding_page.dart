import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OnboardingRoadmapPage extends StatefulWidget {
  const OnboardingRoadmapPage({super.key});

  @override
  State<OnboardingRoadmapPage> createState() => _OnboardingRoadmapPageState();
}

class _OnboardingRoadmapPageState extends State<OnboardingRoadmapPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['email'] != null) {
        setState(() {
          userEmail = args['email'];
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        _animatedBackgroundBubble(
                          offsetX: 30,
                          offsetY: 10,
                          radius: 25,
                          color: const Color.fromARGB(255, 94, 255, 99),
                        ),
                        _animatedBackgroundBubble(
                          offsetX: 100,
                          offsetY: 40,
                          radius: 15,
                          color: const Color.fromARGB(255, 255, 98, 151),
                        ),
                        _animatedBackgroundBubble(
                          offsetX: 200,
                          offsetY: 20,
                          radius: 35,
                          color: const Color.fromARGB(255, 255, 136, 38),
                        ),
                        _animatedBackgroundBubble(
                          offsetX: 280,
                          offsetY: 5,
                          radius: 20,
                          color: const Color.fromARGB(255, 255, 237, 79),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 20,
                    top: 20,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        'assets/images/onboarding3.png',
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'وصول غير محدود إلى الوظائف بخطوتين إضافيتين فقط',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildStep(
                        context,
                        title: 'تم إنشاء الحساب',
                        description:
                            'عمل ممتاز! لن تظهر للعائلات حتى تقوم بالخطوتين 2 و 3',
                        icon: Icons.verified_user,
                        color: Colors.green,
                      ),
                      const Divider(height: 32),
                      _buildStep(
                        context,
                        title: 'اكمل ملفك الشخصي',
                        description:
                            'أضف معلومات عن مهاراتك وخبراتك السابقة التي تستخدمها للتقديم على الوظائف.',
                        icon: Icons.person_outline,
                        color: Colors.orange,
                      ),
                      const Divider(height: 32),
                      _buildStep(
                        context,
                        title: 'تحقق من هويتك',
                        description:
                            ' سلامتك هي أولويتنا القصوى. سوف تحتاج إلى بطاقة هوية حكومية وهاتف ذكي لتنطلق في رحلة العمل معنا .',
                        icon: Icons.verified,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (userEmail == null) return;

                    final url = Uri.parse(
                      "http://10.0.2.2:3000/api/caregiver/checkVerificationStatus",
                    );
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"email": userEmail}),
                    );

                    final json = jsonDecode(response.body);

                    if (response.statusCode == 200 &&
                        json["isVerified"] == true) {
                      Navigator.pushNamed(context, '/caregiverCategory');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "يرجى التحقق من بريدك الإلكتروني وتفعيل الحساب أولًا.",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'اكمل بناء ملفك الشخصي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedBackgroundBubble({
    required double offsetX,
    required double offsetY,
    required double radius,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final movement = sin(_controller.value * 2 * pi) * 4;
        return Positioned(
          left: offsetX + movement,
          top: offsetY + movement,
          child: CircleAvatar(radius: radius, backgroundColor: color),
        );
      },
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
