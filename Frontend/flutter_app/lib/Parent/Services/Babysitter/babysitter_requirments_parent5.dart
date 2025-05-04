import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_summary_parent6.dart';

class ParentOtherRequirementsPage extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const ParentOtherRequirementsPage({super.key, required this.previousData});

  @override
  State<ParentOtherRequirementsPage> createState() =>
      _ParentOtherRequirementsPageState();
}

class _ParentOtherRequirementsPageState
    extends State<ParentOtherRequirementsPage> {
  final List<String> selectedItems = [];

  final Map<String, List<Map<String, dynamic>>> sections = {
    'متطلبات إضافية': [
      {'label': 'تمتلك سيارة', 'icon': Icons.directions_car},
      {'label': 'رعاية التوائم', 'icon': Icons.group},
      {'label': 'تتحدث لغات متعددة', 'icon': Icons.language},
      {'label': 'غير مدخنة', 'icon': Icons.smoke_free},
    ],
    'المسؤوليات': [
      {'label': 'توصيل الأطفال', 'icon': Icons.child_care},
      {'label': 'مساعدة في الواجبات', 'icon': Icons.edit_note},
      {'label': 'تحضير الوجبات', 'icon': Icons.lunch_dining},
      {'label': 'رعاية المرضى', 'icon': Icons.healing},
      {'label': 'تدريب على استخدام المرحاض', 'icon': Icons.wc},
      {'label': 'تنظيف المنزل', 'icon': Icons.cleaning_services},
      {'label': 'غسيل الملابس', 'icon': Icons.local_laundry_service},
      {'label': 'شراء الحاجيات', 'icon': Icons.shopping_bag},
    ],
  };

  void toggleSelection(String label) {
    setState(() {
      selectedItems.contains(label)
          ? selectedItems.remove(label)
          : selectedItems.add(label);
    });
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
          title: const Text(
            'المهام والمتطلبات الإضافية',
            style: TextStyle(fontFamily: 'NotoSansArabic'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LinearProgressIndicator(
                value: 0.95,
                backgroundColor: Colors.grey,
                color: Color(0xFFFF600A),
                minHeight: 6,
              ),
              const SizedBox(height: 24),
              const Text(
                'هل هناك متطلبات أو مهام إضافية تريد من الجليسة معرفتها؟',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Color(0xFFFFF3E8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  side: BorderSide(color: Color(0xFFFFCBA4)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFFF600A)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'بعض المسؤوليات والمتطلبات الإضافية  تؤثر على السعر النهائي للجلسة، وسيتم تحديد ذلك لاحقًا بالتفاهم مع الجليسة.',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'NotoSansArabic',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children:
                      sections.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.start,
                              children:
                                  entry.value.map((item) {
                                    final isSelected = selectedItems.contains(
                                      item['label'],
                                    );
                                    return GestureDetector(
                                      onTap:
                                          () => toggleSelection(item['label']),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2 -
                                            30,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? const Color(0xFFFFF3E8)
                                                  : Colors.grey[100],
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? const Color(0xFFFF600A)
                                                    : Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              item['icon'],
                                              size: 26,
                                              color:
                                                  isSelected
                                                      ? const Color(0xFFFF600A)
                                                      : Colors.grey,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item['label'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'NotoSansArabic',
                                                color:
                                                    isSelected
                                                        ? const Color(
                                                          0xFFFF600A,
                                                        )
                                                        : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      }).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final updatedJobDetails = {
                      ...widget.previousData,
                      'additional_requirements': selectedItems,
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BabysitterSummaryPage(
                              jobDetails: updatedJobDetails,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
                      fontWeight: FontWeight.bold,
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
}
