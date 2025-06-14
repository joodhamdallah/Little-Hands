import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Home/edit_parent_profile_page.dart';
import 'package:flutter_app/pages/config.dart' ;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  Map<String, dynamic>? parentData;
  Map<String, dynamic>? childRequest;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParentData();
    fetchChildRequest();
  }

  Future<void> fetchParentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print('🔑 Token: $token');

    final response = await http.get(
      Uri.parse('${url}me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print('📥 Data: $decoded');

      if (decoded['data'] != null) {
        setState(() {
          parentData = decoded['data'];
          isLoading = false;
        });
      } else {
        print('❌ No "data" field found in response');
      }
    } else {
      print('❌ Failed to fetch parent profile: ${response.statusCode}');
      print('📥 Body: ${response.body}');
    }
  }

  Future<void> fetchChildRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString('userId');

    if (parentId == null) return;

    final response = await http.get(
      Uri.parse('${url}babysitter-requests/by-parent/$parentId'),
    );

    print("📡 Child Info Request URL: ${url}babysitter-requests/by-parent/$parentId");
    print("📬 Response: ${response.statusCode} → ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        childRequest = data['data'];
      });
    }
  }


void navigateToEditPage() async {
  if (parentData != null) {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditParentProfilePage(parentData: parentData!),
      ),
    );

    if (updated == true) {
      fetchParentData();
      fetchChildRequest();
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final birthDate = parentData?['dateOfBirth'] != null
        ? DateFormat('yyyy-MM-dd').format(DateTime.tryParse(parentData?['dateOfBirth']) ?? DateTime(2000))
        : 'غير متوفر';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF600A),
        title: const Text('الملف الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: navigateToEditPage,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFFFD6BA),
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${parentData?['firstName'] ?? ''} ${parentData?['lastName'] ?? ''}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      parentData?['city'] ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  buildInfoRow(Icons.email, 'البريد الإلكتروني', parentData?['email']),
                  buildInfoRow(Icons.phone, 'رقم الهاتف', parentData?['phone']),
                  buildInfoRow(Icons.cake, 'تاريخ الميلاد', birthDate),
                  buildInfoRow(Icons.location_pin, 'العنوان', parentData?['address']),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'معلومات الأطفال',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  if (childRequest != null) ...[
                    buildInfoRow(Icons.child_care, 'أعمار الأطفال',
                        childRequest!['children_ages']?.join(', ') ?? 'غير محدد'),
                    if (childRequest!['has_medical_condition'] == true)
                      buildInfoRow(Icons.warning, 'حالة طبية',
                          childRequest!['medical_condition_details'] ?? 'مذكورة'),
                    if (childRequest!['takes_medicine'] == true)
                      buildInfoRow(Icons.medication, 'أدوية',
                          childRequest!['medicine_details'] ?? 'مذكورة'),
                    if (childRequest!['additional_notes'] != null &&
                        childRequest!['additional_notes'].toString().isNotEmpty)
                      buildInfoRow(Icons.notes, 'ملاحظات إضافية', childRequest!['additional_notes']),
                  ] else
                    const Text('لا توجد معلومات عن الأطفال بعد.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value ?? 'غير متوفر',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
