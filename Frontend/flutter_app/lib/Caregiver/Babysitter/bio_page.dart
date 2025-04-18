import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Babysitter/rate_page.dart';

class BabySitterBioPage extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const BabySitterBioPage({super.key, required this.previousData});

  @override
  State<BabySitterBioPage> createState() => _BabySitterBioPageState();
}

class _BabySitterBioPageState extends State<BabySitterBioPage> {
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
          backgroundColor: const Color(0xFFFF600A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
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
                              'نبذة تعريفية عنكِ',
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
                                  Text('💡 ساعدي العائلات للتعرّف عليكِ بشكل أفضل:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NotoSansArabic',
                                      )),
                                  SizedBox(height: 8),
                                  Text('• لماذا تحبين العمل كمربية؟'),
                                  Text('• ما هي خبراتك السابقة؟'),
                                  Text('• ما المهارات أو الشهادات التي لديكِ؟'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _bioController,
                              maxLines: 7,
                              onChanged: (value) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'اكتبي نبذة تعريفية هنا...',
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
                              style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 127, 127, 127)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '*   صفحتك الشخصية ستكون ظاهرة للمستخدمين، لذلك لا تكتبي معلوماتك الشخصية مثل رقم الهاتف أو الروابط الخاصة بك وإلا سيتم رفض طلبك تلقائياً.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 190, 0, 0)),
                            ),
                            const Spacer(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                    onPressed: _bioController.text.length >= _minLength
    ? () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BabySitterRatePage(
                                previousData: {
                                  ...widget.previousData,
                                  'bio': _bioController.text.trim(),
                                },
                              ),
                            ),
                          );

                        }
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
              );
            },
          ),
        ),
      ),
    );
  }
}
