import 'package:flutter/foundation.dart' show kIsWeb;
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
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('جلسة بديلة متاحة'),
          content: const Text(
              'يوجد جليسات أطفال مستعدون لاستلام الجلسة بعد الإلغاء.'),
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
      child: kIsWeb
          ? _buildWebLayout()
          : _buildMobileLayout(),
    );
  }

  /// 🖥️ Web Layout
  Widget _buildWebLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF600A),
        title: const Text(
          'Little Hands',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('الرئيسية'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('الإشعارات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                label: Text('الحجوزات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.feedback),
                label: Text('تقييماتي'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                label: Text('المحتوى'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                label: Text('حسابي'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 Mobile Layout
  Widget _buildMobileLayout() {
    return Scaffold(
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.white,
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
    );
  }
}
