import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';

class ExpertSessionDetailsPage extends StatefulWidget {
  const ExpertSessionDetailsPage({super.key});

  @override
  State<ExpertSessionDetailsPage> createState() =>
      _ExpertSessionDetailsPageState();
}

class _ExpertSessionDetailsPageState extends State<ExpertSessionDetailsPage> {
  final Color primaryColor = const Color(0xFFFF600A);

  final List<String> sessionTypes = [
    '📝 تقييم أولي',
    '👪 جلسة استشارية مع الأهل',
    '🧒 جلسة علاجية فردية مع الطفل',
    '🔄 متابعة وتعديل خطة علاجية',
  ];

  final List<String> selectedSessionTypes = [];
  String? selectedMode = 'حضوري';
  DateTime? selectedDate;
  bool isFlexible = false;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  void toggleSessionType(String type) {
    setState(() {
      if (selectedSessionTypes.contains(type)) {
        selectedSessionTypes.remove(type);
      } else {
        selectedSessionTypes.add(type);
      }
    });
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickTime({required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void onNext() {
    Navigator.pushNamed(
      context,
      '/parentExpertReviewPage',
      arguments: {
        'sessionTypes': selectedSessionTypes,
        'mode': selectedMode,
        'date': selectedDate?.toIso8601String(),
        'isFlexible': isFlexible,
        'startTime': startTime?.format(context),
        'endTime': endTime?.format(context),
      },
    );
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
            'نوع الجلسة وموعدها',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: 0.6,
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
                      '🗓️ نوع الجلسة المطلوبة',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: sessionTypes.map((type) {
                        final selected = selectedSessionTypes.contains(type);
                        return GestureDetector(
                          onTap: () => toggleSessionType(type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? primaryColor
                                    : Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '🕘 موعد الجلسة',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'حضوري',
                          groupValue: selectedMode,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              selectedMode = value;
                            });
                          },
                        ),
                        const Text('حضوري'),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: 'عن بُعد',
                          groupValue: selectedMode,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              selectedMode = value;
                            });
                          },
                        ),
                        const Text('عن بُعد'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'تاريخ البداية:',
                          style: TextStyle(
                              fontSize: 17, fontFamily: 'NotoSansArabic'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: pickDate,
                          style: OutlinedButton.styleFrom(
                                                   side: BorderSide(color: primaryColor),
                          ),
                      child: Text(
                            selectedDate != null
                                ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                : 'اختر التاريخ',
                            style: const TextStyle(fontFamily: 'NotoSansArabic'),
                          ),

                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isFlexible,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              isFlexible = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'هل الموعد مرن؟',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'NotoSansArabic',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'الوقت:',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickTime(isStart: true),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                            ),
                            child: Text(
                              startTime != null
                                  ? startTime!.format(context)
                                  : 'من',
                              style: const TextStyle(
                                  fontFamily: 'NotoSansArabic'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickTime(isStart: false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                            ),
                            child: Text(
                              endTime != null ? endTime!.format(context) : 'إلى',
                              style: const TextStyle(
                                  fontFamily: 'NotoSansArabic'),
                            ),
                          ),
                        ),
                      ],
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
                   onPressed: () {
                    Navigator.pushNamed(context, '/parentExpertbudgetPage');
                  },
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

