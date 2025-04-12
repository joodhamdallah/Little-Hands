import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class IDVerificationPage extends StatefulWidget {
  const IDVerificationPage({super.key});

  @override
  _IDVerificationPageState createState() => _IDVerificationPageState();
}

class _IDVerificationPageState extends State<IDVerificationPage> {
  File? _idImage;
  File? _selfieImage;
  final picker = ImagePicker();
  String resultMessage = '';
  bool isLoading = false;

  // ضغط الصورة
Future<File?> compressImage(File file) async {
  final dir = await getTemporaryDirectory();
  final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  final XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 60,
  );

  if (result == null) return null;

  return File(result.path); 
}


  Future pickImage(bool isID) async {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 160,
        child: Column(
          children: [
            Text("اختر مصدر الصورة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("التقاط بالكاميرا"),
              onTap: () async {
                Navigator.pop(context);
                await _getImage(ImageSource.camera, isID);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("الاختيار من المعرض"),
              onTap: () async {
                Navigator.pop(context);
                await _getImage(ImageSource.gallery, isID);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future _getImage(ImageSource source, bool isID) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File original = File(pickedFile.path);
      File? compressed = await compressImage(original);
      setState(() {
        if (isID) {
          _idImage = compressed;
        } else {
          _selfieImage = compressed;
        }
      });
    }
  }

  // إرسال الصور والتحقق
  Future verifyIdentity() async {
    if (_idImage == null || _selfieImage == null) {
      setState(() => resultMessage = "يرجى تحميل صورة الهوية والسيلفي.");
      return;
    }

    setState(() {
      isLoading = true;
      resultMessage = '';
    });

    try {
      final idBase64 = base64Encode(await _idImage!.readAsBytes());
      final selfieBase64 = base64Encode(await _selfieImage!.readAsBytes());

      final response = await http.post(
        Uri.parse('http://192.168.0.101:3000/api/verify-id'), // ← ضع IP سيرفرك هنا
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'idImage': idBase64,
          'selfieImage': selfieBase64,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          resultMessage = "✅ تم التحقق: ${data['name']} (الهوية: ${data['idNumber']})";
        });
      } else {
        try {
          final error = jsonDecode(response.body);
          setState(() {
            resultMessage = "❌ فشل: ${error['reason'] ?? error['error']}";
          });
        } catch (e) {
          setState(() {
            resultMessage = "❌ خطأ غير متوقع: ${response.body}";
          });
        }
      }
    } catch (e) {
      setState(() {
        resultMessage = "❌ تعذر الاتصال بالسيرفر. تحقق من الشبكة.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // تصميم الواجهة
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('التحقق من الهوية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => pickImage(true),
              child: Text('📄 تحميل صورة الهوية'),
            ),
            if (_idImage != null) Image.file(_idImage!, height: 100),

            ElevatedButton(
              onPressed: () => pickImage(false),
              child: Text('🤳 تحميل صورة السيلفي'),
            ),
            if (_selfieImage != null) Image.file(_selfieImage!, height: 100),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyIdentity,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('بدء التحقق'),
            ),
            const SizedBox(height: 20),
            Text(resultMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
