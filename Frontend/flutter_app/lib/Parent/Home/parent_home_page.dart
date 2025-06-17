import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Home/my_feedbacks_page.dart';
import 'package:flutter_app/Parent/Home/parent_bookings_page.dart';
import 'package:flutter_app/Parent/Home/parent_main_page.dart';
import 'package:flutter_app/Parent/Home/parent_profile_page.dart';
import 'package:flutter_app/Parent/Home/view_all_expert_cards_page.dart';
import 'package:flutter_app/pages/custom_app_bar.dart';
import 'package:flutter_app/pages/custom_bottom_nav.dart';
import 'package:flutter_app/pages/notifications_page.dart';
import 'package:flutter_app/providers/notification_provider.dart';
import 'package:flutter_app/services/socket_service.dart';
import 'package:provider/provider.dart';

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

    SocketService().onFallbackCandidatesReady((data) {
      print('⚡️ بدائل جديدة للجلسة: $data');

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('جلسة بديلة متاحة'),
              content: const Text(
                'يوجد جليسات أطفال مستعدون لاستلام الجلسة بعد الإلغاء.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('لاحقًا'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/fallback-candidates',
                      arguments: data['booking_id'],
                    );
                  },
                  child: const Text('عرض البدائل'),
                ),
              ],
            ),
      );
    });

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
      ParentMyFeedbacksPage(),
      const ViewAllExpertCardsPage(),
      ParentProfilePage(),
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

        // ✅ Add chatbot FAB only on home tab
        floatingActionButton:
            _selectedIndex == 0
                ? FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  onPressed: () {
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  child: Image.asset(
                    'assets/images/icons/assistance.png',
                    height: 30,
                    width: 30,
                  ),
                )
                : null,
      ),
    );
  }
}
