import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShadowTeacherStep2 extends StatefulWidget {
  const ShadowTeacherStep2({super.key});

  @override
  State<ShadowTeacherStep2> createState() => _ShadowTeacherStep2State();
}

class _ShadowTeacherStep2State extends State<ShadowTeacherStep2> {
  final List<String> qualifications = [
    'بكالوريوس',
    'دبلوم',
    'دورات تدريبية',
    'أخرى',
  ];

  final List<String> experienceOptions = [
    '1 سنة',
    '2 سنتان',
    '3 سنوات',
    '4 سنوات',
    '5 سنوات',
    '6 سنوات',
    'أكثر من 6 سنوات',
  ];

  String? selectedQualification;
  bool? hasExperience;
  String? selectedYears;
  File? _pickedImage;

  Future<void> _pickCertificateImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.32,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF600A)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Question 1
                    const Text(
                      'ما هي المؤهلات العلمية التي تمتلكها؟',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: qualifications.map((option) {
                        final isSelected = selectedQualification == option;
                        return ChoiceChip(
                          label: Text(
                            option,
                            style: const TextStyle(fontFamily: 'NotoSansArabic'),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFFEEE5),
                          onSelected: (_) {
                            setState(() {
                              selectedQualification = option;
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFFF600A)
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Upload image button
                    ElevatedButton.icon(
                      onPressed: _pickCertificateImage,
                      icon: const Icon(Icons.image_outlined, color: Color(0xFFFF600A)),
                      label: const Text(
                        'إرفاق صورة الشهادة',
                        style: TextStyle(
                          fontFamily: 'NotoSansArabic',
                          fontSize: 16,
                          color: Color(0xFFFF600A),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.grey.shade100,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFFF600A)),
                        ),
                      ),
                    ),
                    if (_pickedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'تم اختيار الصورة: ${_pickedImage!.path.split('/').last}',
                          style: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    const Divider(height: 24, thickness: 1),

                    // Question 2
                    const Text(
                      'هل لديك خبرة سابقة في التعامل مع الأطفال ذوي الاحتياجات الخاصة؟',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['نعم', 'لا'].map((answer) {
                        final isSelected =
                            hasExperience == (answer == 'نعم');
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                hasExperience = answer == 'نعم';
                                if (!hasExperience!) selectedYears = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFEEE5)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF600A)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  answer,
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansArabic',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Experience years
                    if (hasExperience == true) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'كم عدد سنوات الخبرة؟',
                        style: TextStyle(
                          fontFamily: 'NotoSansArabic',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: experienceOptions.map((label) {
                          final isSelected = selectedYears == label;
                          return ChoiceChip(
                            label: Text(label,
                                style: const TextStyle(
                                    fontFamily: 'NotoSansArabic')),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFFEEE5),
                            onSelected: (_) {
                              setState(() {
                                selectedYears = label;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFF600A)
                                  : Colors.grey.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                    Navigator.pushNamed(context, '/shadowteacherQ3'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF600A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
