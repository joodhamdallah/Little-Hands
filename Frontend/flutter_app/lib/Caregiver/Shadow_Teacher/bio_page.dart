import 'package:flutter/material.dart';

class ShadowTeacherBioPage extends StatefulWidget {
  const ShadowTeacherBioPage({super.key});

  @override
  State<ShadowTeacherBioPage> createState() => _ShadowTeacherBioPageState();
}

class _ShadowTeacherBioPageState extends State<ShadowTeacherBioPage> {
  final TextEditingController _bioController = TextEditingController();
  final int _minLength = 150;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
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
          children: [
            // ✅ Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.8,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF600A)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Main bio content
            Expanded(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          reverse: true,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
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
                                          '💡 ساعد العائلات لفهم خبراتك وتخصصك بشكل أفضل:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoSansArabic',
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text('• ما الذي يدفعك للعمل كمرافق للأطفال ذوي الاحتياجات؟'),
                                        Text('• هل لديك تجارب ناجحة سابقة؟'),
                                        Text('• ما المهارات أو البرامج التي تتقنها في هذا المجال؟'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _bioController,
                                    maxLines: 7,
                                    onChanged: (value) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: 'اكتب نبذة تعريفية هنا...',
                                      hintStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFFF600A), width: 1.5),
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 127, 127, 127),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '* صفحتك الشخصية ستكون ظاهرة للعائلات، لا تكتب معلوماتك الشخصية مثل رقم الهاتف أو روابط خارجية وإلا سيتم رفض الطلب.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 190, 0, 0),
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ✅ Next Button
                        Positioned(
                          bottom: 5 + MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          child: SizedBox(
                            width: double.infinity,
                            height: 53,
                            child: ElevatedButton(
                              onPressed: _bioController.text.length >= _minLength
                                  ? () {
                                      Navigator.pushNamed(context, '/shadowteacherpricing');
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF600A),
                                disabledBackgroundColor: Colors.orange.shade200,
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
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
