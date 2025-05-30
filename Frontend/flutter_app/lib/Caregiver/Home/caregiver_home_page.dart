import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_bookings_page.dart';
import 'package:flutter_app/Caregiver/Home/ControlPanel/caregiver_control_panel_page.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_main_page.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_profile_model.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart';
import 'package:flutter_app/pages/custom_app_bar.dart';
import 'package:flutter_app/pages/custom_bottom_nav.dart';
import 'package:flutter_app/pages/notifications_page.dart';
import 'package:flutter_app/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/notification_provider.dart';

class CaregiverHomePage extends StatefulWidget {
  final CaregiverProfileModel profile;
  final int initialTabIndex;

  const CaregiverHomePage({
    super.key,
    required this.profile,
    this.initialTabIndex = 0, // 0: default tab, 1: accepted bookings
  });

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;

    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    notifProvider.loadUnreadCount(); // load once on start

    // 👇 Remove this — no more polling!
    // notifProvider.startAutoRefresh();

    // ✅ Listen for real-time notifications
    SocketService().onNewNotification((data) {
      print("📥 Real-time notification: $data");

      // 🔁 Update unread badge count
      notifProvider.loadUnreadCount();

      // Optional: show snackbar or alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['title'] ?? 'إشعار جديد'),
          duration: const Duration(seconds: 3),
        ),
      );
    });

    // ✅ Initialize pages after socket setup
    _pages = [
      CaregiverHomeMainPage(profile: widget.profile),
      NotificationsPage(onMarkedRead: () => notifProvider.loadUnreadCount()),
      CaregiverBookingsPage(profile: widget.profile),
      CaregiverControlPanelPage(),
      SingleChildScrollView(
        child: CaregiverProfilePage(profile: widget.profile),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: CustomAppBar(title: 'Little Hands'),
        body: _pages[_currentIndex],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'الإشعارات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'الحجوزات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize),
              label: 'لوحة التحكم',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
