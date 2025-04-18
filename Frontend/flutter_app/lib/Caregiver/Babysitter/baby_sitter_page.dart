import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Babysitter/address_page.dart';

class BabySitterPage extends StatefulWidget {
  const BabySitterPage({super.key});

  @override
  State<BabySitterPage> createState() => _BabySitterPageState();
}

class _BabySitterPageState extends State<BabySitterPage> {
  List<int> selectedIndices = [];

  final List<Map<String, dynamic>> subcategories = [
    {
      'title': 'رضيع',
      'subtitle': '(من 0 إلى 11 شهرًا)',
      'image': 'assets/images/icons/icons8-infant-64.png',
    },
    {
      'title': 'طفل صغير',
      'subtitle': '(من 1 إلى 3 سنوات)',
      'image': 'assets/images/icons/icons8-toddler-96.png',
    },
    {
      'title': 'ما قبل المدرسة',
      'subtitle': '(من 4 إلى 5 سنوات)',
      'image': 'assets/images/icons/icons8-child-safe-zone-100.png',
    },
    {
      'title': 'المرحلة الابتدائية',
      'subtitle': '(من 6 إلى 10 سنوات)',
      'image': 'assets/images/icons/icons8-students-100.png',
    },
    {
      'title': 'ما قبل المراهقة',
      'subtitle': '(11 سنة فأكثر)',
      'image': 'assets/images/icons/student.png',
    },
  ];

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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ما هو العمر الذي لديكِ خبرة في التعامل معه؟',
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
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = subcategories[index];
                    final isSelected = selectedIndices.contains(index);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedIndices.contains(index)) {
                            selectedIndices.remove(index);
                          } else {
                            selectedIndices.add(index);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFE3D3) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF600A) : Colors.black12,
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
                            item.containsKey('image')
                                ? Image.asset(
                                    item['image'],
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, color: Colors.red);
                                    },
                                  )
                                : Icon(
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
                            Text(
                              item['subtitle'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontFamily: 'NotoSansArabic',
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedIndices.isNotEmpty
                      ? () {
                          final selectedAges = selectedIndices
                              .map((index) => subcategories[index]['title'] as String)
                              .toList();

                       Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BabySitterCityPage(),
                      settings: RouteSettings(arguments: {
                        'age_experience': selectedAges,
                      }),
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
                      fontFamily: 'NotoSansArabic',
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
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
