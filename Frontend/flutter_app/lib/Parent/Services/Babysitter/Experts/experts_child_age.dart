import 'package:flutter/material.dart';

class ChildAgeAndChallengesPage extends StatefulWidget {
  const ChildAgeAndChallengesPage({super.key});

  @override
  State<ChildAgeAndChallengesPage> createState() =>
      _ChildAgeAndChallengesPageState();
}

class _ChildAgeAndChallengesPageState extends State<ChildAgeAndChallengesPage> {
  final Color primaryColor = const Color(0xFFFF600A);
  final List<String> ageOptions = [
    '👶 أطفال ما قبل المدرسة',
  '👦 أطفال في سن المدرسة',
  '🧑‍🎓 مراهقون',
  ];

  String? selectedAge;
  final TextEditingController _challengesController = TextEditingController();

  @override
  void dispose() {
    _challengesController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (selectedAge != null) {
      Navigator.pushNamed(
        context,
        '/parentExpertsessionPage',
        arguments: {
          'ageGroup': selectedAge,
          'challenges': _challengesController.text.trim(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: Color(0xFFFDFDFD),
          title: const Text(
            'عمر الطفل والتحديات الحالية',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: 0.4,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'العمر:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3.8,
                      mainAxisSpacing: 12,
                      children: ageOptions.map((age) {
                        final isSelected = selectedAge == age;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAge = age;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  // ignore: deprecated_member_use
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  age,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'NotoSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'ما هي التحديات التي يواجهها الطفل؟',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _challengesController,
                      maxLines: 5,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'اكتب التحديات هنا...',
                        hintStyle: const TextStyle(
                          fontFamily: 'NotoSansArabic',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAge != null ? _onNextPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                      color: Colors.white,
                    ),
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
 