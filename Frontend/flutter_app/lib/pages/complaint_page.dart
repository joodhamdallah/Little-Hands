import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  String? _sessionType;
  String? _selectedCaregiverId;
  bool isSubmitting = false;
  List<Map<String, dynamic>> caregivers = [];

  final List<String> sessionTypes = [
    'جلسة رعاية أطفال',
    'جلسة احتياجات خاصة',
    'استشارة تربوية',
    'اجتماع أو مقابلة',
  ];

  Map<String, String> roleMap = {
    'جلسة رعاية أطفال': 'babysitter',
    'جلسة احتياجات خاصة': 'special_needs',
    'استشارة تربوية': 'expert',
  };

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = intl.DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _fetchCaregivers(String sessionType) async {
    final role = roleMap[sessionType];
    if (role == null) return;

    try {
      final res = await http.get(Uri.parse('${url}caregiver/by-role/$role'));
      print("📥 Caregiver API response: ${res.body}");

      final jsonRes = json.decode(res.body);
      if (jsonRes['success']) {
        setState(() {
          caregivers = List<Map<String, dynamic>>.from(jsonRes['data']);
          _selectedCaregiverId = null; // reset selection
        });
      }
    } catch (e) {
      print("❌ Error fetching caregivers: $e");
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _sessionType != null &&
        _selectedCaregiverId != null) {
      setState(() => isSubmitting = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final urll = Uri.parse('${url}complaints');
      final caregiver = caregivers.firstWhere(
        (c) => c['_id'] == _selectedCaregiverId,
      );
      final caregiverName =
          "${caregiver['first_name']} ${caregiver['last_name']}";

      final response = await http.post(
        urll,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'caregiver_name': caregiverName,
          'session_type': _sessionType,
          'session_date': _selectedDate!.toIso8601String(),
          'subject': _subjectController.text,
          'details': _detailsController.text,
        }),
      );

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم إرسال الشكوى بنجاح")),
        );

        _formKey.currentState!.reset();
        _selectedDate = null;
        _sessionType = null;
        _selectedCaregiverId = null;
        _dateController.clear();
        caregivers.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء جميع الحقول المطلوبة")),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقديم شكوى'),
          backgroundColor: const Color(0xFFFF600A),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'يرجى تعبئة النموذج التالي لتقديم شكوى بخصوص جلسة أو مقدم رعاية.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Session Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'نوع الجلسة',
                    border: OutlineInputBorder(),
                  ),
                  value: _sessionType,
                  items:
                      sessionTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (value) {
                    setState(() => _sessionType = value);
                    if (value != null) _fetchCaregivers(value);
                  },
                  validator:
                      (value) =>
                          value == null ? 'يرجى اختيار نوع الجلسة' : null,
                ),
                const SizedBox(height: 16),

                // Caregiver dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCaregiverId,
                  decoration: const InputDecoration(
                    labelText: 'اسم مقدم الرعاية',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      caregivers.map((cg) {
                        final fullName =
                            "${cg['first_name']} ${cg['last_name']}";
                        return DropdownMenuItem<String>(
                          // ✅ Add <String> here
                          value: cg['_id'].toString(), // ✅ Ensure it's a String
                          child: Text(fullName),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedCaregiverId = value),
                  validator:
                      (value) =>
                          value == null ? 'يرجى اختيار مقدم الرعاية' : null,
                ),

                const SizedBox(height: 16),

                // Date
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الجلسة',
                    hintText: 'اضغط لاختيار التاريخ',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator:
                      (_) =>
                          _selectedDate == null
                              ? 'يرجى اختيار تاريخ الجلسة'
                              : null,
                ),
                const SizedBox(height: 16),

                // Subject
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'موضوع الشكوى',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'يرجى إدخال الموضوع'
                              : null,
                ),
                const SizedBox(height: 16),

                // Details
                TextFormField(
                  controller: _detailsController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل الشكوى',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'يرجى إدخال التفاصيل'
                              : null,
                ),
                const SizedBox(height: 30),

                // Submit
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _submitForm,
                  icon: const Icon(Icons.report),
                  label:
                      isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('إرسال الشكوى'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
