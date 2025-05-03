import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/caregiver_main_page.dart';
import 'package:flutter_app/Caregiver/caregiver_profile_model.dart';
import 'package:flutter_app/Caregiver/work-schedule-page.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart'; 

class CaregiverHomePage extends StatefulWidget {
  final CaregiverProfileModel profile;

  const CaregiverHomePage({super.key, required this.profile});

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _currentIndex = 0; // لتتبع الزر المضغوط

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
    CaregiverHomeMainPage(profile: widget.profile),

      _buildComingSoonPage('الحجوزات والطلبات'), 
      WorkSchedulePage(),
     SingleChildScrollView(
  child: CaregiverProfilePage(profile: widget.profile),
)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
        
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/littlehandslogo.png'), 
          ),
        ),
        body: _pages[_currentIndex], 
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFFFF600A),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'الحجوزات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize),
              label: 'لوحة التحكم',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  // ✅ صفحة قريباً (حجوزات / لوحة تحكم)
  Widget _buildComingSoonPage(String title) {
    return Center(
      child: Text(
        'قريباً: $title',
        style: const TextStyle(
          fontFamily: 'NotoSansArabic',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
