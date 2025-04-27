import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_type_parent2.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_summary_parent6.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart'; // loginUsers = "${url}auth/login";

class BabysitterSessionAddressPage extends StatefulWidget {
  final Map<String, dynamic>? previousData;
  final bool isEditing;

  const BabysitterSessionAddressPage({
    super.key,
    this.previousData,
    this.isEditing = false,
  });

  @override
  State<BabysitterSessionAddressPage> createState() =>
      _BabysitterSessionAddressPageState();
}

class _BabysitterSessionAddressPageState
    extends State<BabysitterSessionAddressPage> {
  String parentAddress = "جارٍ التحميل..."; // Initially loading text
  String? selectedCity; // It will come from backend
  String? selectedAddress;
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

  @override
  void initState() {
    super.initState();
    _fetchParentProfile();
    if (widget.previousData != null) {
      selectedAddress = widget.previousData!['session_address'];
      selectedCity = widget.previousData!['city'];
      neighborhoodController.text = widget.previousData!['neighborhood'] ?? '';
      streetController.text = widget.previousData!['street'] ?? '';
      buildingController.text = widget.previousData!['building'] ?? '';
    }
  }

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
                "$selectedCity - $parentAddress",
              ),
              const SizedBox(height: 12),
              _buildOption(
                'custom',
                'في عنوان آخر',
                'اختر المدينة وأدخل تفاصيل العنوان',
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
                  onChanged: (_) => setState(() {}), // ✅ أضف هذه

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
                  onChanged: (_) => setState(() {}), // ✅ أضف هذه

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
                  onChanged: (_) => setState(() {}), // ✅ أضف هذه

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
                  onPressed: _canProceed() ? _onNextPressed : null,
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

  void _fetchParentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      print('No token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(fetchParent), // change url if needed
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final parentData = jsonData['data'];

        setState(() {
          parentAddress = parentData['address'] ?? "لم يتم العثور على العنوان";
          selectedCity = parentData['city'] ?? "";
        });
      } else {
        print('Failed to load parent profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching parent profile: $e');
    }
  }

  void _onNextPressed() {
    final updatedJobDetails = {
      ...?widget.previousData,
      'session_address': selectedAddress,
      'city': selectedCity,
      'neighborhood': neighborhoodController.text.trim(),
      'street': streetController.text.trim(),
      'building': buildingController.text.trim(),
    };

    if (widget.isEditing) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => BabysitterSummaryPage(jobDetails: updatedJobDetails),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  BabysitterTypeSelectionPage(previousData: updatedJobDetails),
        ),
      );
    }
  }

  Widget _buildOption(String value, String title, String subtitle) {
    final bool isSelected = value == selectedAddress;
    return GestureDetector(
      onTap: () => setState(() => selectedAddress = value),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
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
            streetController.text.trim().isEmpty)) {
      return false;
    }
    return true;
  }
}
