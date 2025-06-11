import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_bookings_page.dart';
import 'package:flutter_app/Caregiver/Home/ControlPanel/caregiver_control_panel_page.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_main_page.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_profile_model.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:flutter_app/pages/custom_app_bar.dart';
import 'package:flutter_app/pages/custom_bottom_nav.dart';
import 'package:flutter_app/pages/notifications_page.dart';
import 'package:flutter_app/services/socket_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_posts_page.dart';

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
  late List<BottomNavigationBarItem> _navItems;

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

    SocketService().onFallbackOffer((data) {
      if (!mounted) return;

      print("📩 Fallback offer received: $data");

      final String rawDate = data['session_date'];
      final DateTime parsedDate =
          DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now();

      final formattedDate = intl.DateFormat(
        'EEEE، d MMMM y',
        'ar',
      ).format(parsedDate);
      // 🕒 Format time nicely in Arabic (e.g., ٩:٠٠ ص - ٢:٠٠ م)
      DateTime? startTimeObj;
      DateTime? endTimeObj;

      try {
        startTimeObj = intl.DateFormat.jm().parse(data['start_time']);
        endTimeObj = intl.DateFormat.jm().parse(data['end_time']);
      } catch (e) {
        print("❌ Error parsing times: $e");
      }

      final formattedStart =
          startTimeObj != null
              ? intl.DateFormat(
                'h:mm a',
                'ar',
              ).format(startTimeObj).replaceAll('AM', 'ص').replaceAll('PM', 'م')
              : data['start_time'];

      final formattedEnd =
          endTimeObj != null
              ? intl.DateFormat(
                'h:mm a',
                'ar',
              ).format(endTimeObj).replaceAll('AM', 'ص').replaceAll('PM', 'م')
              : data['end_time'];

      final timeRange = "$formattedStart - $formattedEnd";

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => Directionality(
              textDirection: TextDirection.rtl, // 👈 RTL for Arabic
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  "فرصة لجلسة بديلة",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تم إلغاء جلسة مؤكدة.",
                      style: TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "هل ترغب بتنفيذ جلسة بديلة؟",
                      style: TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "📅 التاريخ: $formattedDate",
                      style: const TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                    Text(
                      "🕒 الوقت: $timeRange",
                      style: const TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                    if (data['city'] != null)
                      Text(
                        "📍 المدينة: ${data['city']}",
                        style: const TextStyle(fontFamily: 'NotoSansArabic'),
                      ),
                    if (data['requirements'] != null &&
                        data['requirements'].isNotEmpty)
                      Text(
                        "🧩 المتطلبات: ${data['requirements'].join(', ')}",
                        style: const TextStyle(fontFamily: 'NotoSansArabic'),
                      ),
                    if (data['children_ages'] != null &&
                        data['children_ages'].isNotEmpty)
                      Text(
                        "👶 أعمار الأطفال: ${data['children_ages'].join(', ')}",
                        style: const TextStyle(fontFamily: 'NotoSansArabic'),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "لا",
                      style: TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      respondToFallback(data['booking_id']);
                    },
                    child: const Text(
                      "نعم، أرغب",
                      style: TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                  ),
                ],
              ),
            ),
      );
    });

    // ✅ Initialize pages after socket setup
    SharedPreferences.getInstance().then((prefs) {
      final role = prefs.getString('caregiverRole');
      final isExpert = role == 'expert';

      setState(() {
        _pages = [
          CaregiverHomeMainPage(profile: widget.profile),
          NotificationsPage(
            onMarkedRead: () => notifProvider.loadUnreadCount(),
          ),
          CaregiverBookingsPage(profile: widget.profile),
          CaregiverControlPanelPage(),
          if (isExpert) ExpertPostsPage(),
          SingleChildScrollView(
            child: CaregiverProfilePage(profile: widget.profile),
          ),
        ];

        _navItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'الإشعارات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'الحجوزات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: 'لوحة التحكم',
          ),
          if (isExpert)
            const BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'المحتوى ',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ];
      });
    });
  }

  void respondToFallback(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse('${url}fallbacks/respond'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'booking_id': bookingId,
        'message': 'أرغب بتنفيذ هذه الجلسة',
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Fallback response sent successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إرسال الموافقة على الجلسة البديلة")),
      );
    } else {
      print('❌ Failed to respond to fallback');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("فشل في إرسال الرد")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: CustomAppBar(title: 'Little Hands'),
        body: _pages[_currentIndex],
        bottomNavigationBar:
            _pages.isEmpty
                ? null
                : CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                  },
                  items: _navItems,
                ),
      ),
    );
  }
}
