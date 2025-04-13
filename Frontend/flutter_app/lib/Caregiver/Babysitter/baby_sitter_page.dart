import 'package:flutter/material.dart';

class BabySitterPage extends StatelessWidget {
  const BabySitterPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        'title': 'مرحلة ما قبل المدرسة',
        'subtitle': '(من 4 إلى 5 سنوات)',
        'image': 'assets/images/icons/icons8-child-safe-zone-100.png',
      },
      {
        'title': 'المرحلة الابتدائية',
        'subtitle': '(من 6 إلى 10 سنوات)',
        'image': 'assets/images/icons/icons8-students-100.png',
      },
      {
        'title': 'ما قبل المراهقة والمراهقين',
        'subtitle': '(11 سنة فأكثر)',
        'image': 'assets/images/icons/teenager.png',
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'جليسة أطفال',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansArabic',
            ),
          ),
          backgroundColor: Color(0xFFFF600A),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
              return GestureDetector(
                onTap: () {
                  // Navigate to details or booking
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFFF600A), width: 1.5),
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
    );
  }
}
