import 'package:flutter/material.dart';

class BabysittingInfoPage extends StatelessWidget {
  const BabysittingInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          title: const Text(
            'رعاية الأطفال في المنزل',
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
                'ما هي خدمة رعاية الأطفال في المنزل؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نوفّر لك جليسات أطفال موثوقات، مدرّبات ومؤهلات لرعاية طفلك في بيئة منزلك المريحة. سواء كنتِ بحاجة إلى وقت للراحة، العمل أو الطوارئ، نساعدك على إيجاد الدعم المناسب.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'خدمة جليسة الأطفال متوفرة لجميع المراحل العمرية. نساعدك في إيجاد أقرب جليسة في موقعك، وتوفر العديد منهن خدمات إضافية مثل إطعام الطفل، تنظيف المنزل، تدريس الطفل، وغيرها من الخدمات المفيدة حسب احتياجك.',
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
                    _buildStep(1, 'أدخل بيانات طفلك واختر المدينة'),
                    _buildStep(2, 'استعرض الجليسات المتاحات واختر الأنسب'),
                    _buildStep(3, 'احجز الموعد المناسب وتواصل مع الجليسة'),
                    _buildStep(4, 'تابع الجلسة واحصل على تقييم بعد الانتهاء'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/parentBabysitteraddress');
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
                    'هل يمكنني اختيار الجليسة بناءً على تقييمات أولياء الأمور؟',
                answer:
                    'نعم، يمكنك الاطلاع على تقييمات وتجارب الآخرين قبل اختيار الجليسة المناسبة لطفلك.',
              ),
              const _FAQItem(
                question: 'هل جميع الجليسات مؤهلات ومعتمدات؟',
                answer:
                    'نحن نحرص على قبول الجليسات المؤهلات فقط بعد فحص الهوية والمعلومات المهنية والتدريبية.',
              ),
              const _FAQItem(
                question: 'هل يمكن إلغاء الحجز بعد تأكيده؟',
                answer:
                    'نعم، يمكنك الإلغاء قبل 24 ساعة من موعد الجلسة بدون أي رسوم إضافية.',
              ),
              const _FAQItem(
                question: 'هل الجليسات يقدمن خدمات إضافية؟',
                answer:
                    'بعض الجليسات يقدمن خدمات مثل المساعدة في الدراسة، إطعام الطفل، أو ترتيب المنزل – ويمكنك الاتفاق مع الجليسة مسبقًا على ذلك.',
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
