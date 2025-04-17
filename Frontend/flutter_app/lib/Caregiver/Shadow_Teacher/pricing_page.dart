import 'package:flutter/material.dart';

class ShadowTeacherPricingPage extends StatefulWidget {
  const ShadowTeacherPricingPage({super.key});

  @override
  State<ShadowTeacherPricingPage> createState() => _ShadowTeacherPricingPageState();
}

class _ShadowTeacherPricingPageState extends State<ShadowTeacherPricingPage> {
  final TextEditingController _priceController = TextEditingController();
  String rateType = 'ساعة'; // or 'يوم'

  bool get isValidPrice => _priceController.text.trim().isNotEmpty && double.tryParse(_priceController.text) != null;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF600A)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ما هو أجرك المتوقع؟',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'حدد السعر الذي ترغب في تقاضيه مقابل خدماتك. سيتم عرضه للأهالي كمعدل تقريبي ويمكن التفاوض عليه لاحقًا.',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'مثال: 50',
                              hintStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
                              suffixText: 'شيكل',
                              prefixText: '', 
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFFF600A)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFFF600A), width: 2),
                              ),
                            ),
                          ),

                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: rateType,
                          onChanged: (newValue) {
                            setState(() {
                              rateType = newValue!;
                            });
                          },
                          items: ['ساعة', 'يوم'].map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text('لكل $value',
                                  style: const TextStyle(fontFamily: 'NotoSansArabic')),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),
                    const Text(
                      '* السعر الظاهر للأهالي هو للإرشاد فقط. يتم الاتفاق على التفاصيل النهائية لاحقًا.',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValidPrice
                      ? () {
                          Navigator.pushNamed(context, '/shadowteachercomplete');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    disabledBackgroundColor: Colors.orange.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
