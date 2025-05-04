import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_rate_parent4.dart';

class AddChildrenAgePage extends StatefulWidget {
  final Map<String, dynamic> previousData;
  const AddChildrenAgePage({super.key, required this.previousData});

  @override
  State<AddChildrenAgePage> createState() => _AddChildrenAgePageState();
}

class _AddChildrenAgePageState extends State<AddChildrenAgePage> {
  List<String?> childrenAges = [null];
  final TextEditingController medicalController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool hasMedicalCondition = false;
  bool takesMedicine = false;

  final List<String> ageOptions = [
    'رضيع (0-11 شهرًا)',
    'طفل صغير (1-3 سنة)',
    'ما قبل المدرسة (4-5 سنوات)',
    'ابتدائي (6-10 سنوات)',
    'إعدادي (11 سنة فأكثر)',
  ];

  void addChild() {
    setState(() => childrenAges.add(null));
  }

  void removeChild(int index) {
    setState(() => childrenAges.removeAt(index));
  }

  bool validateSelection() {
    return childrenAges.every((age) => age != null);
  }

  Widget buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 0),
    child: Divider(color: Colors.black12, thickness: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'بيانات الأطفال',
            style: TextStyle(fontFamily: 'NotoSansArabic'),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.grey,
                  color: Color(0xFFFF600A),
                  minHeight: 6,
                ),
                const SizedBox(height: 24),
                const Text(
                  'أخبرنا أكثر عن الأطفال الذين يحتاجون إلى رعاية:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: addChild,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFFFF600A),
                  ),
                  label: const Text(
                    'إضافة طفل آخر',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 15,
                      color: Color(0xFFFF600A),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      ...List.generate(childrenAges.length, (index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'طفل ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSansArabic',
                                  ),
                                ),
                                if (childrenAges.length > 1)
                                  TextButton(
                                    onPressed: () => removeChild(index),
                                    child: const Text(
                                      'إزالة',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'NotoSansArabic',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<String>(
                                value: childrenAges[index],
                                isExpanded: true,
                                alignment: Alignment.centerRight,
                                underline: const SizedBox(),
                                hint: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'اختر الفئة العمرية',
                                    style: TextStyle(
                                      fontFamily: 'NotoSansArabic',
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                items:
                                    ageOptions.map((age) {
                                      return DropdownMenuItem(
                                        value: age,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          age,
                                          style: const TextStyle(
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() => childrenAges[index] = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                      buildDivider(),
                      const SizedBox(height: 20),
                      const Text(
                        '🩺 هل لدى الطفل أي حالات صحية مزمنة؟',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text(
                              'نعم',
                              style: TextStyle(fontFamily: 'NotoSansArabic'),
                            ),
                            selected: hasMedicalCondition,
                            onSelected:
                                (val) =>
                                    setState(() => hasMedicalCondition = true),
                            selectedColor: const Color(0xFFFFE3D3),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text(
                              'لا',
                              style: TextStyle(fontFamily: 'NotoSansArabic'),
                            ),
                            selected: !hasMedicalCondition,
                            onSelected:
                                (val) =>
                                    setState(() => hasMedicalCondition = false),
                            selectedColor: const Color(0xFFFFE3D3),
                          ),
                        ],
                      ),
                      if (hasMedicalCondition)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextField(
                            controller: medicalController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText:
                                  'اذكر الحالة الصحية (مثل: الربو، السكري، الحساسية...)',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: const TextStyle(
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        '💊 هل يحتاج إلى تناول أدوية معينة خلال فترة الرعاية؟',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text(
                              'نعم',
                              style: TextStyle(fontFamily: 'NotoSansArabic'),
                            ),
                            selected: takesMedicine,
                            onSelected:
                                (val) => setState(() => takesMedicine = true),
                            selectedColor: const Color(0xFFFFE3D3),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text(
                              'لا',
                              style: TextStyle(fontFamily: 'NotoSansArabic'),
                            ),
                            selected: !takesMedicine,
                            onSelected:
                                (val) => setState(() => takesMedicine = false),
                            selectedColor: const Color(0xFFFFE3D3),
                          ),
                        ],
                      ),
                      if (takesMedicine)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextField(
                            controller: medicineController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'اذكر الأدوية أو التعليمات الخاصة',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: const TextStyle(
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        '📝 ملاحظات إضافية للمرافق:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'اكتب أي ملاحظات مهمة يفضل أن يعرفها المرافق (اختياري)',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        validateSelection()
                            ? () {
                              final updatedJobDetails = {
                                ...widget.previousData,
                                'children_ages': childrenAges,
                                'has_medical_condition': hasMedicalCondition,
                                'medical_condition_details':
                                    hasMedicalCondition
                                        ? medicalController.text.trim()
                                        : null,
                                'takes_medicine': takesMedicine,
                                'medicine_details':
                                    takesMedicine
                                        ? medicineController.text.trim()
                                        : null,
                                'additional_notes': notesController.text.trim(),
                              };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BabysitterRateRangePage(
                                        previousData: updatedJobDetails,
                                      ),
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF600A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
