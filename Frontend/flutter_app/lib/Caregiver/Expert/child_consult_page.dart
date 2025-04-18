// main_consultation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Expert/subcategories_page.dart';

class ChildConsultPage extends StatefulWidget {
  const ChildConsultPage({super.key});

  @override
  State<ChildConsultPage> createState() => _ChildConsultPageState();
}

class _ChildConsultPageState extends State<ChildConsultPage> {
  List<int> selectedIndices = [];

  final List<Map<String, dynamic>> subcategories = [
    {
      'title': 'استشارة سلوكية',
      'subtitle': 'تعديل سلوك الطفل وتوجيهه',
      'icon': Icons.track_changes,
    },
    {
      'title': 'استشارة اضطرابات النوم',
      'subtitle': 'مساعدة في نوم أفضل للطفل',
      'icon': Icons.bedtime,
    },
    {
      'title': 'استشارة تغذية الأطفال',
      'subtitle': 'إرشادات لتغذية الأطفال في مراحل النمو',
      'icon': Icons.local_dining,
    },
    {
      'title': 'استشارة العلاقات داخل الأسرة',
      'subtitle': 'تعزيز التواصل الأسري',
      'icon': Icons.family_restroom,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'إستشاري رعاية الطفل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansArabic',
            ),
          ),
          backgroundColor: const Color(0xFFFF600A),
          elevation: 0,
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ما نوع الاستشارات التي يمكنك تقديمها؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: subcategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = subcategories[index];
                    final isSelected = selectedIndices.contains(index);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedIndices.remove(index);
                          } else {
                            selectedIndices.add(index);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFFFFE3D3)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFFFF600A)
                                    : Colors.black12,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'],
                              size: 40,
                              color: const Color(0xFFFF600A),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Flexible(
                              child: Text(
                                item['subtitle'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  fontFamily: 'NotoSansArabic',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 40.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      selectedIndices.isNotEmpty
                          ? () {
                            List<String> selectedTitles =
                                selectedIndices
                                    .map(
                                      (i) =>
                                          subcategories[i]['title'].toString(),
                                    )
                                    .toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SubcategoryScreen(
                                      categoryList: selectedTitles,
                                    ),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
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
