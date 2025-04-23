import 'package:flutter/material.dart';

class BabysitterTypeSelectionPage extends StatefulWidget {
  const BabysitterTypeSelectionPage({super.key});

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
          'جليسة تُطلب لمناسبة واحدة أو حالة طارئة، مثل حفلة أو موعد في المستشفى أو سفر ليوم واحد.',
      'icon': Icons.event,
    },
    {
      'value': 'occasional',
      'title': 'جليسة حسب الحاجة',
      'subtitle':
          'جليسة يمكن طلبها عند الحاجة فقط، دون مواعيد محددة أو جدول منتظم، بناءً على الظروف.',
      'icon': Icons.access_time,
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
          title: const Text('نوع جليسة الأطفال'),
          backgroundColor: const Color(0xFFFF600A),
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
                'اختر نوع جليسة الأطفال التي تحتاجها لطفلك:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 20),

              if (!showExtraFields)
                ...sessionTypes.map((type) => _buildTypeCard(type)).toList(),

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
                      selectedType != null
                          ? () {
                            if (showExtraFields) {
                              Navigator.pushNamed(
                                context,
                                '/parentBabysitterSummary',
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
            final days = [
              'الأحد',
              'الاثنين',
              'الثلاثاء',
              'الأربعاء',
              'الخميس',
              'الجمعة',
              'السبت',
            ];
            return FilterChip(
              label: Text(days[index]),
              selected: false,
              onSelected: (val) {},
            );
          }),
        ),
        const SizedBox(height: 20),
        _buildTimeSection(),
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

  Widget _buildOccasionalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarSection(),
        const SizedBox(height: 10),
        _buildFlexibleCheckbox(),
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
          '📅 التاريخ المتوقع للجلسة',
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
        _buildFlexibleCheckbox(),
      ],
    );
  }

  Widget _buildExtraFields(String type) {
    if (type == 'regular') return _buildRegularFields();
    if (type == 'once') return _buildOneTimeFields();
    if (type == 'occasional') return _buildOccasionalFields();
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
}
