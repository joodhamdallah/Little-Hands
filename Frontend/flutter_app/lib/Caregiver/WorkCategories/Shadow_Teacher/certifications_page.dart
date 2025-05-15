import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/special_needs_provider.dart';
import 'package:provider/provider.dart';

class ShadowTeacherStep3 extends StatefulWidget {
  const ShadowTeacherStep3({super.key});

  @override
  State<ShadowTeacherStep3> createState() => _ShadowTeacherStep3State();
}

class _ShadowTeacherStep3State extends State<ShadowTeacherStep3> {
  final List<String> trainingOptions = [
    'تحليل سلوك تطبيقي ABA',
    'PECS',
    'تدريب حسي',
    'الإسعافات الأولية',
    'لا شيء',
  ];

  final Set<int> selectedIndexes = {};

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
            // Progress bar (30%)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.48,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF600A)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'هل لديك تدريبات أو شهادات مهنية؟',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: trainingOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final isSelected = selectedIndexes.contains(index);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (trainingOptions[index] == 'لا شيء') {
                                  // إذا اختار "لا شيء" نلغي كل الخيارات الأخرى
                                  selectedIndexes.clear();
                                  selectedIndexes.add(index);
                                } else {
                                  selectedIndexes.remove(trainingOptions.indexOf('لا شيء'));
                                  if (isSelected) {
                                    selectedIndexes.remove(index);
                                  } else {
                                    selectedIndexes.add(index);
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
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
                              child: Text(
                                trainingOptions[index],
                                style: const TextStyle(
                                  fontFamily: 'NotoSansArabic',
                                  fontSize: 16,
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
            ),

            // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Builder(
                  builder: (context) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedIndexes.isNotEmpty
                            ? () {
                                final selectedTrainings = selectedIndexes
                                    .map((i) => trainingOptions[i])
                                    .toList();

                                final provider = Provider.of<SpecialNeedsProvider>(context, listen: false);
                                provider.update('training_certifications', selectedTrainings);

                                Navigator.pushNamed(context, '/shadowteacherQ4');
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
