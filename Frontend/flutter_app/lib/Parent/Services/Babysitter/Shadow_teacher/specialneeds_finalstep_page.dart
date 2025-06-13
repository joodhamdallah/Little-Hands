import 'package:flutter/material.dart';

class SpecialNeedsFinalStepPage extends StatefulWidget {
  const SpecialNeedsFinalStepPage({super.key});

  @override
  State<SpecialNeedsFinalStepPage> createState() =>
      _SpecialNeedsFinalStepPageState();
}

class _SpecialNeedsFinalStepPageState extends State<SpecialNeedsFinalStepPage> {
  final Color primaryColor = const Color(0xFFFF600A);

  double selectedPrice = 50;
  final double minPrice = 30;
  final double maxPrice = 80;

  final List<String> extraNeeds = [
    '📘 متابعة أكاديمية',
    '📝 كتابة تقارير متابعة',
    '📞 تواصل مع الأهل',
    '🧩 تدريب الطفل على المهارات الحياتية',
    '🧪 دعم الطفل أثناء الامتحانات',
  ];

  final Set<String> selectedExtras = {};

  void toggleExtra(String item) {
    setState(() {
      if (selectedExtras.contains(item)) {
        selectedExtras.remove(item);
      } else {
        selectedExtras.add(item);
      }
    });
  }

  void onSubmit() {
    Navigator.pushNamed(
      context,
      '/specialNeedsConfirmationPage',
      arguments: {
        'price': selectedPrice.round(),
        'extras': selectedExtras.toList(),
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
            'الخطوة الأخيرة',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: 0.9,
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
                      '💰 اختر السعر المناسب:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: selectedPrice,
                      min: minPrice,
                      max: maxPrice,
                      divisions: ((maxPrice - minPrice) / 5).round(),
                      label: '${selectedPrice.round()} ₪/ساعة',
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          selectedPrice = value;
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${selectedPrice.round()} شيكل لكل ساعة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '📌 احتياجات إضافية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: extraNeeds.map((need) {
                        final selected = selectedExtras.contains(need);
                        return GestureDetector(
                          onTap: () => toggleExtra(need),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color:
                                    selected ? primaryColor : Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              need,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'NotoSansArabic',
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
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'التالي ',
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
