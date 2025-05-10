import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_childdage_parent3.dart';

class BabysitterTypeSelectionPage extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const BabysitterTypeSelectionPage({super.key, required this.previousData});

  @override
  State<BabysitterTypeSelectionPage> createState() =>
      _BabysitterTypeSelectionPageState();
}

class _BabysitterTypeSelectionPageState
    extends State<BabysitterTypeSelectionPage> {
  String? selectedType;
  bool showExtraFields = false;
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  bool flexibleTime = false;
  DateTime? endDate;
  bool noEndDate = false;
  List<String> selectedDays = [];

  final List<Map<String, dynamic>> sessionTypes = [
    {
      'value': 'regular',
      'title': 'جليسة منتظمة',
      'subtitle':
          'جليسة تأتي في أوقات محددة خلال الأسبوع مثل قبل/بعد المدرسة، أو لأيام متكررة بشكل ثابت.',
      'icon': Icons.calendar_today_outlined,
    },
    {
      'value': 'once',
      'title': 'جليسة لمرة واحدة',
      'subtitle':
          'جليسة تُطلب لمناسبة واحدة أو حالة طارئة، مثل حفلة أو موعد أو سفر ليوم واحد.',
      'icon': Icons.event,
    },
    {
      'value': 'nanny',
      'title': 'مربية (Nanny)',
      'subtitle':
          'جليسة بدوام جزئي أو كامل، عادة لأيام متعددة أسبوعيًا وتكون مسؤولة عن مهام رعاية شاملة.',
      'icon': Icons.family_restroom,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          automaticallyImplyLeading: false, // Disable default back
          title: const Text(
            'نوع جليسة الأطفال',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/parentHome', // or '/caregiverHome'
                  (route) => false,
                );
              },
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (showExtraFields) {
                setState(() => showExtraFields = false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const LinearProgressIndicator(
                value: 0.4,
                backgroundColor: Colors.grey,
                color: Color(0xFFFF600A),
                minHeight: 6,
              ),
              const SizedBox(height: 24),
              const Text(
                'اختر نوع جليسة الأطفال التي تحتاجها :',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 20),

              if (!showExtraFields)
                ...sessionTypes.map((type) => _buildTypeCard(type)),

              if (showExtraFields && selectedType != null) ...[
                const SizedBox(height: 10),
                // ✅ عرض البطاقة المختارة
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF600A)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sessionTypes.firstWhere(
                          (type) => type['value'] == selectedType,
                        )['icon'],
                        color: const Color(0xFFFF600A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sessionTypes.firstWhere(
                                (type) => type['value'] == selectedType,
                              )['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sessionTypes.firstWhere(
                                (type) => type['value'] == selectedType,
                              )['subtitle'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildExtraFields(selectedType!),
              ],

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed:
                      isFormValid()
                          ? () {
                            if (showExtraFields) {
                              final updatedJobDetails = {
                                ...widget.previousData,
                                'session_type': selectedType,
                                'session_start_date': selectedDate,
                                'session_start_time': selectedStartTime?.format(
                                  context,
                                ),
                                'session_end_time': selectedEndTime?.format(
                                  context,
                                ),
                                'session_days': selectedDays,
                                'session_end_date':
                                    noEndDate ? 'إلى إشعار آخر' : endDate,
                                'is_flexible_time': flexibleTime,
                              };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddChildrenAgePage(
                                        previousData: updatedJobDetails,
                                      ),
                                ),
                              );
                            } else {
                              setState(() => showExtraFields = true);
                            }
                          }
                          : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  String? getSessionDuration() {
    if (selectedStartTime != null && selectedEndTime != null) {
      final startMinutes =
          selectedStartTime!.hour * 60 + selectedStartTime!.minute;
      final endMinutes = selectedEndTime!.hour * 60 + selectedEndTime!.minute;

      int durationMinutes = endMinutes - startMinutes;

      // في حال كان نهاية الوقت أصغر من البداية (عبور منتصف الليل)
      if (durationMinutes < 0) {
        durationMinutes += 24 * 60;
      }

      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;

      if (hours == 0 && minutes == 0) {
        return null;
      } else if (hours == 0) {
        return 'مدة الجلسة: $minutes دقيقة';
      } else if (minutes == 0) {
        return 'مدة الجلسة: $hours ساعة';
      } else {
        return 'مدة الجلسة: $hours ساعة و $minutes دقيقة';
      }
    }
    return null;
  }

  Widget _buildTypeCard(Map<String, dynamic> type) {
    final isSelected = selectedType == type['value'];
    return GestureDetector(
      onTap: () => setState(() => selectedType = type['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E8) : const Color(0xFFF8F8F8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFFFF600A) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(type['icon'], color: const Color(0xFFFF600A), size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type['subtitle'],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularFields() {
    final days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarSection(),
        const SizedBox(height: 20),
        const Text(
          'اختر الأيام:',
          style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic'),
        ),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            return FilterChip(
              label: Text(days[index]),
              selected: selectedDays.contains(days[index]),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    selectedDays.add(days[index]);
                  } else {
                    selectedDays.remove(days[index]);
                  }
                });
              },
            );
          }),
        ),
        const SizedBox(height: 20),
        _buildTimeSection(),
        const SizedBox(height: 20),

        // ✅ الجملة اللي طلبتها
        const Text(
          'حدد إلى متى ترغب في استمرار هذه الجلسات المنتظمة:',
          style: TextStyle(fontSize: 15, fontFamily: 'NotoSansArabic'),
        ),
        const SizedBox(height: 8),

        const Text(
          '📅 مدة استمرار الجلسات',
          style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(
            endDate == null
                ? 'اختر تاريخ الانتهاء'
                : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF3E8),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              noEndDate
                  ? null
                  : () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
        ),
        CheckboxListTile(
          value: noEndDate,
          onChanged: (val) {
            setState(() {
              noEndDate = val ?? false;
              if (noEndDate) endDate = null;
            });
          },
          title: const Text('إلى إشعار آخر'),
        ),
      ],
    );
  }

  Widget _buildOneTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarSection(),
        const SizedBox(height: 20),
        _buildTimeSection(),
      ],
    );
  }

  Widget _buildNannyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الدوام:',
          style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic'),
        ),
        Row(
          children: [
            Radio(value: 'part', groupValue: null, onChanged: (val) {}),
            const Text('جزئي'),
            Radio(value: 'full', groupValue: null, onChanged: (val) {}),
            const Text('كامل'),
          ],
        ),
        const SizedBox(height: 10),
        _buildCalendarSection(),
        const SizedBox(height: 20),
        const Text(
          'حدد أوقات الرعاية خلال الأسبوع:',
          style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic'),
        ),
        Column(
          children: [
            CheckboxListTile(
              value: false,
              onChanged: (val) {},
              title: const Text('الصباح (قبل المدرسة)'),
            ),
            CheckboxListTile(
              value: false,
              onChanged: (val) {},
              title: const Text('الظهيرة'),
            ),
            CheckboxListTile(
              value: false,
              onChanged: (val) {},
              title: const Text('بعد المدرسة'),
            ),
            CheckboxListTile(
              value: false,
              onChanged: (val) {},
              title: const Text('المساء'),
            ),
            const Divider(),
            CheckboxListTile(
              value: false,
              onChanged: (val) {},
              title: const Text('نهاية الأسبوع - نهارًا'),
            ),
            CheckboxListTile(
              value: false,
              onChanged: (val) {},
              title: const Text('نهاية الأسبوع - مساءً'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📅 تاريخ بدء الجلسات',
          style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_month),
          label: Text(
            selectedDate == null
                ? 'اختر التاريخ'
                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF3E8),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => selectedDate = picked);
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🕒 وقت بدء الجلسة',
          style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.access_time),
          label: Text(
            selectedStartTime == null
                ? 'حدد وقت البدء'
                : selectedStartTime!.format(context),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF3E8),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) setState(() => selectedStartTime = picked);
          },
        ),
        const SizedBox(height: 20),
        const Text(
          '⏰ وقت انتهاء الجلسة',
          style: TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.access_time_outlined),
          label: Text(
            selectedEndTime == null
                ? 'حدد وقت الانتهاء'
                : selectedEndTime!.format(context),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF3E8),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) setState(() => selectedEndTime = picked);
          },
        ),
        const SizedBox(height: 16),
        if (getSessionDuration() != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFFF600A), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled, color: Color(0xFFFF600A)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getSessionDuration()!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        _buildFlexibleCheckbox(),
      ],
    );
  }

  Widget _buildExtraFields(String type) {
    if (type == 'regular') return _buildRegularFields();
    if (type == 'once') return _buildOneTimeFields();
    if (type == 'nanny') return _buildNannyFields();
    return const SizedBox();
  }

  Widget _buildFlexibleCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: flexibleTime,
          onChanged: (value) => setState(() => flexibleTime = value ?? false),
        ),
        const Text(
          'الوقت مرن ويمكن التنسيق لاحقًا',
          style: TextStyle(fontSize: 15, fontFamily: 'NotoSansArabic'),
        ),
      ],
    );
  }

  bool isFormValid() {
    if (selectedType == null) return false;

    if (!showExtraFields) return true;

    if (selectedType == 'regular') {
      return selectedDate != null &&
          selectedStartTime != null &&
          selectedEndTime != null &&
          (noEndDate || endDate != null) &&
          selectedDays.isNotEmpty;
    }

    if (selectedType == 'once') {
      return selectedDate != null &&
          selectedStartTime != null &&
          selectedEndTime != null;
    }

    if (selectedType == 'nanny') {
      return selectedDate !=
          null; // 👈 اضف هنا شروط التحقق لباقي الحقول إذا لزم
    }

    return false;
  }
}
