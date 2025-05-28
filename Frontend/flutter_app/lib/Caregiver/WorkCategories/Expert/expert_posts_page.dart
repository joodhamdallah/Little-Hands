import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/view_expert_posts_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/upload_expert_post_page.dart';

class ExpertPostsPage extends StatefulWidget {
  const ExpertPostsPage({super.key});

  @override
  State<ExpertPostsPage> createState() => _ExpertPostsPageState();
}

class _ExpertPostsPageState extends State<ExpertPostsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final Color primaryColor = const Color(0xFFFF600A); 
  final Color bgColor = const Color(0xFFF8F5FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
Widget build(BuildContext context) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: Text(
          'مشاركات الخبراء',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSansArabic',
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Column(
            children: [
             
              TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: '➕ إضافة نصيحة جديدة'),
                  Tab(text: '🧠 النصائح المنشورة'),
                ],
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UploadExpertPostPage(),
          ViewExpertCardsPage(),
        ],
      ),
    ),
  );
}

}
