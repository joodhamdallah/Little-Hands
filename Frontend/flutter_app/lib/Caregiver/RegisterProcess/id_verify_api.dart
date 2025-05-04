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
  int _currentStep = 0;
  final Color mainOrange = const Color(0xFFFF600A);
  final Color lightOrange = const Color(0xFFFF7F36);
  final Color darkOrange = const Color(0xFFD45000);

  File? _idImage;
  File? _selfieImage;
  final picker = ImagePicker();
  String resultMessage = '';
  bool isLoading = false;

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );
    return result != null ? File(result.path) : null;
  }

  Future pickImage(bool isID) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Container(
            padding: const EdgeInsets.all(16),
            height: 180,
            child: Column(
              children: [
                const Text(
                  "اختر مصدر الصورة",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("التقاط بالكاميرا"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImage(ImageSource.camera, isID);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("الاختيار من المعرض"),
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
        Uri.parse('http://10.0.2.2:3000/api/verify-id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'idImage': idBase64, 'selfieImage': selfieBase64}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fullName = data['fullName'] ?? 'غير معروف';
        final idNumber = data['idNumber'] ?? 'غير متوفر';
        final faceConfidence = data['faceMatchConfidence'];
        final decision = data['decision'] ?? 'unknown';
        final warnings = data['warnings'] ?? [];
        final bool isUnder18 = warnings.any((w) => w['code'] == 'UNDER_18');
        final age = data['age'] ?? 'غير معروف';

        setState(() {
          if (isUnder18) {
            resultMessage =
                "⚠️ لا يمكننا قبول المستخدمين دون سن 18 عامًا.\nالعمر: ${age ?? 'غير معروف'}\nالاسم: $fullName\nرقم الهوية: $idNumber";
          } else if (decision == "reject" ||
              faceConfidence == null ||
              faceConfidence < 0.3) {
            resultMessage =
                "❌ تعذر التحقق من هويتك بسبب عدم تطابق الوجه بين صورة الهوية وصورة السيلفي.\nالاسم: $fullName\nرقم الهوية: $idNumber";
          } else if (decision == "review") {
            resultMessage =
                "🟡 تم التحقق جزئياً (تحتاج لمراجعة).\nالاسم: $fullName\nرقم الهوية: $idNumber";
          } else {
            resultMessage =
                "✅ تم التحقق بنجاح!\nالاسم: $fullName\nرقم الهوية: $idNumber";
          }
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          resultMessage = "❌ فشل: ${error['reason'] ?? error['error']}";
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = "❌ تعذر الاتصال بالسيرفر. تحقق من الشبكة.";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildInstructionsStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFFFF600A), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'بطاقة هوية حكومية: هوية شخصية أو جواز سفر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFFFF600A), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'هاتف ذكي: لمسح الهوية والتقاط سيلفي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Text(
                '*صورتك تستخدم فقط للتحقق، ولن يتم استخدامها أو مشاركتها مع أي جهة أخرى.نحترم خصوصيتك ونعالج معلوماتك وفقًا لأعلى معايير الأمان لحماية بياناتك الشخصية أثناء عملية التحقق. ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() => _currentStep = 1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF600A),
            minimumSize: const Size.fromHeight(60),
          ),
          child: const Text(
            'ابدأ التحقق',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Divider(
          thickness: 2, // ⬅️ Makes it bold
          color: Colors.black54, // ⬅️ Optional: customize color
        ),
        const SizedBox(height: 5),
        Container(
          // margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'عند الضغط على زر "ابدأ التحقق"، سيتم نقلك إلى الصفحة التالية لإرفاق صورة الهوية وصورة سيلفي لمطابقة البيانات والتحقق من هويتك.',
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'أرفق الوثائق المطلوبة:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --------------------- صورة الهوية ---------------------
                ElevatedButton.icon(
                  onPressed: () => pickImage(true),
                  icon: const Icon(Icons.upload, size: 24),
                  label: const Text(
                    'تحميل صورة الهوية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                if (_idImage != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Image.file(_idImage!, height: 100),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _idImage = null);
                        },
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Color(0xFFD45000),
                        ),
                        label: const Text(
                          'إزالة',
                          style: TextStyle(
                            color: Color(0xFFD45000),
                            fontFamily: 'NotoSansArabic',
                            fontSize: 15,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => pickImage(true),
                        icon: const Icon(
                          Icons.repeat,
                          color: Color(0xFFD45000),
                        ),
                        label: const Text(
                          'استبدال',
                          style: TextStyle(
                            color: Color(0xFFD45000),
                            fontFamily: 'NotoSansArabic',
                            fontSize: 15,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: const StadiumBorder(), // شكل بيضاوي
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                // --------------------- صورة السيلفي ---------------------
                ElevatedButton.icon(
                  onPressed: () => pickImage(false),
                  icon: const Icon(Icons.upload, size: 24),
                  label: const Text(
                    'تحميل صورة السيلفي',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (_selfieImage != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Image.file(_selfieImage!, height: 100),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _selfieImage = null);
                        },
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Color(0xFFD45000),
                        ),
                        label: const Text(
                          'إزالة',
                          style: TextStyle(
                            color: Color(0xFFD45000),
                            fontSize: 15,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: const StadiumBorder(), // شكل بيضاوي
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => pickImage(false),
                        icon: const Icon(
                          Icons.repeat,
                          color: Color(0xFFD45000),
                        ),
                        label: const Text(
                          'استبدال',
                          style: TextStyle(
                            color: Color(0xFFD45000),
                            fontSize: 15,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: const StadiumBorder(), // شكل بيضاوي
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : verifyIdentity,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF600A),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    'تحقق',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
        ),
        const SizedBox(height: 16),
        // TextButton.icon(
        //   onPressed: () {
        //     setState(() => _currentStep = 0);
        //   },
        //   icon: const Icon(Icons.arrow_back),
        //   label: const Text("العودة إلى الخطوة السابقة"),
        // ),
        const SizedBox(height: 16),
        if (resultMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              border: Border.all(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.info_outline, color: Colors.orange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    resultMessage,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
        const Divider(
          thickness: 2, // ⬅️ Makes it bold
          color: Colors.black54, // ⬅️ Optional: customize color
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text:
                'بالنقر على زر تحقق، فإنك توافق على سياسة الخصوصية الخاصة بموقع id analyzer ومعالجة معلوماتك البيومترية لغرض التحقق من الهوية، وفقًا لـ ',
            style: TextStyle(fontSize: 16, color: Colors.black87),
            children: [
              TextSpan(
                text: 'سياسة الخصوصية',
                style: TextStyle(
                  color: Color(0xFFFF600A),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(
                text: '. يتم الاحتفاظ بالبيانات لمدة لا تتجاوز 3 سنوات.',
              ),
            ],
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ✅ السطر الجديد: شريط التقدم مع زر السهم
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (_currentStep == 1)
                      IconButton(
                        onPressed: () {
                          setState(() => _currentStep = 0);
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.black87,
                      ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _currentStep == 0 ? 0.4 : 1.0,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'التحقق من الهوية للبدء',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'نساعدك في ضمان أمان وثقة المجتمع من خلال التحقق من هويتك عبر موقع id analyzer مجانًا.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (_currentStep == 0)
                        Image.asset('assets/images/idverify.jpg', height: 200),
                      const SizedBox(height: 20),
                      _currentStep == 0
                          ? _buildInstructionsStep()
                          : _buildVerificationStep(),
                    ],
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
