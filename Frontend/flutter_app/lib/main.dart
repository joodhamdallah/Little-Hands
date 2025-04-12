import 'package:flutter/material.dart';
import 'package:flutter_app/pages/ResetPass_page.dart';
import 'package:flutter_app/pages/caregiver_categories_page.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/pages/register_caregivers_page.dart';
import 'package:flutter_app/pages/register_page.dart';
import 'package:flutter_app/pages/Firstpage.dart'; 
import 'package:flutter_app/pages/onboarding_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Little Hands',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansArabic',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FirstPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        "/resetPassword": (context) => const ResetPassPage(),
         '/onboarding': (context) => const OnboardingRoadmapPage(),
         '/caregiverCategory': (context) => const CaregiverCategorySelection(), 
        '/registerCaregivers': (context) => const RegisterCaregiversPage(),
      },
    );
  }
}
