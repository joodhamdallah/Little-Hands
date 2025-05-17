import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_childdage_parent3.dart';

class BabysitterTypeSelectionPage extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const BabysitterTypeSelectionPage({super.key, required this.previousData});

  @override
  State<BabysitterTypeSelectionPage> createState() =>
      _BabysitterTypeSelectionPageState();
}

class _BabysitterTypeSelectionPageState
    extends State<BabysitterTypeSelectionPage> {
  String? selectedType;

  final List<Map<String, dynamic>> sessionTypes = [
    {
      'value': 'regular',
      'title': 'جليسة منتظمة',
      'subtitle':
          'جليسة تأتي في أوقات محددة خلال الأسبوع مثل قبل/بعد المدرسة، أو لأيام متكررة بشكل ثابت.',
      'icon': Icons.calendar_today_outlined,
    },
    {
      'value': 'once',
      'title': 'جليسة لمرة واحدة',
      'subtitle':
          'جليسة تُطلب لمناسبة واحدة أو حالة طارئة، مثل حفلة أو موعد أو سفر ليوم واحد.',
      'icon': Icons.event,
    },
    {
      'value': 'nanny',
      'title': 'مربية (Nanny)',
      'subtitle':
          'جليسة بدوام جزئي أو كامل، عادة لأيام متعددة أسبوعيًا وتكون مسؤولة عن مهام رعاية شاملة.',
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
          backgroundColor: const Color(0xFFFF600A),
          automaticallyImplyLeading: false,
          title: const Text(
            'نوع جليسة الأطفال',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/parentHome',
                  (route) => false,
                );
              },
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const LinearProgressIndicator(
                value: 0.4,
                backgroundColor: Colors.grey,
                color: Color(0xFFFF600A),
                minHeight: 6,
              ),
              const SizedBox(height: 24),
              const Text(
                'اختر نوع جليسة الأطفال التي تحتاجها :',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 20),
              ...sessionTypes.map((type) => _buildTypeCard(type)),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed:
                      selectedType != null
                          ? () {
                            final updatedJobDetails = {
                              ...widget.previousData,
                              'session_type': selectedType,
                            };
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddChildrenAgePage(
                                      previousData: updatedJobDetails,
                                    ),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(Map<String, dynamic> type) {
    final isSelected = selectedType == type['value'];
    return GestureDetector(
      onTap: () => setState(() => selectedType = type['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E8) : const Color(0xFFF8F8F8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFFFF600A) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(type['icon'], color: const Color(0xFFFF600A), size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type['subtitle'],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
