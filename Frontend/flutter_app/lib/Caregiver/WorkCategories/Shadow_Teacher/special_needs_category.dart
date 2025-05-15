import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/special_needs_provider.dart';
import 'package:provider/provider.dart';

class DisabilityExperiencePage extends StatefulWidget {
  const DisabilityExperiencePage({super.key});

  @override
  State<DisabilityExperiencePage> createState() =>
      _DisabilityExperiencePageState();
}

class _DisabilityExperiencePageState extends State<DisabilityExperiencePage> {
  final List<Map<String, dynamic>> options = [
    {'title': 'دعم الأطفال ذوي التوحد', 'icon': Icons.psychology_alt},
    {'title': 'فرط حركة وتشتت انتباه', 'icon': Icons.bolt},
    {'title': 'معلّم ظل داخل الصف', 'icon': Icons.school},
    {'title': 'دعم مهارات النطق والتواصل', 'icon': Icons.record_voice_over},
  ];

  final Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
// First of 10 questions

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
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.16,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF600A)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Rest of the content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'ما نوع الإعاقات التي لديك خبرة في التعامل معها؟',
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: List.generate(options.length, (index) {
                      final isSelected = selectedIndexes.contains(index);
                      final option = options[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIndexes.remove(index);
                            } else {
                              selectedIndexes.add(index);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF600A)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1,
                            ),
                            color: isSelected
                                ? const Color(0xFFFFEEE5)
                                : Colors.grey.shade100,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(option['icon'],
                                  size: 36, color: Color(0xFFFF600A)),
                              const SizedBox(height: 10),
                              Text(
                                option['title'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'NotoSansArabic',
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                  ElevatedButton(
                  onPressed: selectedIndexes.isNotEmpty
                      ? () {
                          // 🟠 استخراج العناوين المختارة
                          final selectedDisabilities = selectedIndexes
                              .map((index) => options[index]['title'] as String)
                              .toList();

                          // 🟠 حفظ في الـ Provider
                          final provider = Provider.of<SpecialNeedsProvider>(context, listen: false);
                          provider.update('disability_experience', selectedDisabilities);

                          // 🟠 الانتقال للصفحة التالية
                          Navigator.pushNamed(context, '/shadowteacherQ2');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    disabledBackgroundColor: const Color.fromARGB(255, 255, 218, 196),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    ),
  ),
);

  }
}
