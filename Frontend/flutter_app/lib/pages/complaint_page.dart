import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _caregiverNameController =
      TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  DateTime? _selectedDate;
  String? _sessionType;
  bool isSubmitting = false;

  final List<String> sessionTypes = [
    'جلسة رعاية',
    'جلسة احتياجات خاصة',
    'استشارة تربوية',
    'اجتماع أو مقابلة',
  ];

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      textDirection: TextDirection.rtl,
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _sessionType != null) {
      setState(() => isSubmitting = true);

      // TODO: Save to Firestore or send to backend

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم إرسال الشكوى بنجاح")),
        );

        _formKey.currentState!.reset();
        _selectedDate = null;
        _sessionType = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء جميع الحقول المطلوبة")),
      );
    }
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

                // Session Type Dropdown
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
                  },
                  validator:
                      (value) =>
                          value == null ? 'يرجى اختيار نوع الجلسة' : null,
                ),
                const SizedBox(height: 16),

                // Caregiver Name
                TextFormField(
                  controller: _caregiverNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم مقدم/مقدمة الرعاية',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'يرجى إدخال اسم مقدم الرعاية'
                              : null,
                ),
                const SizedBox(height: 16),

                // Session Date
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'تاريخ الجلسة',
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                        hintText:
                            _selectedDate != null
                                ? intl.DateFormat.yMMMMd(
                                  'ar',
                                ).format(_selectedDate!)
                                : 'اختر التاريخ',
                      ),
                      validator:
                          (_) =>
                              _selectedDate == null
                                  ? 'يرجى اختيار تاريخ الجلسة'
                                  : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Complaint Subject
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

                // Complaint Details
                TextFormField(
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل الشكوى',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'يرجى إدخال التفاصيل'
                              : null,
                ),
                const SizedBox(height: 30),

                // Submit Button
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
