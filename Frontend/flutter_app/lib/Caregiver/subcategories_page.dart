import 'package:flutter/material.dart';

class SubcategoryScreen extends StatelessWidget {
  final String category;

  const SubcategoryScreen({super.key, required this.category});

  List<String> getSubcategories(String category) {
    switch (category) {
      case 'جليسة أطفال':
        return [
          'رعاية أطفال رضّع (0-2 سنة)',
          'رعاية أطفال صغار (3-5 سنوات)',
          'رعاية أطفال في سن المدرسة (6-12 سنة)',
          'جلسات مؤقتة أو طارئة',
        ];
      case 'إستشاري رعاية الطفل':
        return [
          'استشارة تربوية',
          'استشارة نفسية للطفل',
          'استشارة سلوكية',
          'استشارة اضطرابات النوم',
          'استشارة تغذية الأطفال',
          'استشارة العلاقات داخل الأسرة',
        ];
      case 'مدرس خصوصي':
        return [
          'المرحلة الابتدائية (جميع المواد)',
          'المرحلة الإعدادية (رياضيات، علوم، لغة، إلخ)',
          'المرحلة الثانوية (تخصصات علمية وأدبية)',
          'تعليم اللغات (إنجليزية، فرنسية، إلخ)',
          'تعليم مهارات خاصة (برمجة، رسم، موسيقى)',
        ];
      case 'مساعدة الأطفال ذوي الاحتياجات':
        return [
          'معلّم ظل داخل الصف (Shadow Teacher)',
          'رعاية فردية منزلية',
          'دعم مهارات النطق والتواصل',
          'دعم التعلم للأطفال ذوي اضطراب فرط الحركة وتشتت الانتباه',
          'دعم الأطفال من ذوي التوحد',
        ];
      default:
        return [];
    }
  }

  IconData getIconForItem(String item) {
    if (item.contains('رضّع')) return Icons.child_friendly;
    if (item.contains('صغار')) return Icons.face_retouching_natural;
    if (item.contains('سن المدرسة')) return Icons.school;
    if (item.contains('جلسات ليلية')) return Icons.nightlight;
    if (item.contains('طارئة')) return Icons.warning;
    if (item.contains('تربوية')) return Icons.menu_book;
    if (item.contains('نفسية')) return Icons.psychology;
    if (item.contains('سلوكية')) return Icons.track_changes;
    if (item.contains('النوم')) return Icons.bedtime;
    if (item.contains('تغذية')) return Icons.restaurant;
    if (item.contains('العلاقات')) return Icons.family_restroom;
    if (item.contains('الابتدائية')) return Icons.looks_one;
    if (item.contains('الإعدادية')) return Icons.looks_two;
    if (item.contains('الثانوية')) return Icons.looks_3;
    if (item.contains('اللغات')) return Icons.language;
    if (item.contains('مهارات')) return Icons.brush;
    if (item.contains('ظل')) return Icons.visibility;
    if (item.contains('رعاية فردية')) return Icons.home;
    if (item.contains('النطق')) return Icons.record_voice_over;
    if (item.contains('فرط الحركة')) return Icons.directions_run;
    if (item.contains('التوحد')) return Icons.diversity_3;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = getSubcategories(category);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'اختر التخصص الفرعي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansArabic',
            ),
          ),
          backgroundColor: const Color(0xFFFF600A),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التصنيفات لـ "$category":',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final item = subcategories[index];
                    final icon = getIconForItem(item);
                    return GestureDetector(
                      onTap: () {
                        // Handle subcategory selection
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE7DA), Color(0xFFFFF3ED)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xFFFF600A),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: Color(0xFFFF600A)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
