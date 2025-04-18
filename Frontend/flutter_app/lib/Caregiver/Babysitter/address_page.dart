import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Babysitter/skilles_page.dart';

class BabySitterCityPage extends StatefulWidget {
  const BabySitterCityPage({super.key});

  @override
  State<BabySitterCityPage> createState() => _BabySitterCityPageState();
}

class _BabySitterCityPageState extends State<BabySitterCityPage> {
  String? selectedCity;
  int yearsOfExperience = 0;
  bool hasFirstAid = false;
  bool hasCPR = false;

  late List<String> ageExperience = [];

  final List<String> cities = [
    "طولكرم",
    "نابلس",
    "جنين",
    "رام الله",
    "الخليل",
    "غزة",
    "بيت لحم",
  ];

  Widget buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(color: Colors.black12, thickness: 1),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('age_experience')) {
      ageExperience = List<String>.from(args['age_experience']);
    }
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ما المدينة التي ترغبين بالعمل فيها؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF600A), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCity,
                      hint: const Text(
                        'اختر المدينة',
                        style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFFF600A)),
                      items: cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: const TextStyle(
                              fontFamily: 'NotoSansArabic',
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              buildDivider(),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'كم عدد سنوات الخبرة المدفوعة لديكِ في رعاية الأطفال؟',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF600A), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
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
                            setState(() {
                              yearsOfExperience--;
                            });
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
                        onPressed: () {
                          setState(() {
                            yearsOfExperience++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              buildDivider(),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'هل لديكِ أي تدريبات أو شهادات؟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => hasFirstAid = !hasFirstAid),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: hasFirstAid ? const Color(0xFFFFE3D3) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasFirstAid ? const Color(0xFFFF600A) : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.medical_services_outlined, size: 36, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('الإسعافات الأولية', style: TextStyle(fontSize: 14, fontFamily: 'NotoSansArabic')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => hasCPR = !hasCPR),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: hasCPR ? const Color(0xFFFFE3D3) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasCPR ? const Color(0xFFFF600A) : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.favorite_border, size: 36, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('CPR الإنعاش القلبي', style: TextStyle(fontSize: 14, fontFamily: 'NotoSansArabic')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: selectedCity != null
                        ? () {
                            final training = <String>[];
                            if (hasFirstAid) training.add('First Aid');
                            if (hasCPR) training.add('CPR');

                         Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BabySitterSkillsPage(
                                  selectedCity: selectedCity!,
                                  years_experience: yearsOfExperience,
                                  certifications: [
                                    if (hasFirstAid) 'First Aid',
                                    if (hasCPR) 'CPR',
                                  ],
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
          ),
        ),
      ),
    );
  }
}
