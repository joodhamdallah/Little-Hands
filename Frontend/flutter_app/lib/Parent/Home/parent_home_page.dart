import 'package:flutter/material.dart';
import 'package:flutter_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../pages/custom_app_bar.dart';
import '../../pages/custom_bottom_nav.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> sliderData = [
    {
      'image': 'assets/images/homepage/babysitter5.webp',
      'title': 'جليسة أطفال',
    },
    {
      'image': 'assets/images/homepage/babysitter1.webp',
      'title': 'أخصائي رعاية',
    },
    {'image': 'assets/images/homepage/shadowteacher.avif', 'title': 'معلم ظل'},
    {'image': 'assets/images/homepage/expert1.webp', 'title': 'مدرس خصوصي'},
  ];

  @override
  void initState() {
    super.initState();
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notifProvider.loadUnreadCount();
    notifProvider.startAutoRefresh();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % sliderData.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'Little Hands'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Slider
              SizedBox(
                height: 290,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: sliderData.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final data = sliderData[index];
                    return _buildPageItem(data['image']!, data['title']!);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Slider indicator
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(sliderData.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 18 : 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? const Color(0xFFFF600A)
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 30),

              // ✅ Services section
              buildSectionTitle('اختر نوع الخدمة التي تحتاجها'),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _buildServiceCard(
                    'رعاية الأطفال في المنزل',
                    'assets/images/homepage/babysittingicon.png',
                  ),
                  _buildServiceCard(
                    'الاستشارات التربوية والنفسية',
                    'assets/images/homepage/counseling.png',
                  ),
                  _buildServiceCard(
                    'مساعدة الأطفال ذوي الاحتياجات',
                    'assets/images/homepage/specialneeds.png',
                  ),
                  _buildServiceCard(
                    'التدريس والتعليم المنزلي',
                    'assets/images/homepage/tutoring.png',
                  ),
                ],
              ),

              // ✅ Platform intro section
              buildPlatformIntroSection(),

              // ✅ Safety section
              const SizedBox(height: 30),
              buildSectionTitle('نحرص على أمان طفلك وخصوصيتك'),
              buildSafetySection(),

              // ✅ Testimonials
              const SizedBox(height: 30),
              buildSectionTitle('تجارب الآباء والأمهات'),
              buildTestimonialsSection(),

              const SizedBox(height: 10),
              buildCaregiversListSection(),
            ],
          ),
        ),
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
              icon: Icon(Icons.dashboard_customize_outlined),
              label: 'لوحة التحكم',
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

  Widget buildTestimonialsSection() {
    final List<Map<String, String>> testimonials = [
      {
        'text':
            'كنت أبحث عن جليسة أطفال لطفلي الصغير وكانت التجربة مذهلة. وجدت جليسة من خلال المنصة بكل سهولة، وكانت متجاوبة جدًا ومحبة. شعرت أن طفلي بأيدٍ أمينة.',
        'name': 'رنا',
        'title': 'أم لطفلين',
        'image': 'assets/images/homepage/expert1.webp',
        'rating': '5',
      },
      {
        'text':
            'حجزت استشارة تربوية حول مشاكل التركيز لابني، وكان التواصل مع الأخصائي سهل وسريع. شعرت أنهم فعلاً مهتمين يساعدوني، ونصائحه كانت عملية ومفيدة.',
        'name': 'خالد',
        'title': 'والد لطالب',
        'image': 'assets/images/homepage/expert1.webp',
        'rating': '4',
      },
      {
        'text':
            'ابني من ذوي الاحتياجات الخاصة، وكنت مترددة كثيرًا. وجدت معلمة ظل عبر المنصة وكانت محترفة ومتعاونة. ابني اندمج في المدرسة بشكل رائع. شكرًا Little Hands.',
        'name': 'هبة',
        'title': 'أم لطفل توحدي',
        'image': 'assets/images/homepage/expert1.webp',
        'rating': '5',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: PageView.builder(
            itemCount: testimonials.length,
            controller: PageController(viewportFraction: 0.92),
            itemBuilder: (context, index) {
              final t = testimonials[index];
              final int rating = int.parse(t['rating']!);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF600A), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⭐ نجوم التقييم
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 💬 النص
                    Expanded(
                      child: Text(
                        '"${t['text']}"',
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'NotoSansArabic',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 👤 صورة واسم
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(t['image']!),
                          radius: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${t['name']} - ${t['title']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'NotoSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // 🧭 مؤشر "اسحب لرؤية المزيد"
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.swipe, color: Colors.grey, size: 20),
              SizedBox(width: 6),
              Text(
                'اسحب لرؤية المزيد',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ],
          ),
        ),

        // ✅ زر "أضف تجربتك"
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to "Add Testimonial" screen
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text(
              'أضف تجربتك',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansArabic',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF600A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSafetySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        // بطاقة التحقق من الهوية
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF600A), width: 1),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/homepage/id.png', // أيقونة التحقق من الهوية
                width: 40,
                height: 42,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'نقوم بالتحقق من هوية مقدمي الرعاية لضمان بيئة آمنة لطفلك.',
                  style: TextStyle(fontSize: 15, fontFamily: 'NotoSansArabic'),
                ),
              ),
            ],
          ),
        ),

        // بطاقة سرية المعلومات
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF600A), width: 1),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/homepage/protection.png', // أيقونة خصوصية المعلومات (أنت نزلتها)
                width: 40,
                height: 42,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'نلتزم بالحفاظ على سرية معلوماتك وبيانات طفلك، ولا يتم مشاركتها مع أي طرف خارجي.',
                  style: TextStyle(fontSize: 15, fontFamily: 'NotoSansArabic'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageItem(String imagePath, String title) {
    String description = _getServiceDescription(title);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // ✅ حواف دائرية لكل العنصر
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.black.withOpacity(0.4),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceDescription(String title) {
    switch (title) {
      case 'جليسة أطفال':
        return 'رعاية آمنة ومحبّة لأطفالك في جميع الأوقات.';
      case 'أخصائي رعاية':
        return 'خبراء في دعم وتوجيه سلوك ونمو الأطفال.';
      case 'معلم ظل':
        return 'مرافقة الأطفال ذوي الاحتياجات في بيئات التعلم.';
      case 'مدرس خصوصي':
        return 'لقاءات استشارية لدعمك في تربية طفلك.';
      default:
        return '';
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 6, height: 24, color: const Color(0xFFFF600A)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansArabic',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String imagePath) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFF600A), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(imagePath, height: 70),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansArabic',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (title == 'رعاية الأطفال في المنزل') {
                Navigator.pushNamed(context, '/parentBabysitterInfo');
              } else if (title == 'الاستشارات التربوية والنفسية') {
                Navigator.pushNamed(context, '/counseling');
              } else if (title == 'مساعدة الأطفال ذوي الاحتياجات') {
                Navigator.pushNamed(context, '/specialNeeds');
              } else if (title == 'التدريس والتعليم المنزلي') {
                Navigator.pushNamed(context, '/tutoring');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF600A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              textStyle: const TextStyle(
                fontSize: 14,
                fontFamily: 'NotoSansArabic',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_ios_new, size: 14),
                  SizedBox(width: 6),
                  Text('تعرّف على الخدمة'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlatformIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        buildSectionTitle('كل ما يحتاجه طفلك في مكان واحد'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF600A), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'في منصة "Little Hands"، نربطك بأفضل مقدمي الرعاية والخبراء التربويين، لنقدم لك خدمات موثوقة تشمل جليسات الأطفال، الاستشارات، التعليم المنزلي، ومرافقة الأطفال ذوي الاحتياجات.',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'NotoSansArabic',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'هدفنا دعمك في كل خطوة، وتوفير بيئة آمنة لطفلك... لأننا نعلم أن طفلك هو الأهم 🧡',
                style: TextStyle(
                  color: Color(0xFFFF600A),
                  fontSize: 15,
                  fontFamily: 'NotoSansArabic',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCaregiversListSection() {
    final List<Map<String, String>> caregivers = [
      {
        'name': 'سارة أ.',
        'role': 'جليسة أطفال معتمدة',
        'image': 'assets/images/homepage/sarah_test_pic.jpg',
        'rating': '5',
      },
      {
        'name': 'مها ن.',
        'role': 'مرافقة لطفل توحدي',
        'image': 'assets/images/homepage/maha_test_pic.webp',
        'rating': '4',
      },
      {
        'name': 'نور ع.',
        'role': 'خبيرة تربوية',
        'image': 'assets/images/homepage/maha_test_pic.webp',
        'rating': '5',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('تعرف على بعض مقدمي الرعاية'),
        const SizedBox(height: 12),
        Column(
          children:
              caregivers.map((c) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(c['image']!),
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            Text(
                              c['role']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < int.parse(c['rating']!)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: const Color(0xFFFFC107),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Open caregiver profile
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Color(0xFFFF600A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
