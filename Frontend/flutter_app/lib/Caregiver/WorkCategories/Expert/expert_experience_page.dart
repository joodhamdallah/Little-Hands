import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Expert/expert_provider.dart';

class ExpertExperiencePage extends StatefulWidget {
  const ExpertExperiencePage({super.key});

  @override
  State<ExpertExperiencePage> createState() => _ExpertExperiencePageState();
}

class _ExpertExperiencePageState extends State<ExpertExperiencePage> {
  int yearsOfExperience = 0;
  List<String> selectedSessionTypes = [];
  String? deliveryMethod;
  List<String> selectedAges = [];

  final List<String> sessionOptions = [
    'تقييم',
    'متابعة',
    'خطة علاجية',
    'استشارة أسرية',
    'جلسات فردية مع الطفل',
    'أخرى',
  ];

  final List<Map<String, String>> sessionModes = [
    {
      'label': 'حضوري فقط',
      'description': 'اللقاء يتم وجهًا لوجه في المركز أو المكان المخصص.',
    },
    {
      'label': 'عن بُعد فقط',
      'description': 'الجلسات تتم عبر مكالمات فيديو أو صوت من خلال الإنترنت.',
    },
    {
      'label': 'كلاهما',
      'description': 'يمكن تقديم الجلسات إما حضوريًا أو عن بُعد حسب رغبة الأهل.',
    },
  ];

  final List<String> ageGroups = [
    'أطفال ما قبل المدرسة',
    'أطفال في سن المدرسة',
    'مراهقون',
  ];

  Widget buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(color: Colors.black12, thickness: 1),
      );

  bool isFormValid() {
    return selectedSessionTypes.isNotEmpty &&
        deliveryMethod != null &&
        selectedAges.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final selectedMode = sessionModes.firstWhere(
      (element) => element['label'] == deliveryMethod,
      orElse: () => {'description': ''},
    );

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'كم سنة من الخبرة لديك في تقديم الجلسات الاستشارية أو العلاجية؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF600A), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                      onPressed: () {
                        if (yearsOfExperience > 0) {
                          setState(() => yearsOfExperience--);
                        }
                      },
                    ),
                    Text(
                      '$yearsOfExperience سنوات',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF007A)),
                      onPressed: () => setState(() => yearsOfExperience++),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              buildDivider(),
              const SizedBox(height: 32),
              const Text(
                'ما نوع الجلسات التي تقدمها؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: sessionOptions.map((option) {
                  final isSelected = selectedSessionTypes.contains(option);
                  return ChoiceChip(
                    label: Text(option, style: const TextStyle(fontFamily: 'NotoSansArabic')),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFE3D3),
                    backgroundColor: Colors.grey[100],
                    side: const BorderSide(color: Color(0xFFFF600A)),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedSessionTypes.add(option);
                        } else {
                          selectedSessionTypes.remove(option);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              buildDivider(),
              const SizedBox(height: 32),
              const Text(
                'هل تقدم الجلسات حضوريًا أم عن بُعد؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                value: deliveryMethod,
                hint: const Text('حدد طريقة التقديم'),
                items: sessionModes.map((option) {
                  return DropdownMenuItem(
                    value: option['label'],
                    child: Text(option['label']!, style: const TextStyle(fontFamily: 'NotoSansArabic')),
                  );
                }).toList(),
                onChanged: (value) => setState(() => deliveryMethod = value),
              ),
              if (deliveryMethod != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    selectedMode['description'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              buildDivider(),
              const SizedBox(height: 32),
              const Text(
                'ما الفئات العمرية التي تتعامل معها؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ageGroups.map((group) {
                  final isSelected = selectedAges.contains(group);
                  return ChoiceChip(
                    label: Text(group, style: const TextStyle(fontFamily: 'NotoSansArabic')),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFE3D3),
                    backgroundColor: Colors.grey[100],
                    side: const BorderSide(color: Color(0xFFFF600A)),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedAges.add(group);
                        } else {
                          selectedAges.remove(group);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isFormValid()
                      ? () {
                          final provider = Provider.of<ExpertProvider>(context, listen: false);
                          provider.setExperienceDetails(
                            yearsOfExperience: yearsOfExperience,
                            sessionTypes: selectedSessionTypes,
                            deliveryMethod: deliveryMethod!,
                            ageGroups: selectedAges,
                          );
                          Navigator.pushNamed(context, '/expertBioQ5');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF600A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            ],
          ),
        ),
      ),
    );
  }
}
