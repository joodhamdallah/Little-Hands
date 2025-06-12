import 'package:flutter/material.dart';

class ExpertConsultationInfoPage extends StatelessWidget {
  const ExpertConsultationInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          title: const Text(
            'الاستشارات التربوية والنفسية',
            style: TextStyle(fontFamily: 'NotoSansArabic'),
          ),
          backgroundColor: const Color(0xFFFF600A),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ما هي خدمة الاستشارات التربوية والنفسية؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نقدّم لك خبراء مختصين في التربية وعلم النفس لدعم سلوك ونمو طفلك. سواء كنتِ تواجهين تحديات في التعامل مع الطفل، أو تحتاجين لتوجيه تربوي، أو دعم نفسي لطفلك، نحن نوفر لك الدعم المناسب بكل خصوصية.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'يمكنك اختيار الجلسة التي تناسب احتياجك – سواء كانت استشارة سريعة أو جلسة مطولة، مع خيار تحديد الموعد المناسب والتواصل مع الخبير مباشرة.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'كيف تعمل الخدمة؟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                  color: Color(0xFFFF600A),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStep(1, 'أدخل بيانات الطفل وحدد نوع الاستشارة المطلوبة'),
                    _buildStep(2, 'استعرض الخبراء المتاحين واختر الأنسب'),
                    _buildStep(3, 'احجز الموعد المناسب وتواصل مع الخبير'),
                    _buildStep(4, 'تابع الجلسة واحصل على التوصيات والتقييم'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/parentExpertStart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'ابدأ الحجز الآن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'الأسئلة الشائعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                  color: Color(0xFFFF600A),
                ),
              ),
              const SizedBox(height: 16),
              const _FAQItem(
                question:
                    'هل يمكنني اختيار الخبير بناءً على تقييمات الآخرين؟',
                answer:
                    'نعم، يمكنك الاطلاع على تقييمات وتجارب الآخرين قبل اختيار الخبير المناسب لاستشارة طفلك.',
              ),
              const _FAQItem(
                question: 'هل جميع الخبراء معتمدون؟',
                answer:
                    'نعم، نحرص على أن يكون جميع الخبراء مؤهلين ومرخصين في مجالات التربية أو علم النفس.',
              ),
              const _FAQItem(
                question: 'هل يمكن إلغاء الجلسة بعد حجزها؟',
                answer:
                    'نعم، يمكنك الإلغاء قبل 24 ساعة من موعد الجلسة بدون رسوم.',
              ),
              const _FAQItem(
                question: 'هل يمكن اختيار نوع الجلسة (فردية/مع الوالدين)؟',
                answer:
                    'نعم، عند إدخال البيانات يمكنك تحديد نوع الجلسة التي تناسب حالتك.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFF600A),
            radius: 14,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'NotoSansArabic',
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        collapsedIconColor: const Color(0xFFFF600A),
        iconColor: const Color(0xFFFF600A),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'NotoSansArabic',
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'NotoSansArabic',
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
