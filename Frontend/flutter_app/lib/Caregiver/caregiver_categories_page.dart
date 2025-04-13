import 'package:flutter/material.dart';

class CaregiverCategorySelection extends StatefulWidget {
  const CaregiverCategorySelection({super.key});

  @override
  State<CaregiverCategorySelection> createState() =>
      _CaregiverCategorySelectionState();
}

class _CaregiverCategorySelectionState
    extends State<CaregiverCategorySelection> {
  String? selectedCategory;
  final Map<String, String> categoryRoutes = {
    'جليسة أطفال': '/babysitter',
    'إستشاري رعاية الطفل': '/childConsult',
    'مساعدة الأطفال ذوي الاحتياجات': '/specialNeeds',
    'مدرس خصوصي': '/tutor',
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ما نوع الوظيفة التي تبحث عنها؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'لا تقلق - يمكنك دائمًا إنشاء ملفات تعريف إضافية لاحقًا.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildCategoryCard(
                      context,
                      title: 'إستشاري رعاية الطفل',
                      subtitle:
                          'تقديم الإستشارات التربوية والنفسية للأهل والأطفال.',
                      icon: Icons.psychology_alt,
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'جليسة أطفال',
                      subtitle: 'رعاية الأطفال في غياب الأهل داخل المنزل.',
                      icon: Icons.child_care,
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'مساعدة الأطفال ذوي الاحتياجات',
                      subtitle:
                          'مساعدة الأطفال من ذوي الاحتياجات داخل المدرسة .',
                      icon: Icons.accessibility_new,
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'مدرس خصوصي',
                      subtitle:
                          'دروس تعليمية خاصة في العديد من مواد المنهج الفلسطني لمختلف الأعمار.',
                      icon: Icons.menu_book,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    selectedCategory != null
                        ? () {
                          final route = categoryRoutes[selectedCategory!];
                          if (route != null) {
                            Navigator.pushNamed(context, route);
                          }
                        }
                        : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF600A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'التالي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'NotoSansArabic',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedCategory == title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3ED) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: const Color(0xFFFF600A), width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Color(0xFFFF600A)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansArabic',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
