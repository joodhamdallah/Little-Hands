import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // يحتوي على متغيرات الرابط

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  State<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  String? email;
  String? token;
  String? newPassword;
  bool isLoading = false;
  bool hidePassword = true;
  bool isStepOne = true;

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
                    child: Text(
                      isStepOne
                          ? "يرجى إدخال بريدك الإلكتروني لاستلام رمز التحقق."
                          : "أدخل كلمة المرور الجديدة لإعادة التعيين.",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (isStepOne)
                            _buildTextField(
                              "البريد الإلكتروني",
                              (val) => email = val,
                              isEmail: true,
                              controller: emailController,
                            ),
                          if (!isStepOne) ...[_buildPasswordField()],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                isStepOne
                                    ? sendResetRequest()
                                    : confirmNewPassword();
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
                            child: Text(
                              isStepOne
                                  ? 'إرسال الرمز'
                                  : 'إعادة تعيين كلمة المرور',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
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
            "إعادة تعيين كلمة المرور",
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

  Widget _buildTextField(
    String label,
    Function(String) onSaved, {
    bool isEmail = false,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
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
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (val) {
        if (val == null || val.isEmpty) return 'هذا الحقل مطلوب';
        if (isEmail &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
          return 'البريد الإلكتروني غير صالح';
        }
        return null;
      },
      onSaved: (val) => onSaved(val!),
    );
  }

  Widget _buildPasswordField() {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          errorMaxLines: 3,
          errorStyle: TextStyle(
            fontSize: 14, // 🔸 Make font bigger here
            color: Colors.red[800], // optional: slightly darker red
            fontWeight: FontWeight.bold, // optional: bold
          ),
        ),
      ),
      child: TextFormField(
        obscureText: hidePassword,
        decoration: InputDecoration(
          labelText: 'كلمة المرور الجديدة',
          labelStyle: const TextStyle(fontSize: 20),
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

          final passwordPattern =
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$';
          final regex = RegExp(passwordPattern);

          if (!regex.hasMatch(val)) {
            return 'كلمة المرور ضعيفة! يجب أن تحتوي على 8 أحرف على الأقل، حرف كبير، حرف صغير، رقم، ورمز خاص.';
          }

          return null;
        },
        onSaved: (val) => newPassword = val!,
      ),
    );
  }

  void sendResetRequest() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(initiateReset),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200 && data["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إرسال الرمز إلى بريدك الإلكتروني ✅")),
        );
        emailController.clear(); // 💥 clear the field
        setState(() => isStepOne = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "حدث خطأ"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فشل إرسال الطلب"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void confirmNewPassword() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(resetPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200 && data["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح 🎉")),
        );
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        String errorMessage = data["message"] ?? "حدث خطأ";

        if (errorMessage.contains(
          "Password reset not authorized or expired.",
        )) {
          errorMessage = "يرجى التحقق من بريدك الإلكتروني أولاً.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ أثناء العملية"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
