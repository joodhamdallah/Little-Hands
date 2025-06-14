import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart';

class EditParentProfilePage extends StatefulWidget {
  final Map<String, dynamic> parentData;

  const EditParentProfilePage({super.key, required this.parentData});

  @override
  State<EditParentProfilePage> createState() => _EditParentProfilePageState();
}

class _EditParentProfilePageState extends State<EditParentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.parentData['firstName'] ?? '');
    lastNameController = TextEditingController(text: widget.parentData['lastName'] ?? '');
    phoneController = TextEditingController(text: widget.parentData['phone'] ?? '');
    addressController = TextEditingController(text: widget.parentData['address'] ?? '');
    selectedDate = widget.parentData['dateOfBirth'] != null
        ? DateTime.tryParse(widget.parentData['dateOfBirth'])
        : null;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final body = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      if (selectedDate != null) 'dateOfBirth': selectedDate!.toIso8601String(),
    };

    final response = await http.put(
      Uri.parse('${url}parents/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في حفظ التعديلات'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final initial = selectedDate ?? DateTime(now.year - 10);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        backgroundColor: const Color(0xFFFF600A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(firstNameController, 'الاسم الأول'),
              buildTextField(lastNameController, 'الاسم الأخير'),
              buildTextField(phoneController, 'رقم الهاتف', keyboardType: TextInputType.phone),
              buildTextField(addressController, 'العنوان'),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : 'تاريخ الميلاد',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF600A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }
}
