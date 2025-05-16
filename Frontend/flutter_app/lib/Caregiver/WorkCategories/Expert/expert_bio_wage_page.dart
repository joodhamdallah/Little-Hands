import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_provider.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpertBioPage extends StatefulWidget {
  const ExpertBioPage({super.key});

  @override
  State<ExpertBioPage> createState() => _ExpertBioPageState();
}

class _ExpertBioPageState extends State<ExpertBioPage> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final int _minLength = 150;

  @override
  void dispose() {
    _bioController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  bool isFormValid() {
    return _bioController.text.trim().length >= _minLength &&
        int.tryParse(_rateController.text.trim()) != null;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  Future<void> submitData(BuildContext context) async {
    final provider = Provider.of<ExpertProvider>(context, listen: false);
    provider.setBioAndRate(
      bio: _bioController.text.trim(),
      rate: int.parse(_rateController.text.trim()),
    );
    final token = await getToken();
    final data = provider.getAll();
    data['bio'] = provider.bio;
    data['rate'] = provider.rate;

    try {
      final response = await http.post(
        Uri.parse(expertDetails),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushNamed(context, '/idverifyapi');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إرسال البيانات: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إرسال البيانات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نبذة تعريفية عنك',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 ساعد الأهالي للتعرّف عليك بشكل أفضل:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansArabic',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('• ما هي مجالات خبرتك؟'),
                          Text('• ما نوع الفئات التي تفضل العمل معها؟'),
                          Text('• هل لديك مهارات أو تخصصات مميزة؟'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _bioController,
                      maxLines: 7,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'اكتب نبذة تعريفية هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFF600A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFF600A), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_bioController.text.length}/$_minLength (الحد الأدنى)',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'حدد أجرك للجلسة الواحدة (60 دقيقة)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'مثال: 120',
                        suffixText: 'شيكل',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFF600A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFF600A), width: 2),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '* السعر يكون للجلسة الواحدة ومدتها 60 دقيقة.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: isFormValid() ? () => submitData(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
                    ),
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
