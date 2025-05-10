import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Services/Babysitter/babysitter_requirments_parent5.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class BabysitterRateRangePage extends StatefulWidget {
  final Map<String, dynamic> previousData;
  const BabysitterRateRangePage({super.key, required this.previousData});

  @override
  State<BabysitterRateRangePage> createState() =>
      _BabysitterRateRangePageState();
}

class _BabysitterRateRangePageState extends State<BabysitterRateRangePage> {
  double minRate = 20;
  double maxRate = 30;
  String rateOption = 'range';

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
            'تحديد ميزانية الجلسة',
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(
                  value: 0.85,
                  backgroundColor: Colors.grey,
                  color: Color(0xFFFF600A),
                  minHeight: 6,
                ),
                const SizedBox(height: 24),
                const Text(
                  'ما هو نطاق السعر الذي ترغب في دفعه؟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تُفضّل الجليسات العروض التي تقدم أجرًا عادلًا ومناسبًا في منطقتك. اختر نطاقًا يعكس تقديرك للخدمة.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 30),
                RadioListTile<String>(
                  value: 'range',
                  groupValue: rateOption,
                  activeColor: const Color(0xFFFF600A),
                  title: const Text(
                    'أحدد نطاق السعر الذي أفضّله',
                    style: TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                  onChanged: (value) {
                    setState(() => rateOption = value!);
                  },
                ),
                if (rateOption == 'range') ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '₪ ${minRate.toInt()} - ${maxRate.toInt()} / ساعة',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FlutterSlider(
                    values: [minRate, maxRate],
                    max: 100,
                    min: 0,
                    rangeSlider: true,
                    step: const FlutterSliderStep(step: 1),
                    tooltip: FlutterSliderTooltip(
                      alwaysShowTooltip: true,
                      format: (value) => '₪ $value',
                      textStyle: const TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 14,
                      ),
                    ),
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        minRate = lowerValue;
                        maxRate = upperValue;
                      });
                    },
                    handler: FlutterSliderHandler(
                      decoration: const BoxDecoration(),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xFFFF600A),
                      ),
                    ),
                    rightHandler: FlutterSliderHandler(
                      decoration: const BoxDecoration(),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xFFFF600A),
                      ),
                    ),
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBarHeight: 4,
                      inactiveTrackBarHeight: 4,
                      activeTrackBar: BoxDecoration(
                        color: const Color(0xFFFF600A),
                      ),
                      inactiveTrackBar: BoxDecoration(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
                RadioListTile<String>(
                  value: 'negotiable',
                  groupValue: rateOption,
                  activeColor: const Color(0xFFFF600A),
                  title: const Text(
                    'أفضل التفاوض مع الجليسة بشأن الأجر لاحقًا',
                    style: TextStyle(fontFamily: 'NotoSansArabic'),
                  ),
                  onChanged: (value) {
                    setState(() => rateOption = value!);
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedJobDetails = {
                        ...widget.previousData,
                        if (rateOption == 'range') 'rate_min': minRate.toInt(),
                        if (rateOption == 'range') 'rate_max': maxRate.toInt(),
                        'is_negotiable': rateOption == 'negotiable',
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ParentOtherRequirementsPage(
                                previousData: updatedJobDetails,
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
      ),
    );
  }
}
