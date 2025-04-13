import 'package:flutter/material.dart';

class ChildConsultPage extends StatelessWidget {
  const ChildConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> subcategories = [
      'استشارة تربوية',
      'استشارة نفسية للطفل',
      'استشارة سلوكية',
      'استشارة اضطرابات النوم',
      'استشارة تغذية الأطفال',
      'استشارة العلاقات داخل الأسرة',
    ];

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
          backgroundColor: Color(0xFFFF600A),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final item = subcategories[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to detail or booking screen
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE7DA), Color(0xFFFFF3ED)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Color(0xFFFF600A), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NotoSansArabic',
                          ),
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
