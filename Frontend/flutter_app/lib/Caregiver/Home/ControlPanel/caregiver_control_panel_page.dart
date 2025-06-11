import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Home/ControlPanel/weekly_work_schedule_tab.dart';
import 'package:flutter_app/Caregiver/Home/ControlPanel/work-schedule-page.dart';
import 'package:flutter_app/Caregiver/Home/ControlPanel/work_calendar_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaregiverControlPanelPage extends StatefulWidget {
  const CaregiverControlPanelPage({super.key});

  @override
  State<CaregiverControlPanelPage> createState() => _CaregiverControlPanelPageState();
}

class _CaregiverControlPanelPageState extends State<CaregiverControlPanelPage> {
  String? caregiverRole;

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      caregiverRole = prefs.getString('caregiverRole');
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text('لوحة التحكم'),
          bottom: const TabBar(
            labelStyle: TextStyle(fontFamily: 'NotoSansArabic'),
            tabs: [
              Tab(text: 'مواعيد العمل'),
              Tab(text: 'التقويم'),
              Tab(text: 'مقابلات'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WeeklyWorkScheduleTab(),
            WorkCalendarTab(),
            WorkSchedulePage(),
          ],
        ),
      ),
    );
  }
}
