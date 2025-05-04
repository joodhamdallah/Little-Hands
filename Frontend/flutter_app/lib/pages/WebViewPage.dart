import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Caregiver/Home/caregiver_home_page.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          setState(() => _isLoading = false);

          if (url.contains('/success') || url.contains('success')) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 مرحبًا بك في موقعنا'),
                  backgroundColor: Colors.green,
                ),
              );

              await Future.delayed(const Duration(seconds: 2));

              if (mounted) {
                await navigateToHomeAfterPayment();
              }
            }
          }
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> navigateToHomeAfterPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('❌ Token not found');
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/caregiver/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final profile = CaregiverProfileModel.fromJson(data['profile']);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => CaregiverHomePage(profile: profile),
        ),
        (route) => false,
      );
    } else {
      print('❌ Failed to fetch profile: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF600A),
          title: const Text(
            'إتمام الدفع',
            style: TextStyle(
              fontFamily: 'NotoSansArabic',
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF600A)),
              ),
          ],
        ),
      ),
    );
  }
}
