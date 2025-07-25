import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/WorkCategories/Babysitter/skilles_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BabySitterCityPage extends StatefulWidget {
  const BabySitterCityPage({super.key});

  @override
  State<BabySitterCityPage> createState() => _BabySitterCityPageState();
}

class _BabySitterCityPageState extends State<BabySitterCityPage> {
  String? selectedCity;

  LatLng? selectedLatLng;
  TextEditingController searchController = TextEditingController();
  late final MapController _mapController = MapController();

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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF600A),
                      width: 1.5,
                    ),
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
                        style: TextStyle(
                          fontFamily: 'NotoSansArabic',
                          fontSize: 16,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFFFF600A),
                      ),
                      items:
                          cities.map((city) {
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
              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'حددي موقعك على الخريطة',
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
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'اكتبي اسم المنطقة',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed:
                          () => searchLocationByName(searchController.text),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFF600A), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FlutterMap(
                  mapController: _mapController,

                  options: MapOptions(
                    center: selectedLatLng ?? LatLng(31.9, 35.2),
                    zoom: 10,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLatLng = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (selectedLatLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLatLng!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              buildDivider(),
              const SizedBox(height: 10),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF600A),
                      width: 1.5,
                    ),
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
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                        ),
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
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFFFF007A),
                        ),
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
                            color:
                                hasFirstAid
                                    ? const Color(0xFFFFE3D3)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  hasFirstAid
                                      ? const Color(0xFFFF600A)
                                      : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 36,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'الإسعافات الأولية',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
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
                            color:
                                hasCPR ? const Color(0xFFFFE3D3) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  hasCPR
                                      ? const Color(0xFFFF600A)
                                      : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 36,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'CPR الإنعاش القلبي',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'NotoSansArabic',
                                ),
                              ),
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
                    onPressed:
                        selectedCity != null && selectedLatLng != null
                            ? () {
                              final training = <String>[];
                              if (hasFirstAid) training.add('First Aid');
                              if (hasCPR) training.add('CPR');

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BabySitterSkillsPage(
                                        previousData: {
                                          'age_experience': ageExperience,
                                          'selectedCity': selectedCity!,
                                          'years_experience': yearsOfExperience,
                                          'certifications': training,
                                          'location': {
                                            'lat': selectedLatLng!.latitude,
                                            'lng': selectedLatLng!.longitude,
                                          },
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
          ),
        ),
      ),
    );
  }

  Future<void> searchLocationByName(String placeName) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$placeName&format=json&limit=1',
    );
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'LittleHandsApp/1.0', // Required by Nominatim
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          selectedLatLng = LatLng(lat, lon);
        });
        _mapController.move(selectedLatLng!, 16); // zoom level 15
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على الموقع')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء البحث')));
    }
  }
}
