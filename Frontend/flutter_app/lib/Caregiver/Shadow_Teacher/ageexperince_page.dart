import 'package:flutter/material.dart';

class ShadowTeacherStep4 extends StatefulWidget {
  const ShadowTeacherStep4({super.key});

  @override
  State<ShadowTeacherStep4> createState() => _ShadowTeacherStep4State();
}

class _ShadowTeacherStep4State extends State<ShadowTeacherStep4> {
  final List<String> ageGroups = [
    '0-3 سنوات',
    '4-6 سنوات',
    '7-12 سنة',
    '13+',
  ];

  String? selectedAgeGroup;
  bool? canAccompany;

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
        body: Column(
          children: [
            // Progress bar (40%)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.4,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF600A)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Question 1
                    const Text(
                      'ما هي الفئة العمرية التي تفضل العمل معها؟',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ageGroups.map((age) {
                        final isSelected = selectedAgeGroup == age;
                        return ChoiceChip(
                          label: Text(age,
                              style: const TextStyle(
                                  fontFamily: 'NotoSansArabic')),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFEEE5),
                          onSelected: (_) {
                            setState(() {
                              selectedAgeGroup = age;
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFFF600A)
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    const Divider(thickness: 1, height: 24),

                    // Question 2
                    const Text(
                      'هل تستطيع مرافقة الطفل في المدرسة أو الروضة؟',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['نعم', 'لا'].map((answer) {
                        final isSelected = canAccompany == (answer == 'نعم');
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                canAccompany = answer == 'نعم';
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFEEE5)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF600A)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  answer,
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansArabic',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAgeGroup != null && canAccompany != null
                      ? () {
                          // Handle next step
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    disabledBackgroundColor: Colors.orange.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
