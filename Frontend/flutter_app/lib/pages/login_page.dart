import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_home_page.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart';
import 'package:flutter_app/services/socket_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ✅
import 'config.dart'; // loginUsers = "${url}auth/login";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _headerSection(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: _welcomeMessage(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                            "البريد الإلكتروني",
                            (val) => email = val,
                          ),
                          const SizedBox(height: 14),
                          _buildPasswordField(),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/resetPassword");
                              },
                              child: const Text(
                                "هل نسيت كلمة المرور؟",
                                style: TextStyle(
                                  color: Colors.black87,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                loginUser();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF600A),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 60,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(text: "ليس لديك حساب؟ "),
                                TextSpan(
                                  text: "سجل الآن",
                                  style: const TextStyle(
                                    color: Color(0xFFFF600A),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(
                                            context,
                                            "/register",
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(100),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/littlehandslogo.png",
            width: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          const Text(
            "تسجيل الدخول",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeMessage() {
    return const Text(
      "مرحبًا بعودتك! الرجاء تسجيل الدخول للمتابعة.",
      style: TextStyle(fontSize: 20, color: Colors.black87),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInputField(String label, Function(String) onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val == null || val.isEmpty) return 'الرجاء تعبئة هذا الحقل';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
          return 'البريد الإلكتروني غير صالح';
        }
        return null;
      },
      onSaved: (val) => onSaved(val!),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: hidePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        labelStyle: const TextStyle(fontSize: 16),
        suffixIcon: IconButton(
          icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => hidePassword = !hidePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ),
      ),
      validator:
          (val) => val == null || val.isEmpty ? 'كلمة المرور مطلوبة' : null,
      onSaved: (val) => password = val!,
    );
  }

Future<CaregiverProfileModel> fetchCaregiverProfile(String token) async {
  final response = await http.get(
    Uri.parse('${url}caregiver/profile'),
    headers: {'Authorization': 'Bearer $token'},
  );

  print('📥 Status Code: ${response.statusCode}');
  print('📥 Body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return CaregiverProfileModel.fromJson(jsonData['profile']);
  } else {
    throw Exception('فشل في تحميل بيانات مقدم الرعاية');
  }
}


  void loginUser() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(loginUsers); // /api/auth/login
      final headers = {"Content-Type": "application/json"};
      final requestBody = jsonEncode({
        "email": email,
        "password": password,
        "rememberMe": false,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: requestBody,
      );
      if (!mounted) return;
      setState(() => isLoading = false);

      final jsonData = jsonDecode(response.body);
      String message = jsonData["message"] ?? "فشل تسجيل الدخول";

      if (response.statusCode == 200 && jsonData["status"] == true) {
        // ✅ تخزين التوكن
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', jsonData["token"]);

        //by Jood
        // ✅ Check role and save caregiver role if exists
        final user = jsonData["user"];
        final userId = user["id"]; // 🔥 Mongo ID
        await prefs.setString('userId', userId); // ✅ store for socket later

        try {
          SocketService().connect(userId);
          print("🧠 Connecting to socket with userId: $userId");
        } catch (e) {
          print("❌ Failed to connect to socket: $e");
        }

        final type = user["type"]; // "caregiver" or "parent"
        final role = user["role"]; // ممكن تكون null أو String

        // ✅ خزّن الرول فقط إذا كان موجود
        if (type == "caregiver" && role != null) {
          await prefs.setString('caregiverRole', role);
        }

        // ✅ إشعار نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تسجيل الدخول بنجاح 🎉"),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;

        // ✅ تحديد الوجهة حسب النوع والحالة
        if (type == "caregiver") {
          await saveFcmTokenToBackend();

          if (role == null || role.isEmpty) {
            await prefs.setString('caregiverEmail', email!);
            Navigator.pushReplacementNamed(context, '/onboarding');
          } else {
            try {
              final token = prefs.getString('accessToken')!;
              final profile = await fetchCaregiverProfile(token);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CaregiverHomePage(profile: profile),
                ),
              );
            } catch (e) {
              print('خطأ في تحميل البروفايل: $e');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('فشل في تحميل البروفايل')));
            }
          }
        } else {
          saveFcmTokenToBackend();
          Navigator.pushReplacementNamed(context, '/parentHome');
        }
      } else {
        if (message.toLowerCase().contains("user does not exist")) {
          message = "لا يوجد حساب بهذا البريد الإلكتروني، سجّل الآن.";
        } else if (message.toLowerCase().contains(
          "incorrect email or password",
        )) {
          message = "البريد الإلكتروني أو كلمة المرور غير صحيحة.";
        } else if (message.toLowerCase().contains("not verified")) {
          message = "يجب تفعيل البريد الإلكتروني أولاً.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ أثناء تسجيل الدخول"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveFcmTokenToBackend() async {
    await FirebaseMessaging.instance.deleteToken(); // Clear old token
    final fcmToken =
        await FirebaseMessaging.instance.getToken(); // Get new token
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (fcmToken != null && accessToken != null) {
      await http.post(
        Uri.parse(saveFcmToken), // عدل حسب نوع المستخدم إذا كان parent
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
    }
  }
}
