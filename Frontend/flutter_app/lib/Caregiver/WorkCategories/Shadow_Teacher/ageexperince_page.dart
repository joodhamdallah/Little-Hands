import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/special_needs_provider.dart' show SpecialNeedsProvider;
import 'package:provider/provider.dart';

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

  final List<String> daysOfWeek = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  String? selectedAgeGroup;
  bool? canAccompany;
  Map<String, Set<String>> availability = {}; // {'السبت': {'صباح', 'مساء'}}

  @override
  void initState() {
    super.initState();
    for (var day in daysOfWeek) {
      availability[day] = {};
    }
  }

  void toggleAvailability(String day, String period) {
    setState(() {
      if (availability[day]!.contains(period)) {
        availability[day]!.remove(period);
      } else {
        availability[day]!.add(period);
      }
    });
  }

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
                  value: 0.64,
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
                    const Divider(thickness: 1),

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
                    const Divider(thickness: 1),

                    // Question 3
                    const Text(
                      'حدد الأوقات التي تكون متاحًا فيها للعمل:',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...daysOfWeek.map((day) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                fontFamily: 'NotoSansArabic',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: ['صباح', 'مساء'].map((period) {
                                final isSelected =
                                    availability[day]!.contains(period);
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => toggleAvailability(day, period),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFFFEEE5)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFFF600A)
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          period,
                                          style: const TextStyle(
                                            fontFamily: 'NotoSansArabic',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Next Button
       Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Builder(
              builder: (context) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedAgeGroup != null &&
                            canAccompany != null &&
                            availability.values.any((set) => set.isNotEmpty))
                        ? () {
                            // تحويل الـ Set إلى List لتخزينها
                            final Map<String, List<String>> availabilityMap =
                                availability.map((key, value) => MapEntry(key, value.toList()));

                            final provider = Provider.of<SpecialNeedsProvider>(context, listen: false);
                            provider.updateMany({
                              'preferred_age_group': selectedAgeGroup,
                              'can_accompany_to_school': canAccompany,
                              'availability': availabilityMap,
                            });

                            Navigator.pushNamed(context, '/shadowteacherbio');
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
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          ],
        ),
      ),
    );
  }
}
