import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Your config with login = "${url}login";

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
      validator: (val) {
        if (val == null || val.isEmpty) return 'كلمة المرور مطلوبة';
        return null;
      },
      onSaved: (val) => password = val!,
    );
  }

  void loginUser() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(login); // from config.dart
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
      setState(() => isLoading = false);

      final jsonData = jsonDecode(response.body);
      String message = jsonData["message"] ?? "فشل تسجيل الدخول";

      if (response.statusCode == 200 && jsonData["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تسجيل الدخول بنجاح 🎉"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // ✅ Translate backend messages
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
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ أثناء تسجيل الدخول"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
