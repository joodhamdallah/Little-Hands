import 'package:flutter/material.dart';

class SpecialNeedsDisabilityAndAgePage extends StatefulWidget {
  const SpecialNeedsDisabilityAndAgePage({super.key});

  @override
  State<SpecialNeedsDisabilityAndAgePage> createState() =>
      _SpecialNeedsDisabilityAndAgePageState();
}

class _SpecialNeedsDisabilityAndAgePageState extends State<SpecialNeedsDisabilityAndAgePage> {
  final Color primaryColor = const Color(0xFFFF600A);

  final List<String> disabilityTypes = [
    'توحد',
    'صعوبات تعلم',
    'فرط الحركة وتشتت الانتباه',
    'إعاقات جسدية',
    'إعاقات سمعية أو بصرية',
    'أخرى',
  ];

  final List<String> ageRanges = [
    '3-5 سنوات',
    '6-9 سنوات',
    '10-13 سنة',
    '14 سنة فأكثر',
  ];

  final Set<String> selectedDisabilities = {};
  final Set<String> selectedAges = {};

  void toggleDisability(String d) {
    setState(() {
      if (selectedDisabilities.contains(d)) {
        selectedDisabilities.remove(d);
      } else {
        selectedDisabilities.add(d);
      }
    });
  }

  void toggleAge(String a) {
    setState(() {
      if (selectedAges.contains(a)) {
        selectedAges.remove(a);
      } else {
        selectedAges.add(a);
      }
    });
  }

  void onNext() {
    Navigator.pushNamed(
      context,
      '/specialNeedsSessionDetails',
      arguments: {
        'disabilities': selectedDisabilities.toList(),
        'ages': selectedAges.toList(),
      },
    );
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
            'نوع التحدي والعمر',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: 0.4,
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
                      'نوع التحدي أو الإعاقة:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2,
                      children: disabilityTypes.map((d) {
                        final selected = selectedDisabilities.contains(d);
                        return GestureDetector(
                          onTap: () => toggleDisability(d),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? primaryColor
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      ' عمر الطفل  ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2,
                      children: ageRanges.map((a) {
                        final selected = selectedAges.contains(a);
                        return GestureDetector(
                          onTap: () => toggleAge(a),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? primaryColor
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                a,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                  child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/specialNeedsschedule');
                  },
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
