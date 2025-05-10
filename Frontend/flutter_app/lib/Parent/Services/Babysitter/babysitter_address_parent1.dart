import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_type_parent2.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_summary_parent6.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BabysitterSessionAddressPage extends StatefulWidget {
  final Map<String, dynamic>? previousData;
  final bool isEditing;

  const BabysitterSessionAddressPage({
    super.key,
    this.previousData,
    this.isEditing = false,
  });

  @override
  State<BabysitterSessionAddressPage> createState() =>
      _BabysitterSessionAddressPageState();
}

class _BabysitterSessionAddressPageState
    extends State<BabysitterSessionAddressPage> {
  LatLng? selectedLatLng;
  LatLng? parentLatLng;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  late final MapController _mapController = MapController();

  String parentAddress = "جارٍ التحميل...";
  String? parentCity;
  String? selectedCity;

  final List<String> cities = [
    "طولكرم",
    "نابلس",
    "جنين",
    "رام الله",
    "الخليل",
    "غزة",
    "بيت لحم",
  ];

  @override
  void initState() {
    super.initState();
    _fetchParentProfile();
    if (widget.previousData != null) {
      selectedCity = widget.previousData!['city'];
      neighborhoodController.text = widget.previousData!['location_note'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تفاصيل جلسة جليسة الأطفال',
            style: TextStyle(color: Colors.black, fontFamily: 'NotoSansArabic'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: 0.2,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFFFF600A),
                minHeight: 6,
              ),
              const SizedBox(height: 24),

              const Text(
                'حدد مكان الجلسة على الخريطة:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabic',
                ),
              ),
              const SizedBox(height: 12),

              if (parentLatLng != null && parentAddress != "جارٍ التحميل...")
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedLatLng = parentLatLng;
                    });
                    _mapController.move(parentLatLng!, 15.0);
                  },
                  icon: const Icon(Icons.home, color: Color(0xFFFF600A)),
                  label: Text(
                    'هل تريد استخدام عنوان منزلك؟ ($parentCity - $parentAddress)',
                    style: const TextStyle(
                      color: Color(0xFFFF600A),
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCity,
                items:
                    cities
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCity = val;
                  });
                  if (val != null) {
                    _searchLocation(val);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'اختر المدينة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'اكتب اسم الحي أو المنطقة للبحث على الخريطة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _searchLocation(searchController.text),
                      icon: const Icon(Icons.search),
                      label: const Text('ابحث'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF600A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF600A)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: selectedLatLng ?? LatLng(31.9, 35.2),
                    zoom: 18,
                    onTap: (_, point) {
                      setState(() => selectedLatLng = point);
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
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: neighborhoodController,
                decoration: const InputDecoration(
                  hintText: 'وصف إضافي (اسم الحي، معلم قريب...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _canProceed() ? _onNextPressed : null,
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

  void _fetchParentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(fetchParent),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parentData = jsonDecode(response.body)['data'];

        setState(() {
          parentAddress = parentData['address'] ?? "لم يتم العثور على العنوان";
          parentCity = parentData['city'] ?? "";
          if (parentData['location'] != null) {
            parentLatLng = LatLng(
              parentData['location']['lat'],
              parentData['location']['lng'],
            );
          }
        });
      }
    } catch (e) {
      print('Error fetching parent profile: $e');
    }
  }

  void _onNextPressed() {
    final updatedJobDetails = {
      ...?widget.previousData,
      'city': selectedCity,
      'location':
          selectedLatLng != null
              ? {
                'lat': selectedLatLng!.latitude,
                'lng': selectedLatLng!.longitude,
              }
              : null,
      'location_note': neighborhoodController.text.trim(),
    };

    if (widget.isEditing) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => BabysitterSummaryPage(jobDetails: updatedJobDetails),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  BabysitterTypeSelectionPage(previousData: updatedJobDetails),
        ),
      );
    }
  }

  bool _canProceed() {
    return selectedCity != null && selectedLatLng != null;
  }

  Future<void> _searchLocation(String placeName) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${placeName.trim()},West Bank&format=json&limit=1',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'LittleHandsApp/1.0'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        final newPoint = LatLng(lat, lon);
        setState(() => selectedLatLng = newPoint);
        _mapController.move(newPoint, 15.0);
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
