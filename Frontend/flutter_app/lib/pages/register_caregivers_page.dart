import 'package:flutter/material.dart' as flutter;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterCaregiversPage extends StatefulWidget {
  const RegisterCaregiversPage({super.key});

  @override
  State<RegisterCaregiversPage> createState() => _RegisterCaregiversState();
}

class _RegisterCaregiversState extends State<RegisterCaregiversPage> {
  final _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  bool agreedToTerms = false;
  int _currentPage = 0;

  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phone;
  String? dateOfBirth;
  String? gender;
  String? city;
  String? zipCode;
  String? address;
  File? profileImage;

  String passwordStrengthMessage = '';
  Color passwordStrengthColor = Colors.red;
  String emailValidationMessage = '';
  Color emailValidationColor = Colors.red;

  final List<String> cities = [
    "طولكرم",
    "نابلس",
    "جنين",
    "رام الله",
    "الخليل",
    "غزة",
    "بيت لحم",
  ];
  // Controllers here 👇
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer =
        TapGestureRecognizer()
          ..onTap = () => Navigator.pushNamed(context, '/login');
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    _dobController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void checkEmailValidation(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (value.isEmpty) {
      emailValidationMessage = '';
    } else if (!emailRegex.hasMatch(value)) {
      emailValidationMessage = "❌ البريد الإلكتروني غير صالح";
      emailValidationColor = Colors.red;
    } else {
      emailValidationMessage = "✅ البريد الإلكتروني صالح!";
      emailValidationColor = Colors.green;
    }

    setState(() {});
  }

  void checkPasswordStrength(String value) {
    final hasUpper = RegExp(r'[A-Z]');
    final hasLower = RegExp(r'[a-z]');
    final hasDigit = RegExp(r'\d');
    final hasSpecial = RegExp(r'[!@#\\$%^&*(),.?":{}|<>]');
    final hasMinLength = value.length >= 8;

    if (!hasMinLength) {
      passwordStrengthMessage = "❌ يجب أن تكون 8 أحرف على الأقل";
      passwordStrengthColor = Colors.red;
    } else if (!hasUpper.hasMatch(value)) {
      passwordStrengthMessage = "❌ أضف حرفًا كبيرًا";
      passwordStrengthColor = Colors.orange;
    } else if (!hasLower.hasMatch(value)) {
      passwordStrengthMessage = "❌ أضف حرفًا صغيرًا";
      passwordStrengthColor = Colors.orange;
    } else if (!hasDigit.hasMatch(value)) {
      passwordStrengthMessage = "❌ أضف رقمًا";
      passwordStrengthColor = Colors.orange;
    } else if (!hasSpecial.hasMatch(value)) {
      passwordStrengthMessage = "❌ أضف رمزًا خاصًا";
      passwordStrengthColor = Colors.orange;
    } else {
      passwordStrengthMessage = "✅ كلمة مرور قوية!";
      passwordStrengthColor = Colors.green;
    }

    setState(() {});
  }

  Widget _headerSection() {
    return Container(
      width: double.infinity,
      height: 190, // Smaller height
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
            width: 190, // 👈 Slightly bigger logo
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6), // 👈 Less space under the logo
          const Text(
            "إنشاء حساب جديد",
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
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 22),
        children: [
          const TextSpan(
            text: "أهلاً وسهلاً بمقدمي الرعاية الأعزاء \nهل لديك حساب بالفعل؟ ",
          ),
          TextSpan(
            text: "تسجيل الدخول",
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 96, 10),
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
            ),
            recognizer: _tapGestureRecognizer,
          ),
          const TextSpan(text: " ."),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    Function(String) onSaved, {
    TextEditingController? controller,
    bool isEmail = false,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator: (val) {
          if (!isOptional && (val == null || val.isEmpty)) {
            return 'الرجاء تعبئة هذا الحقل';
          }
          if (isEmail &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val!)) {
            return 'البريد الإلكتروني غير فعال';
          }
          return null;
        },
        onSaved: (val) => onSaved(val!),
      ),
    );
  }

  Widget buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: passwordController,
        obscureText: hidePassword,
        decoration: InputDecoration(
          labelText: 'كلمة المرور',
          labelStyle: const TextStyle(fontSize: 16),
          suffixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => hidePassword = !hidePassword),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'كلمة المرور مطلوبة';
          if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
          ).hasMatch(val)) {
            return 'كلمة المرور ضعيفة';
          }
          return null;
        },
        onChanged: checkPasswordStrength,
        onSaved: (val) => password = val!,
      ),
    );
  }

  Widget buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'البريد الإلكتروني',
          labelStyle: const TextStyle(fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'البريد الإلكتروني مطلوب';
          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(val)) {
            return 'البريد الإلكتروني غير صالح';
          }
          return null;
        },
        onChanged: checkEmailValidation,
        onSaved: (val) => email = val!,
      ),
    );
  }

  Widget buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'تاريخ الميلاد',
          hintText: 'اختر تاريخ ميلادك',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Directionality(
                textDirection: flutter.TextDirection.rtl,
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              dateOfBirth = DateFormat('yyyy-MM-dd').format(picked);
              _dobController.text = dateOfBirth!;
            });
          }
        },
        validator: (_) {
          if (dateOfBirth == null || dateOfBirth!.isEmpty) {
            return 'الرجاء اختيار تاريخ الميلاد';
          }
          return null;
        },
      ),
    );
  }

  Widget buildCityDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: city,
        decoration: InputDecoration(
          labelText: 'المدينة التي تقيم بها',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
        items:
            cities.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c, textDirection: flutter.TextDirection.rtl),
              );
            }).toList(),
        onChanged: (val) => setState(() => city = val),
        validator: (val) => val == null ? 'الرجاء اختيار مدينة' : null,
      ),
    );
  }

  Widget buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الجنس',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('ذكر'),
                  value: 'ذكر',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('أنثى'),
                  value: 'أنثى',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
              ),
            ],
          ),
          if (gender == null)
            const Text(
              'يرجى اختيار الجنس',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('صورة الملف الشخصي', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: pickImage,
            child:
                profileImage == null
                    ? Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                    : CircleAvatar(
                      backgroundImage: FileImage(profileImage!),
                      radius: 60,
                    ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: LinearProgressIndicator(
        value: _currentPage == 0 ? 0.5 : 1,
        backgroundColor: Colors.grey[300],
        color: const Color(0xFFFF600A),
        minHeight: 5,
      ),
    );
  }

  void nextPage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _currentPage = 1);
    }
  }

  void previousPage() {
    setState(() => _currentPage = 0);
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> registerUser() async {
    final Uri url = Uri.parse(registerCaregiver); // update if needed

    final request = http.MultipartRequest('POST', url);

    // Add text fields
    request.fields['first_name'] = firstName ?? '';
    request.fields['last_name'] = lastName ?? '';
    request.fields['email'] = email ?? '';
    request.fields['password'] = password ?? '';
    request.fields['phone_number'] = phone ?? '';
    request.fields['date_of_birth'] = dateOfBirth ?? '';
    request.fields['gender'] = gender ?? '';
    request.fields['city'] = city ?? '';
    request.fields['zip_code'] = zipCode ?? '';
    request.fields['address'] = address ?? '';

    // Add image if selected
    if (profileImage != null) {
      final imageFile = await http.MultipartFile.fromPath(
        'image',
        profileImage!.path,
      );
      request.files.add(imageFile);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ تم إنشاء الحساب بنجاح! تحقق من بريدك الإلكتروني."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        String errorMessage =
            responseData['message'] ?? "حدث خطأ أثناء التسجيل";

        if (errorMessage.contains("already exists")) {
          errorMessage =
              "البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد آخر.";
        } else if (errorMessage.contains("already registered as a parent")) {
          errorMessage =
              "البريد الإلكتروني مسجل كولي أمر، لا يمكنك استخدامه كمقدم رعاية.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("فشل الاتصال بالخادم: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: flutter.TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _headerSection(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 5,
                ),
                child: _welcomeMessage(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: LinearProgressIndicator(
                  value: _currentPage == 0 ? 0.5 : 1.0,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFFFF600A),
                  minHeight: 5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_currentPage == 0) ...[
                        buildTextField(
                          "الاسم الأول",
                          (val) => firstName = val,
                          controller: firstNameController,
                        ),
                        buildTextField(
                          "اسم العائلة",
                          (val) => lastName = val,
                          controller: lastNameController,
                        ),
                        buildEmailField(),
                        if (emailValidationMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              emailValidationMessage,
                              style: TextStyle(color: emailValidationColor),
                            ),
                          ),
                        buildTextField(
                          "رقم الهاتف",
                          (val) => phone = val,
                          controller: phoneController,
                        ),
                        buildPasswordField(),
                        if (passwordStrengthMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              passwordStrengthMessage,
                              style: TextStyle(color: passwordStrengthColor),
                            ),
                          ),
                        buildDatePickerField(),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: nextPage,
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
                            'التالي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ] else ...[
                        buildImagePicker(),
                        buildGenderSelector(),
                        buildCityDropdown(),
                        buildTextField(
                          "الرمز البريدي (اختياري)",
                          (val) => zipCode = val,
                          isOptional: true,
                        ),
                        buildTextField("عنوان السكن", (val) => address = val),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: agreedToTerms,
                              onChanged:
                                  (val) => setState(() => agreedToTerms = val!),
                            ),
                            Expanded(
                              child: Text(
                                "أوافق على شروط الاستخدام. لمزيد من التفاصيل حول جمع معلوماتك واستخدامها، راجع سياسة الخصوصية الخاصة بنا.",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: previousPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 30,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'السابق',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;
                                if (!agreedToTerms) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "يجب الموافقة على شروط الاستخدام أولًا.",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                _formKey.currentState!.save();
                                await registerUser();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF600A),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 30,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'إنشاء حساب',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            children: [
                              const TextSpan(
                                text: "هل تبحث عن رعاية لأطفالك؟ ",
                              ),
                              TextSpan(
                                text: "سجّل كولي أمر الآن!",
                                style: const TextStyle(
                                  color: Color(0xFFFF600A),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register',
                                        );
                                      },
                              ),
                            ],
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
      ),
    );
  }
}
