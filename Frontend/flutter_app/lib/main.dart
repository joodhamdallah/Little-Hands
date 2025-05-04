import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ إضافة هذه المكتبة

import 'package:flutter_app/Caregiver/WorkCategories/Babysitter/address_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Babysitter/baby_sitter_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/child_consult_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_bio_wage_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_experience_page.dart';
// import 'package:flutter_app/Caregiver/Expert/expert_qualification_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/academic_qualifications_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/ageexperince_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/bio_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/certifications_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/pricing_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/special_needs_category.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_address_parent1.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_info_page.dart';
import 'package:flutter_app/Parent/Home/parent_home_page.dart';
import 'package:flutter_app/pages/ResetPass_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/caregiver_categories_page.dart';
import 'package:flutter_app/Caregiver/RegisterProcess/id_verify_api.dart';
import 'package:flutter_app/pages/SubscriptionPlanPage.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/Caregiver/RegisterProcess/register_caregivers_page.dart';
import 'package:flutter_app/Parent/Register/register_page.dart';
import 'package:flutter_app/pages/Firstpage.dart';
import 'package:flutter_app/Caregiver/RegisterProcess/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null); 

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
        '/idverifyapi': (context) => const IDVerificationPage(),

        '/childConsult': (context) => const ChildConsultPage(),
        // '/expertQualificationsQ3': (context) => const ExpertQualificationPage(),
        '/expertExperienceQ4': (context) => const ExpertExperiencePage(),
        '/expertBioQ5': (context) => const ExpertBioPage(),

        '/babysitter': (context) => const BabySitterPage(),
        '/babysitteraddresspage': (context) => const BabySitterCityPage(),

        '/specialNeeds': (context) => const DisabilityExperiencePage(),
        '/shadowteacherQ2': (context) => const ShadowTeacherStep2(),
        '/shadowteacherQ3': (context) => const ShadowTeacherStep3(),
        '/shadowteacherQ4': (context) => const ShadowTeacherStep4(),
        '/shadowteacherbio': (context) => const ShadowTeacherBioPage(),
        '/shadowteacherpricing': (context) => const ShadowTeacherPricingPage(),

        '/parentHome': (context) => const ParentHomePage(),
        '/parentBabysitterInfo': (context) => const BabysittingInfoPage(),
        '/parentBabysitteraddress':
            (context) => const BabysitterSessionAddressPage(),

        '/subscriptionpage': (context) => const SubscriptionPlanPage(),
      },
    );
  }
}
