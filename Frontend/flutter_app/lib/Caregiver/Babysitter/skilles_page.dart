import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Babysitter/bio_page.dart';

class BabySitterSkillsPage extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const BabySitterSkillsPage({super.key, required this.previousData});

  @override
  State<BabySitterSkillsPage> createState() => _BabySitterSkillsPageState();
}


class _BabySitterSkillsPageState extends State<BabySitterSkillsPage> {
  final List<Map<String, dynamic>> skills = [
    {'label': 'تمتلك سيارة', 'icon': Icons.directions_car, 'selected': false},
    {'label': 'تنظيف المنزل', 'icon': Icons.cleaning_services, 'selected': false},
    {'label': 'توصيل الأطفال', 'icon': Icons.child_care, 'selected': false},
    {'label': 'شراء الحاجيات', 'icon': Icons.shopping_bag, 'selected': false},
    {'label': 'مساعدة في الواجبات', 'icon': Icons.edit_note, 'selected': false},
    {'label': 'غسيل الملابس', 'icon': Icons.local_laundry_service, 'selected': false},
    {'label': 'تحضير الوجبات', 'icon': Icons.restaurant_menu, 'selected': false},
    {'label': 'تدريب على استخدام المرحاض', 'icon': Icons.wc, 'selected': false},
    {'label': 'رعاية المرضى', 'icon': Icons.healing, 'selected': false},
    {'label': 'رعاية التوائم', 'icon': Icons.group, 'selected': false},
  ];

  List<String> getSelectedSkills() {
    return skills.where((skill) => skill['selected'] == true).map((s) => s['label'] as String).toList();
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'هل هناك خدمات إضافية يمكنكِ تقديمها؟',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: skills.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemBuilder: (context, index) {
                    final skill = skills[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          skill['selected'] = !skill['selected'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: skill['selected'] ? const Color(0xFFFFE3D3) : Colors.white,
                          border: Border.all(
                            color: skill['selected'] ? const Color(0xFFFF600A) : Colors.black26,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(skill['icon'], size: 28, color: Colors.black54),
                            const SizedBox(height: 8),
                            Text(
                              skill['label'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final selectedSkills = getSelectedSkills();

                       Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BabySitterBioPage(
                                previousData: {
                                  ...widget.previousData,
                                  'skills': selectedSkills,
                                },
                              ),
                            ),
                          );


                  },
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
    );
  }
}
