import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Home/edit_parent_profile_page.dart';
// ignore: library_prefixes
import 'package:flutter_app/pages/config.dart' as Config;
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParentData();
  }

  Future<void> fetchParentData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print('🔑 Token: $token');

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/me'),
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

  void navigateToEditPage() async {
    if (parentData != null) {
      final updated = await Navigator.pushNamed(context, '/editParentProfile', arguments: parentData);
      if (updated == true) {
        fetchParentData(); // reload on return
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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditParentProfilePage(parentData: parentData!),
                    ),
                  );
                  if (result == true) fetchParentData(); // ✅ تحديث البيانات بعد الحفظ
                },
              )
            ],

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFFFD6BA),
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${parentData?['firstName'] ?? ''} ${parentData?['lastName'] ?? ''}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    parentData?['city'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  buildInfoRow(Icons.email, 'البريد الإلكتروني', parentData?['email']),
                  buildInfoRow(Icons.phone, 'رقم الهاتف', parentData?['phone']),
                  buildInfoRow(Icons.cake, 'تاريخ الميلاد', birthDate),
                  buildInfoRow(Icons.location_pin, 'العنوان', parentData?['address']),
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
