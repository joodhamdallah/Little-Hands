import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart';

class UploadExpertPostPage extends StatefulWidget {
  const UploadExpertPostPage({super.key});

  @override
  State<UploadExpertPostPage> createState() => _UploadExpertPostPageState();
}

class _UploadExpertPostPageState extends State<UploadExpertPostPage> {
  File? _pdfFile;
  File? _imageFile;
  bool _isUploading = false;
  final Color orange = const Color(0xFFFF600A);

  Future<void> _pickPdfFile() async {
    final file = await openFile(acceptedTypeGroups: [
      XTypeGroup(label: 'PDF', extensions: ['pdf'])
    ]);
    if (file != null) {
      setState(() => _pdfFile = File(file.path));
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _uploadPost() async {
    if (_pdfFile == null) return;

    setState(() => _isUploading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final uri = Uri.parse('${baseUrl}/api/expert-posts/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('pdf', _pdfFile!.path));
    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    setState(() => _isUploading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم رفع النصيحة بنجاح')),
      );
      setState(() {
        _pdfFile = null;
        _imageFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الرفع: ${result.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.upload_file, size: 64, color: Colors.orange),
            const SizedBox(height: 10),
            const Text(
              '  📌يمكنك رفع أي ملف : يحتوي على بحث او نصيحة ونسقوم بتحويله الى بطاقة نصيحة مختصرة تظهر للآباء ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NotoSansArabic',
              ),
            ),
            const SizedBox(height: 25),

            // PDF Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _pickPdfFile,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('اختيار ملف PDF',
                  style: TextStyle(fontFamily: 'NotoSansArabic')),
            ),
            if (_pdfFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '📄 تم اختيار: ${_pdfFile!.path.split('/').last}',
                  style: const TextStyle(fontSize: 14, fontFamily: 'NotoSansArabic'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 16),

            // Image Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('اختيار صورة للبطاقة',
                  style: TextStyle(fontFamily: 'NotoSansArabic')),
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '🖼 تم اختيار: ${_imageFile!.path.split('/').last}',
                  style: const TextStyle(fontSize: 14, fontFamily: 'NotoSansArabic'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isUploading ? null : _uploadPost,
              icon: const Icon(Icons.send),
              label: _isUploading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('رفع النصيحة',
                      style: TextStyle(fontFamily: 'NotoSansArabic')),
            ),
          ],
        ),
      ),
    );
  }
}
