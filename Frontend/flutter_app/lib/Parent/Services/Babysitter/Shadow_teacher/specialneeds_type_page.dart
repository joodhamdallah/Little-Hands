import 'package:flutter/material.dart';

class SpecialNeedsServiceTypePage extends StatefulWidget {
  const SpecialNeedsServiceTypePage({super.key});

  @override
  State<SpecialNeedsServiceTypePage> createState() =>
      _SpecialNeedsServiceTypePageState();
}

class _SpecialNeedsServiceTypePageState
    extends State<SpecialNeedsServiceTypePage> {
  final Color primaryColor = const Color(0xFFFF600A);

  final List<String> serviceOptions = [
    '📚 دعم تعليمي داخل الصف',
    '🧠 تعديل سلوك خلال اليوم الدراسي',
    '🤝 تعزيز المهارات الاجتماعية',
    '🏠 متابعة أكاديمية بعد المدرسة',
    '🎒 مرافقة في النشاطات / الرحلات المدرسية',
  ];

  final Set<String> selectedServices = {};

  void toggleSelection(String service) {
    setState(() {
      if (selectedServices.contains(service)) {
        selectedServices.remove(service);
      } else {
        selectedServices.add(service);
      }
    });
  }

  void onNext() {
    Navigator.pushNamed(
      context,
      '/specialNeedsDateAndTime',
      arguments: selectedServices.toList(),
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
            'نوع الخدمة المطلوبة',
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
                      'ماذا يحتاج طفلك من مقدّم الرعاية؟',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children:
                          serviceOptions.map((service) {
                            final selected = selectedServices.contains(service);
                            return GestureDetector(
                              onTap: () => toggleSelection(service),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      selected
                                          ? primaryColor.withOpacity(0.1)
                                          : Colors.white,
                                  border: Border.all(
                                    color:
                                        selected
                                            ? primaryColor
                                            : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Center(
                                  child: Text(
                                    service,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,

                                      fontFamily: 'NotoSansArabic',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
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
                    Navigator.pushNamed(context, '/specialNeedsage');
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
