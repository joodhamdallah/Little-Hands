import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isAPIcallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final GlobalKey progressHUDKey = GlobalKey();

  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phone;
  String? role;
  String? dateOfBirth;
  String? address;

  String passwordStrengthMessage = "";
  Color passwordStrengthColor = Colors.red;

  final List<Map<String, String>> roles = [
    {"id": "admin", "label": "Admin"},
    {"id": "parent", "label": "Parent"},
    {"id": "expert", "label": "Expert"},
    {"id": "specialist", "label": "Specialist"},
  ];

  void checkPasswordStrength(String value) {
    final hasUpper = RegExp(r'[A-Z]');
    final hasLower = RegExp(r'[a-z]');
    final hasDigit = RegExp(r'\d');
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    final hasMinLength = value.length >= 8;

    if (!hasMinLength) {
      passwordStrengthMessage = "❌ Must be at least 8 characters";
      passwordStrengthColor = Colors.red;
    } else if (!hasUpper.hasMatch(value)) {
      passwordStrengthMessage = "❌ Add an uppercase letter";
      passwordStrengthColor = Colors.orange;
    } else if (!hasLower.hasMatch(value)) {
      passwordStrengthMessage = "❌ Add a lowercase letter";
      passwordStrengthColor = Colors.orange;
    } else if (!hasDigit.hasMatch(value)) {
      passwordStrengthMessage = "❌ Add a number";
      passwordStrengthColor = Colors.orange;
    } else if (!hasSpecial.hasMatch(value)) {
      passwordStrengthMessage = "❌ Add a special character";
      passwordStrengthColor = Colors.orange;
    } else {
      passwordStrengthMessage = "✅ Strong password!";
      passwordStrengthColor = Colors.green;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: HexColor("F9C74F"),
        body: ProgressHUD(
          key: progressHUDKey,
          inAsyncCall: isAPIcallProcess,
          opacity: 0.3,
          child: Form(key: globalFormKey, child: _registerUI(context)),
        ),
      ),
    );
  }

  Widget _registerUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerSection(),
          _formFields(),
          _submitButton(),
          _footerLinks(),
        ],
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.white]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(100),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/littlehandslogo.png",
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          const Text(
            "Register",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formFields() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInputField("First Name", (val) => firstName = val),
          _buildInputField("Last Name", (val) => lastName = val),
          _buildInputField("Email", (val) => email = val, isEmail: true),
          _buildPasswordField(),
          if (passwordStrengthMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                passwordStrengthMessage,
                style: TextStyle(color: passwordStrengthColor),
              ),
            ),
          _buildInputField("Phone", (val) => phone = val),
          _buildDatePickerField(),
          _buildInputField("Address", (val) => address = val),
          FormHelper.dropDownWidgetWithLabel(
            context,
            "Role",
            "Select Role",
            role,
            roles,
            (onChangedVal) => setState(() => role = onChangedVal),
            (onValidateVal) => null,
            borderColor: Colors.white,
            borderRadius: 10,
            optionValue: "id",
            optionLabel: "label",
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    Function(String) onSave, {
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FormHelper.inputFieldWidget(
        context,
        label,
        label,
        (val) {
          if (val.isEmpty) return "$label can't be empty.";
          if (isEmail &&
              !RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              ).hasMatch(val)) {
            return "Invalid email format.";
          }
          return null;
        },
        (val) => onSave(val),
        borderFocusColor: Colors.white,
        borderColor: Colors.white,
        textColor: Colors.white,
        hintColor: Colors.white,
        borderRadius: 10,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        obscureText: hidePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Password",
          labelStyle: const TextStyle(color: Colors.white),
          hintText: "Enter your password",
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() => hidePassword = !hidePassword),
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            color: Colors.white,
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "Password can't be empty.";
          final passwordRegex = RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
          );
          if (!passwordRegex.hasMatch(val)) {
            return "Must include uppercase, lowercase, number, symbol & min 8 chars.";
          }
          return null;
        },
        onChanged: (val) => checkPasswordStrength(val),
        onSaved: (val) => password = val,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              dateOfBirth = picked.toIso8601String();
            });
          }
        },
        child: AbsorbPointer(
          child: FormHelper.inputFieldWidget(
            context,
            "Date of Birth",
            dateOfBirth != null
                ? dateOfBirth!.split("T").first
                : "Select your birthdate",
            (val) {
              if (dateOfBirth == null || dateOfBirth!.isEmpty) {
                return "Date of Birth can't be empty.";
              }
              return null;
            },
            (val) {},
            borderFocusColor: Colors.white,
            borderColor: Colors.white,
            textColor: Colors.white,
            hintColor: Colors.white,
            borderRadius: 10,
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Center(
      child: FormHelper.submitButton(
        "Register",
        () {
          if (globalFormKey.currentState!.validate()) {
            globalFormKey.currentState!.save();
            setState(() => isAPIcallProcess = true);
            registerUser();
          }
        },
        btnColor: HexColor("#FFB3BA"),
        borderColor: Colors.white,
        txtColor: Colors.white,
        borderRadius: 10,
      ),
    );
  }

  Widget _footerLinks() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey, fontSize: 14.0),
            children: <TextSpan>[
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: 'Login',
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, "/login");
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void registerUser() async {
    try {
      final url = Uri.parse(registeration);
      final headers = {"Content-Type": "application/json"};
      final requestBody = {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "phone": phone,
        "role": role,
        "dateOfBirth": dateOfBirth,
        "address": address,
      }.map((key, value) => MapEntry(key, value ?? ""));

      debugPrint("🚀 Sending POST to $url");
      debugPrint("📤 Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint("✅ Response Code: ${response.statusCode}");
      debugPrint("📨 Response Body: ${response.body}");

      if (!mounted) return;
      setState(() => isAPIcallProcess = false);

      if (response.statusCode == 201) {
        FormHelper.showSimpleAlertDialog(
          context,
          "Success",
          "Registration successful! Please check your email.",
          "OK",
          () => Navigator.pushNamed(context, "/login"),
        );
      } else {
        FormHelper.showSimpleAlertDialog(
          context,
          "Failed",
          "Registration failed: ${response.body}",
          "OK",
          () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isAPIcallProcess = false);
      debugPrint("🔥 Exception: $e");
      FormHelper.showSimpleAlertDialog(
        context,
        "Error",
        "Something went wrong. Please try again.",
        "OK",
        () => Navigator.pop(context),
      );
    }
  }
}
