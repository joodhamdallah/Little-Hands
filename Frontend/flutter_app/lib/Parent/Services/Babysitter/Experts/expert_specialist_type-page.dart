import 'package:flutter/material.dart';

class ExpertSpecialistTypePage extends StatefulWidget {
  const ExpertSpecialistTypePage({super.key});

  @override
  State<ExpertSpecialistTypePage> createState() =>
      _ExpertSpecialistTypePageState();
}

class _ExpertSpecialistTypePageState extends State<ExpertSpecialistTypePage> {
  final Color primaryColor = const Color(0xFFFF600A);

  final Map<String, List<Map<String, dynamic>>> expertCategories = {
    'أخصائي سلوك وتعامل': [
      {'title': 'نوبات الغضب', 'icon': Icons.warning_amber_outlined},
      {'title': 'السلوك العدواني', 'icon': Icons.flash_on},
      {'title': 'فرط الحركة', 'icon': Icons.directions_run},
      {'title': 'تحدي القوانين', 'icon': Icons.gavel},
    ],
    'أخصائي اضطرابات النوم': [
      {'title': 'صعوبات النوم', 'icon': Icons.bedtime},
      {'title': 'الاستيقاظ الليلي', 'icon': Icons.nightlight},
      {'title': 'روتين النوم', 'icon': Icons.schedule},
    ],
    'أخصائي تغذية الأطفال': [
      {'title': 'الرضاعة الطبيعية', 'icon': Icons.baby_changing_station},
      {'title': 'الطعام الصلب', 'icon': Icons.fastfood},
      {'title': 'رفض الطعام', 'icon': Icons.block},
      {'title': 'نقص الشهية', 'icon': Icons.local_dining},
    ],
    'أخصائي العلاقات داخل الأسرة': [
      {'title': 'إرشاد الأمهات الجدد', 'icon': Icons.emoji_emotions},
      {'title': 'تحسين العلاقة مع الطفل', 'icon': Icons.emoji_emotions},
      {'title': 'الغيرة بين الإخوة', 'icon': Icons.family_restroom},
      {'title': 'دعم الأهل نفسيًا', 'icon': Icons.support},
    ],
  };

  final Set<String> selectedConcerns = {};

  void toggleSelection(String concern) {
    setState(() {
      if (selectedConcerns.contains(concern)) {
        selectedConcerns.remove(concern);
      } else {
        selectedConcerns.add(concern);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: Color(0xFFFDFDFD),
          title: const Text(
            'نوع الأخصائي الذي تبحث عنه',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: 0.2,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ما نوع الأخصائي الذي يحتاجه طفلك؟',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...expertCategories.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'NotoSansArabic',
                              color: Color(0xFFFF600A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.9,
                            children: entry.value.map((item) {
                              final isSelected =
                                  selectedConcerns.contains(item['title']);
                              return GestureDetector(
                                onTap: () => toggleSelection(item['title']),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor.withOpacity(0.1)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item['icon'],
                                        color: primaryColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['title'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'NotoSansArabic',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedConcerns.isNotEmpty
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/parentExpertChildAgePage',
                            arguments: selectedConcerns.toList(),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                      color: Colors.white,
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
