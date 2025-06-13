import 'package:flutter/material.dart';

class SpecialNeedsSchedulePage extends StatefulWidget {
  const SpecialNeedsSchedulePage({super.key});

  @override
  State<SpecialNeedsSchedulePage> createState() =>
      _SpecialNeedsSchedulePageState();
}

class _SpecialNeedsSchedulePageState extends State<SpecialNeedsSchedulePage> {
  final Color primaryColor = const Color(0xFFFF600A);

  final List<String> supportLocations = [
    'المدرسة',
    'الروضة',
    'المنزل',
    'في أكثر من مكان',
    'عن بُعد (افتراضي)',
  ];

  final List<String> weekdays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  final Set<String> selectedLocations = {};
  final Set<String> selectedDays = {};
  String attendanceType = 'جزئي';
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isFlexible = false;

  void toggleLocation(String loc) {
    setState(() {
      if (selectedLocations.contains(loc)) {
        selectedLocations.remove(loc);
      } else {
        selectedLocations.add(loc);
      }
    });
  }

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  Future<void> pickTime(bool isStart) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
      '/specialNeedsFinalStep',
      arguments: {
        'locations': selectedLocations.toList(),
        'attendance': attendanceType,
        'days': selectedDays.toList(),
        'startTime': startTime?.format(context),
        'endTime': endTime?.format(context),
        'isFlexible': isFlexible,
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
            'مكان وتوقيت الدعم',
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
                      'مكان تقديم الخدمة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: supportLocations.map((loc) {
                        final selected = selectedLocations.contains(loc);
                        return GestureDetector(
                          onTap: () => toggleLocation(loc),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                  color: selected
                                      ? primaryColor
                                      : Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              loc,
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
                      'المواعيد المطلوبة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'جزئي',
                          groupValue: attendanceType,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              attendanceType = value!;
                            });
                          },
                        ),
                        const Text('جزئي'),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: 'كامل',
                          groupValue: attendanceType,
                          activeColor: primaryColor,
                          onChanged: (value) {
                            setState(() {
                              attendanceType = value!;
                            });
                          },
                        ),
                        const Text('كامل'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'الأيام:',
                      style: TextStyle(
                          fontSize: 16, fontFamily: 'NotoSansArabic'),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: weekdays.map((day) {
                        final selected = selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () => toggleDay(day),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? primaryColor
                                    : Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('الوقت: من'),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => pickTime(true),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                          ),
                          child: Text(
                            startTime?.format(context) ?? 'اختر',
                            style: const TextStyle(fontFamily: 'NotoSansArabic'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('إلى'),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => pickTime(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                          ),
                          child: Text(
                            endTime?.format(context) ?? 'اختر',
                            style: const TextStyle(fontFamily: 'NotoSansArabic'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                          style: TextStyle(fontFamily: 'NotoSansArabic'),
                        ),
                      ],
                    ),
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
                    Navigator.pushNamed(context, '/specialNeedsFinalstep');
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
