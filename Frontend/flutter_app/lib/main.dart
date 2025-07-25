import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Home/ControlPanel/fallback_offers.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_posts_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_provider.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_qualification_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Shadow_Teacher/special_needs_provider.dart';
import 'package:flutter_app/Parent/Home/chatbot_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Experts/expert_budget_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Experts/expert_info_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Experts/expert_session_details_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Experts/expert_specialist_type-page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Experts/experts_child_age.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Shadow_teacher/special_needs_age_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Shadow_teacher/special_needs_schedule_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Shadow_teacher/specialneeds_Info_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Shadow_teacher/specialneeds_finalstep_page.dart';
import 'package:flutter_app/Parent/Services/Babysitter/Shadow_teacher/specialneeds_type_page.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/pages/FallbackCandidatesPage.dart';
import 'package:flutter_app/pages/chat_page.dart';
import 'package:flutter_app/pages/complaint_page.dart';
import 'package:flutter_app/pages/my_messages_page.dart';
import 'package:flutter_app/pages/rolePage.dart';
import 'package:flutter_app/providers/notification_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_app/Caregiver/WorkCategories/Babysitter/address_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Babysitter/baby_sitter_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/child_consult_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_bio_wage_page.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_experience_page.dart';
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
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📥 Background notification received: ${message.messageId}');
}

void initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  String? token = await messaging.getToken();
  print("🔑 FCM Token: $token");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📲 Foreground notification: ${message.notification?.title}");

    // 👇 This displays it like a system notification
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // channel id
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 🟠 Create the channel
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  initFCM();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = NotificationProvider();
            provider.loadUnreadCount();
            //  provider.startAutoRefresh(); // 🔄 enable polling every 30s
            return provider;
          },
        ),

        ChangeNotifierProvider(create: (_) => SpecialNeedsProvider()),
        ChangeNotifierProvider(create: (_) => ExpertProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/expertQualificationsQ3': (context) => const ExpertQualificationPage(),
        '/expertExperienceQ4': (context) => const ExpertExperiencePage(),
        '/expertBioQ5': (context) => const ExpertBioPage(),
        '/expertPostsPage': (context) => const ExpertPostsPage(),
        '/chatbot': (context) => const ChatbotPage(),

        '/babysitter': (context) => const BabySitterPage(),
        '/babysitteraddresspage': (context) => const BabySitterCityPage(),

        '/specialNeeds': (context) => const DisabilityExperiencePage(),
        '/shadowteacherQ2': (context) => const ShadowTeacherStep2(),
        '/shadowteacherQ3': (context) => const ShadowTeacherStep3(),
        '/shadowteacherQ4': (context) => const ShadowTeacherStep4(),
        '/shadowteacherbio': (context) => const ShadowTeacherBioPage(),
        '/shadowteacherpricing': (context) => const ShadowTeacherPricingPage(),
        '/shadowteacherInfo': (context) => const SpecialNeedsInfoPage(),
        '/specialNeedsStart': (context) => const SpecialNeedsServiceTypePage(),
        '/specialNeedsage':
            (context) => const SpecialNeedsDisabilityAndAgePage(),
        '/specialNeedsschedule': (context) => const SpecialNeedsSchedulePage(),
        '/specialNeedsFinalstep':
            (context) => const SpecialNeedsFinalStepPage(),

        '/parentHome': (context) => const ParentHomePage(),
        '/parentBabysitterInfo': (context) => const BabysittingInfoPage(),
        '/parentExpertInfo': (context) => const ExpertConsultationInfoPage(),
        '/parentExpertStart': (context) => const ExpertSpecialistTypePage(),
        '/parentExpertChildAgePage':
            (context) => const ChildAgeAndChallengesPage(),
        '/parentExpertsessionPage':
            (context) => const ExpertSessionDetailsPage(),
        '/parentExpertbudgetPage': (context) => const ExpertSessionBudgetPage(),

        '/parentBabysitteraddress':
            (context) => const BabysitterSessionAddressPage(),

        '/subscriptionpage': (context) => const SubscriptionPlanPage(),
        '/fallback-candidates': (context) => const FallbackCandidatesPage(),
        '/my-messages': (context) => const MyMessagesPage(),
        '/chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          final String myId = args['myId'] ?? '';
          final String otherId = args['otherId'] ?? '';
          final String? otherUserName = args['otherUserName']; // 👈 Optional

          return ChatPage(
            myId: myId,
            otherId: otherId,
            otherName: otherUserName, // 👈 Pass it to ChatPage
          );
        },
        '/complaint': (context) => const ComplaintPage(),
        '/fallback-offers': (context) => const FallbackOffersPage(),
        '/selectRole': (context) => const SelectRolePage(),

        //         '/send_price': (context) {
        //   final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        //   return SendPricePage(booking: args);
        // },
      },
    );
  }
}
