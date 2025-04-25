import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/WebViewPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPlanPage extends StatelessWidget {
  const SubscriptionPlanPage({super.key});

  void _openCheckout(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text(
            'اختر خطة الاشتراك',
            style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 21,
                  fontWeight: FontWeight.w700,),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'وفر على نفسك وابدأ الاشتراك الكامل:',
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '✔︎ وفر حتى 1175 شيكل بالسنة\n✔︎ احصل على خدمات موثوقة للعناية بطفلك\n✔︎ بدون التزام – يمكنك الإلغاء في أي وقت',
                style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildPlanTile(
                context,
                title: 'سنوي',
                newPrice: '₪ 13.95 / شهر',
                oldPrice: '₪ 39.95',
                discount: 'خصم 65%',
                planKey: 'annual',
              ),
              _buildPlanTile(
                context,
                title: 'ربع سنوي',
                newPrice: '₪ 25.95 / شهر',
                oldPrice: '₪ 39.95',
                discount: 'خصم 35%',
                planKey: 'quarterly',
              ),
              _buildPlanTile(
                context,
                title: 'شهري',
                newPrice: '₪ 39.95 / شهر',
                oldPrice: '',
                discount: '',
                planKey: 'monthly',
              ),
              const SizedBox(height: 20),
              const Text(
                '*يتم تجديد الاشتراك تلقائيًا حتى يتم إلغاؤه. لا توجد استرجاعات. قد تُطبق ضرائب محلية.',
                style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTile(BuildContext context, {
    required String title,
    required String newPrice,
    required String oldPrice,
    required String discount,
    required String planKey,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabic')),
                const Spacer(),
                if (discount.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(discount, style: const TextStyle(color: Colors.red, fontFamily: 'NotoSansArabic')),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(newPrice, style: const TextStyle(fontSize: 16, fontFamily: 'NotoSansArabic')),
                const SizedBox(width: 10),
                if (oldPrice.isNotEmpty)
                  Text(
                    oldPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  final url = await getCheckoutUrl(planKey);
                  if (context.mounted && url != null) _openCheckout(context, url);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF600A),
                ),
                child: const Text('اشترك الآن', style: TextStyle(fontFamily: 'NotoSansArabic', color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> getCheckoutUrl(String planType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return null;

    final response = await http.post(
      Uri.parse("http://10.0.2.2:3000/api/subscribe"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"plan": planType}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['url'];
    } else {
      print("❌ Failed to get checkout URL: ${response.body}");
      return null;
    }
  }
}
