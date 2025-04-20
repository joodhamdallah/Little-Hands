// expert_qualification_page.dart
/*
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// class ExpertQualificationPage extends StatefulWidget {
//   const ExpertQualificationPage({super.key});

//   @override
//   State<ExpertQualificationPage> createState() =>
//       _ExpertQualificationPageState();
// }

// class _ExpertQualificationPageState extends State<ExpertQualificationPage> {
//   bool isFormValid() {
//     for (int i = 0; i < selectedDegrees.length; i++) {
//       if (selectedDegrees[i] == null ||
//           specializationControllers[i].text.isEmpty ||
//           institutionControllers[i].text.isEmpty) {
//         return false;
//       }
//       if (selectedDegrees[i] == 'أخرى' &&
//           otherDegreeControllers[i].text.isEmpty) {
//         return false;
//       }
//     }
//     if (hasLicense) {
//       if (authorityNameController.text.isEmpty ||
//           expiryDateController.text.isEmpty ||
//           licenseAttachmentFileName == null) {
//         return false;
//       }
//     }
//     return true;
//   }

//   final List<String?> selectedDegrees = [];
//   final List<String?> attachedDegrees = [];
//   final List<TextEditingController> specializationControllers = [];
//   final List<TextEditingController> institutionControllers = [];
//   final List<TextEditingController> otherDegreeControllers = [];

//   final List<String> degreeOptions = [
//     'بكالوريوس',
//     'ماجستير',
//     'دكتوراه',
//     'دبلوم عالي',
//     'أخرى',
//   ];

//   bool hasLicense = false;
//   final TextEditingController authorityNameController = TextEditingController();
//   final TextEditingController expiryDateController = TextEditingController();
//   String? licenseAttachmentFileName;

//   Future<void> pickDegreeFile(int index) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         if (attachedDegrees.length > index) {
//           attachedDegrees[index] = result.files.single.name;
//         } else {
//           attachedDegrees.add(result.files.single.name);
//         }
//       });
//     }
//   }

//   Future<void> pickLicenseFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         licenseAttachmentFileName = result.files.single.name;
//       });
//     }
//   }

//   void addDegreeField() {
//     setState(() {
//       selectedDegrees.add(null);
//       attachedDegrees.add(null);
//       specializationControllers.add(TextEditingController());
//       institutionControllers.add(TextEditingController());
//       otherDegreeControllers.add(TextEditingController());
//     });
//   }

//   void removeDegreeField(int index) {
//     setState(() {
//       selectedDegrees.removeAt(index);
//       attachedDegrees.removeAt(index);
//       specializationControllers[index].dispose();
//       institutionControllers[index].dispose();
//       otherDegreeControllers[index].dispose();
//       specializationControllers.removeAt(index);
//       institutionControllers.removeAt(index);
//       otherDegreeControllers.removeAt(index);
//     });
//   }

//   @override
//   void dispose() {
//     authorityNameController.dispose();
//     expiryDateController.dispose();
//     for (var controller in specializationControllers) {
//       controller.dispose();
//     }
//     for (var controller in institutionControllers) {
//       controller.dispose();
//     }
//     for (var controller in otherDegreeControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     addDegreeField();
//   }

//   Widget buildDivider() => const Padding(
//     padding: EdgeInsets.symmetric(horizontal: 16.0),
//     child: Divider(color: Colors.black12, thickness: 1),
//   );

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
          title: const Text(
            'الشهادات العلمية والترخيص',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'ما الشهادات العلمية التي حصلت عليها؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedDegrees.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF600A),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'شهادة ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
                              IconButton(
                                onPressed: () => removeDegreeField(index),
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            value: selectedDegrees[index],
                            hint: const Text('اختر نوع الشهادة'),
                            items:
                                degreeOptions
                                    .map(
                                      (degree) => DropdownMenuItem(
                                        value: degree,
                                        child: Text(degree),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setState(
                                  () => selectedDegrees[index] = value,
                                ),
                          ),
                          if (selectedDegrees[index] == 'أخرى')
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextField(
                                controller: otherDegreeControllers[index],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'حدد الشهادة الأخرى',
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: specializationControllers[index],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'تخصص الشهادة',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: institutionControllers[index],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'الجامعة أو الجهة المانحة',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async => await pickDegreeFile(index),
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              attachedDegrees[index] ?? 'إرفاق شهادة المؤهل',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF600A),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: addDegreeField,
                    icon: const Icon(Icons.add, color: Color(0xFFFF600A)),
                    label: const Text(
                      'إضافة مؤهل آخر',
                      style: TextStyle(
                        color: Color(0xFFFF600A),
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                buildDivider(),
                const SizedBox(height: 32),
                const Text(
                  'هل تمتلك ترخيصاً أو عضوية في جهة مهنية معتمدة؟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Radio(
                      value: true,
                      groupValue: hasLicense,
                      onChanged: (value) => setState(() => hasLicense = true),
                    ),
                    const Text('نعم'),
                    const SizedBox(width: 20),
                    Radio(
                      value: false,
                      groupValue: hasLicense,
                      onChanged: (value) => setState(() => hasLicense = false),
                    ),
                    const Text('لا'),
                  ],
                ),
                if (hasLicense) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'اسم الجهة المانحة',
                    style: TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: authorityNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'مثال: وزارة الصحة',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تاريخ انتهاء الترخيص',
                    style: TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: expiryDateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'مثال: 12/2025',
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async => await pickLicenseFile(),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      licenseAttachmentFileName ?? 'إرفاق صورة أو ملف الترخيص',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF600A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          isFormValid()
                              ? () => Navigator.pushNamed(
                                context,
                                '/expertExperienceQ4',
                              )
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF600A),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/