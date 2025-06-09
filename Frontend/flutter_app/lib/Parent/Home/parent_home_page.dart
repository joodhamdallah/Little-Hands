// lib/pages/parent/parent_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Home/my_feedbacks_page.dart';
import 'package:flutter_app/Parent/Home/parent_bookings_page.dart';
import 'package:flutter_app/Parent/Home/parent_main_page.dart';
import 'package:flutter_app/Parent/Home/view_all_expert_cards_page.dart';
import 'package:flutter_app/pages/custom_app_bar.dart';
import 'package:flutter_app/pages/custom_bottom_nav.dart';
import 'package:flutter_app/pages/notifications_page.dart';
import 'package:flutter_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_app/pages/parent/notifications_page.dart';
// import 'package:flutter_app/pages/parent/bookings_page.dart';
// import 'package:flutter_app/pages/parent/dashboard_page.dart';
// import 'package:flutter_app/pages/parent/content_page.dart';
// import 'package:flutter_app/pages/parent/account_page.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notifProvider.loadUnreadCount();
    notifProvider.startAutoRefresh();

    _pages = [
      const ParentHomeMainContent(),
      NotificationsPage(
        onMarkedRead: () {
          Provider.of<NotificationProvider>(
            context,
            listen: false,
          ).loadUnreadCount();
        },
      ),
      const ParentBookingsPage(),
      ParentMyFeedbacksPage(), // ✅ Added here
      const ViewAllExpertCardsPage(), // ✅ صفحة المحتوى (الكروت)
      const SizedBox(), // حسابي (غير مفعّل بعد)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'Little Hands'),
        body: _pages[_selectedIndex],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'الإشعارات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'الحجوزات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback),
              label: 'تقييماتي',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: 'المحتوى',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
