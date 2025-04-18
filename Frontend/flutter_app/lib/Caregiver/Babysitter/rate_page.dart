import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BabySitterRatePage extends StatefulWidget {
  final Map<String, dynamic> previousData;

  const BabySitterRatePage({super.key, required this.previousData});

  @override
  State<BabySitterRatePage> createState() => _BabySitterRatePageState();
}

class _BabySitterRatePageState extends State<BabySitterRatePage> {
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();
  int numberOfChildren = 1;
  bool? isSmoker;
  bool isLoading = false;

  @override
  void dispose() {
    _minRateController.dispose();
    _maxRateController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'NotoSansArabic')),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _handleSubmit() async {
    final min = int.tryParse(_minRateController.text);
    final max = int.tryParse(_maxRateController.text);

    if (min == null || max == null || min > max || isSmoker == null) {
      _showError("يرجى التأكد من صحة البيانات المدخلة.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null) {
        _showError("يرجى تسجيل الدخول أولاً.");
        return;
      }

      final Map<String, dynamic> fullData = {
        ...widget.previousData,
        "city": widget.previousData['selectedCity'],  
        "training_certification": widget.previousData['certifications'], 
        "skills_and_services": widget.previousData['skills'], 
        "rate_per_hour": {"min": min, "max": max},
        "number_of_children": numberOfChildren,
        "is_smoker": isSmoker,
      };
          fullData.remove("selectedCity");
          fullData.remove("certifications");
          fullData.remove("skills");
          fullData.remove("selectedCity");

// print("📦 Full Data Sent: ${jsonEncode(fullData)}"); 

      final response = await http.post(
        Uri.parse(babysitterDetails),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(fullData),
      );

      // print("📥 Status Code: ${response.statusCode}");
      // print("📥 Response Body: ${response.body}");


      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حفظ بياناتك بنجاح 🎉"),
            backgroundColor: Colors.green,
          ),
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/idverifyapi');
      } else {
        final json = jsonDecode(response.body);
        _showError(json["message"] ?? "فشل في حفظ البيانات.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError("حدث خطأ أثناء حفظ البيانات.");
    }
  }

  Widget buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 0),
    child: Divider(color: Colors.black12, thickness: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFFFF600A),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حددي أجركِ لكل ساعة',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'أجركِ بالساعة لطفل واحد. يمكنكِ تحديثه لاحقًا في أي وقت.',
                      style: TextStyle(fontSize: 14, fontFamily: 'NotoSansArabic', color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('💡 متوسط أجور المربيات المشابهات لكِ:', style: TextStyle(fontSize: 14, fontFamily: 'NotoSansArabic')),
                          Text('₪ 24 - 30 / ساعة', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minRateController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الحد الأدنى',
                              labelStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('إلى', style: TextStyle(fontFamily: 'NotoSansArabic')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxRateController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الحد الأعلى',
                              labelStyle: const TextStyle(fontFamily: 'NotoSansArabic'),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    buildDivider(),
                    const SizedBox(height: 32),
                    const Text(
                      'عدد الأطفال الذين يمكنكِ العناية بهم:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (numberOfChildren > 1) {
                              setState(() => numberOfChildren--);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                          iconSize: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Text(
                                '$numberOfChildren',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic'),
                              ),
                              const SizedBox(height: 4),
                              const Text('طفل', style: TextStyle(fontSize: 14, fontFamily: 'NotoSansArabic')),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => numberOfChildren++);
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF007A)),
                          iconSize: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    buildDivider(),
                    const SizedBox(height: 32),
                    const Text(
                      'هل أنتِ مدخنة؟',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Row(
                            children: [
                              Text('نعم', style: TextStyle(fontFamily: 'NotoSansArabic')),
                              SizedBox(width: 6),
                              Text('😞'),
                            ],
                          ),
                          selected: isSmoker == true,
                          onSelected: (_) => setState(() => isSmoker = true),
                          selectedColor: const Color(0xFFFFE3D3),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Row(
                            children: [
                              Text('لا', style: TextStyle(fontFamily: 'NotoSansArabic')),
                              SizedBox(width: 6),
                              Text('😊'),
                            ],
                          ),
                          selected: isSmoker == false,
                          onSelected: (_) => setState(() => isSmoker = false),
                          selectedColor: const Color(0xFFFFE3D3),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF600A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'التالي',
                                style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'NotoSansArabic'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
