// subcategory_screen.dart
import 'package:flutter/material.dart';

class SubcategoryScreen extends StatefulWidget {
  final List<String> categoryList;

  const SubcategoryScreen({super.key, required this.categoryList});

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  final Set<String> selectedSubcategories = {};

  Map<String, List<Map<String, dynamic>>> getSubcategoriesMap() {
    return {
      'استشارة سلوكية': [
        {'title': 'نوبات الغضب', 'icon': Icons.warning_amber_outlined},
        {'title': 'السلوك العدواني', 'icon': Icons.flash_on},
        {'title': 'فرط الحركة', 'icon': Icons.directions_run},
        {'title': 'تحدي القوانين', 'icon': Icons.gavel},
      ],
      'استشارة اضطرابات النوم': [
        {'title': 'صعوبات النوم', 'icon': Icons.bedtime},
        {'title': 'الاستيقاظ الليلي', 'icon': Icons.nightlight},
        {'title': 'روتين النوم', 'icon': Icons.schedule},
      ],
      'استشارة تغذية الأطفال': [
        {'title': 'الرضاعة الطبيعية', 'icon': Icons.baby_changing_station},
        {'title': 'الطعام الصلب', 'icon': Icons.fastfood},
        {'title': 'رفض الطعام', 'icon': Icons.block},
        {'title': 'نقص الشهية', 'icon': Icons.local_dining},
      ],
      'استشارة العلاقات داخل الأسرة': [
        {'title': 'إرشاد الأمهات الجدد', 'icon': Icons.emoji_emotions},
        {'title': 'تحسين العلاقة مع الطفل', 'icon': Icons.emoji_emotions},
        {'title': 'الغيرة بين الإخوة', 'icon': Icons.family_restroom},
        {'title': 'دعم الأهل نفسيًا', 'icon': Icons.support},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final allSubs = getSubcategoriesMap();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text(
            'اختر الموضوعات التي تقدمها',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.categoryList.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final category = widget.categoryList[index];
                  final subList = allSubs[category] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.8,
                            ),
                        itemBuilder: (context, subIndex) {
                          final sub = subList[subIndex];
                          final title = sub['title'] as String;
                          final icon = sub['icon'] as IconData;
                          final isSelected = selectedSubcategories.contains(
                            title,
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedSubcategories.remove(title);
                                } else {
                                  selectedSubcategories.add(title);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xFFFFE3D3)
                                        : const Color(0xFFFFF3ED),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? const Color(0xFFFF600A)
                                          : Colors.black12,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icon,
                                    color: const Color(0xFFFF600A),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'NotoSansArabic',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 24.0,
                top: 8,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      selectedSubcategories.isNotEmpty
                          ? () {
                            Navigator.pushNamed(
                              context,
                              '/expertQualificationsQ3',
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
