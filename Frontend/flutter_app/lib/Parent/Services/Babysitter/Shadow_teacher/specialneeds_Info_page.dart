import 'package:flutter/material.dart';

class SpecialNeedsInfoPage extends StatelessWidget {
  const SpecialNeedsInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          title: const Text(
            'مساعدة الأطفال ذوي الاحتياجات الخاصة',
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
                'ما هي خدمة مساعدة الأطفال ذوي الاحتياجات؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نوفّر لك أخصائيين ومساعدين مؤهلين لدعم الأطفال ذوي الاحتياجات الخاصة، سواء كانت احتياجات جسدية، تطورية، أو تعليمية. يتم إرسال المساعد إلى المنزل، المدرسة، أو الحضانة حسب حاجتك.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  fontFamily: 'NotoSansArabic',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'يتم اختيار المساعد المناسب بناءً على حالة الطفل، نوع الإعاقة، والخدمات المطلوبة مثل المتابعة التعليمية، الدعم الحركي، السلوك، أو المرافقة اليومية.',
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
                    _buildStep(1, 'أدخل بيانات الطفل وحدد نوع الإعاقة'),
                    _buildStep(2, 'اختر الخدمة المطلوبة ومكان الجلسة'),
                    _buildStep(3, 'استعرض المساعدين واختر الأنسب'),
                    _buildStep(4, 'تابع الجلسة واحصل على التقييم'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/specialNeedsStart');
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
                question: 'هل يتم اختيار المساعد بناءً على نوع الإعاقة؟',
                answer: 'نعم، نطابق بين حالة الطفل وخبرة المساعد لضمان تقديم الدعم المناسب.',
              ),
              const _FAQItem(
                question: 'هل يمكن حضور المساعد في المدرسة أو الحضانة؟',
                answer: 'نعم، يمكن تحديد مكان الجلسة حسب حاجة الطفل سواء في المنزل أو خارجه.',
              ),
              const _FAQItem(
                question: 'هل يمكن إلغاء الجلسة بعد الحجز؟',
                answer: 'نعم، يمكن الإلغاء مجاناً قبل 24 ساعة من الجلسة.',
              ),
              const _FAQItem(
                question: 'هل يمكن تقييم أداء المساعد؟',
                answer: 'بالتأكيد، بعد كل جلسة يمكنك كتابة تقييم للمساعدة في تحسين التجربة.',
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
