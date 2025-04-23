import 'package:flutter/material.dart';

class BabysitterSessionAddressPage extends StatefulWidget {
  const BabysitterSessionAddressPage({super.key});

  @override
  State<BabysitterSessionAddressPage> createState() =>
      _BabysitterSessionAddressPageState();
}

class _BabysitterSessionAddressPageState
    extends State<BabysitterSessionAddressPage> {
  String? selectedAddress;
  String? selectedCity;
  final TextEditingController customAddressController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();

  final List<String> cities = [
    "طولكرم",
    "نابلس",
    "جنين",
    "رام الله",
    "الخليل",
    "غزة",
    "بيت لحم",
  ];

  final String parentAddress = "843 Manor Close, بيت لحم";

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تفاصيل جلسة جليسة الأطفال',
            style: TextStyle(color: Colors.black, fontFamily: 'NotoSansArabic'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: 0.2,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFFFF600A),
                minHeight: 6,
              ),
              const SizedBox(height: 24),

              const Text(
                'أين تريد أن تُقدَّم الجلسة؟',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              _buildOption(
                'home',
                'في منزلي',
                parentAddress,
                selectedAddress,
                (val) => setState(() => selectedAddress = val),
              ),
              const SizedBox(height: 12),
              _buildOption(
                'custom',
                'في عنوان آخر',
                'اختر المدينة وأدخل تفاصيل العنوان',
                selectedAddress,
                (val) => setState(() => selectedAddress = val),
              ),
              const SizedBox(height: 12),
              if (selectedAddress == 'custom') ...[
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  items:
                      cities
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => selectedCity = val),
                  decoration: InputDecoration(
                    labelText: 'اختر المدينة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: neighborhoodController,
                  decoration: InputDecoration(
                    hintText: 'اسم الحي / البلدة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: streetController,
                  decoration: InputDecoration(
                    hintText: 'اسم الشارع',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: buildingController,
                  decoration: InputDecoration(
                    hintText: 'رقم المبنى أو الطابق (اختياري)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed:
                      _canProceed()
                          ? () {
                            Navigator.pushNamed(
                              context,
                              '/parentBabysitterType',
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

  Widget _buildOption(
    String value,
    String title,
    String subtitle,
    String? groupValue,
    Function(String) onChanged,
  ) {
    final bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFFF600A) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFFFFF3E8) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFFFF600A),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
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

  bool _canProceed() {
    if (selectedAddress == null) return false;
    if (selectedAddress == 'custom' &&
        (selectedCity == null ||
            neighborhoodController.text.trim().isEmpty ||
            streetController.text.trim().isEmpty))
      return false;
    return true;
  }
}
