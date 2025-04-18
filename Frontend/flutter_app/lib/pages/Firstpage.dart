import 'dart:async';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/im4.jpeg',
      'title': 'سلامة طفلك  من أولويتنا',
      'desc': 'نحن هنا لنساعدك في البحث والتواصل والتوظيف بأمان.',
    },
    {
      'image': 'assets/images/im2.jpeg',
      'title': 'اعثر على الرعاية التي تحتاجها الآن',
      'desc': 'رعاية أطفال، أصحاب الهمم، الكبار في السن، إستشارات وأكثر.',
    },
    {
      'image': 'assets/images/im1.jpeg',
      'title': 'نَصِلُك مع مقدم الرعاية المناسب',
      'desc':
          'انشر وظيفة، قارن الملفات الشخصية واقرأ التقييمات والأبحاث من ذوي الخبرات.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_currentPage < _pages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(_pages[index]['image']!, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            // ignore: deprecated_member_use
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Text(
                        'Little Hands',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 255, 96, 10),
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _pages[index]['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _pages[index]['desc']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: Colors.black45,
                                  offset: Offset(0.5, 0.5),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (dotIndex) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentPage == dotIndex ? 12 : 8,
                                height: _currentPage == dotIndex ? 12 : 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentPage == dotIndex
                                          ? const Color.fromARGB(
                                            255,
                                            255,
                                            96,
                                            10,
                                          )
                                          : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/caregiverCategory');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                96,
                                10,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 60,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'إنشاء حساب',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/login',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 60,
                              ),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 255, 96, 10),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 96, 10),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
