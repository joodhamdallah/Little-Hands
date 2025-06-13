import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart' as Config;

class EditParentProfilePage extends StatefulWidget {
  final Map<String, dynamic> parentData;

  const EditParentProfilePage({super.key, required this.parentData});

  @override
  State<EditParentProfilePage> createState() => _EditParentProfilePageState();
}

class _EditParentProfilePageState extends State<EditParentProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  DateTime? birthDate;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.parentData['firstName']);
    lastNameController = TextEditingController(text: widget.parentData['lastName']);
    phoneController = TextEditingController(text: widget.parentData['phone']);
    addressController = TextEditingController(text: widget.parentData['address']);
    birthDate = widget.parentData['dateOfBirth'] != null
        ? DateTime.tryParse(widget.parentData['dateOfBirth'])
        : null;
  }

  Future<void> saveChanges() async {
    setState(() => isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final body = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "phone": phoneController.text,
      "address": addressController.text,
      if (birthDate != null) "dateOfBirth": birthDate!.toIso8601String(),
    };

    final response = await http.put(
      Uri.parse('${Config.baseUrl}/api/parents/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    setState(() => isSaving = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // return success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث البيانات'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        backgroundColor: const Color(0xFFFF600A),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isSaving ? null : saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildTextField('الاسم الأول', firstNameController),
            buildTextField('اسم العائلة', lastNameController),
            buildTextField('رقم الهاتف', phoneController, keyboard: TextInputType.phone),
            buildTextField('العنوان', addressController),
            const SizedBox(height: 16),
            const Text('تاريخ الميلاد', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: birthDate ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  locale: const Locale('ar'),
                );
                if (picked != null) {
                  setState(() => birthDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  birthDate != null
                      ? DateFormat('yyyy-MM-dd').format(birthDate!)
                      : 'اختر تاريخ الميلاد',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
