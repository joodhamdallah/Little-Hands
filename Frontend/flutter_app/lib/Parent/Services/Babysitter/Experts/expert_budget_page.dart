import 'package:flutter/material.dart';

class ExpertSessionBudgetPage extends StatefulWidget {
  const ExpertSessionBudgetPage({super.key});

  @override
  State<ExpertSessionBudgetPage> createState() =>
      _ExpertSessionBudgetPageState();
}

class _ExpertSessionBudgetPageState extends State<ExpertSessionBudgetPage> {
  final Color primaryColor = const Color(0xFFFF600A);

  double minBudget = 100;
  double maxBudget = 250;
  double selectedBudget = 150;

  final List<String> extraOptions = [
    'إرسال تقرير بعد كل جلسة',
    'متابعة عبر الهاتف',
    'إرسال واجبات منزلية علاجية',
    'تقديم جلسة توجيهية للأهل',
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

  void onNext() {
    Navigator.pushNamed(
      context,
      '/parentExpertSummary',
      arguments: {
        'budget': selectedBudget,
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
            'ميزانية ومتطلبات الجلسة',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: 0.8,
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
                      '💸 ميزانية للجلسة الواحدة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'اختر نطاق السعر المناسب:',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'NotoSansArabic',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: selectedBudget,
                      min: minBudget,
                      max: maxBudget,
                      divisions: 15,
                      label: '${selectedBudget.round()} ₪',
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          selectedBudget = value;
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${selectedBudget.round()} ₪ للجلسة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '📝 متطلبات إضافية',
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
                      children: extraOptions.map((item) {
                        final selected = selectedExtras.contains(item);
                        return GestureDetector(
                          onTap: () => toggleExtra(item),
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
                              item,
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
                  onPressed: onNext,
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
