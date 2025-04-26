import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/caregiver_profile_model.dart';
import '../models/caregiver_profile_model.dart'; 

class CaregiverHomePage extends StatelessWidget {
  final CaregiverProfileModel profile;

  const CaregiverHomePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text(
            'الصفحة الرئيسية',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CaregiverProfilePage(profile: profile),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "قريباً: الحجوزات والطلبات",
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
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
}
