import 'package:flutter/material.dart';

class BabySitterRatePage extends StatefulWidget {
  const BabySitterRatePage({super.key});

  @override
  State<BabySitterRatePage> createState() => _BabySitterRatePageState();
}

class _BabySitterRatePageState extends State<BabySitterRatePage> {
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();
  int numberOfChildren = 1;
  bool? isSmoker;

  @override
  void dispose() {
    _minRateController.dispose();
    _maxRateController.dispose();
    super.dispose();
  }

  Widget buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 0),
    child: Divider(color: Colors.black12, thickness: 1),
  );

  void _handleNext() {
    final minRate = int.tryParse(_minRateController.text);
    final maxRate = int.tryParse(_maxRateController.text);

    if (minRate == null || maxRate == null) {
      _showError('يرجى إدخال قيم صحيحة للأجر.');
      return;
    }

    if (minRate > maxRate) {
      _showError('لا يمكن أن يكون الحد الأدنى أكبر من الحد الأعلى.');
      return;
    }

    // إذا كل شيء صحيح انتقل للصفحة التالية أو احفظ البيانات
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'NotoSansArabic'),
        ),
        backgroundColor: Colors.red,
      ),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'أجركِ بالساعة لطفل واحد. يمكنكِ تحديثه لاحقًا في أي وقت.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NotoSansArabic',
                    color: Colors.black54,
                  ),
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
                      Text(
                        '💡 متوسط أجور المربيات المشابهات لكِ:',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'NotoSansArabic',
                        ),
                      ),
                      Text(
                        '₪ 24 - 30 / ساعة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                          labelStyle: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF600A),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'إلى',
                      style: TextStyle(fontFamily: 'NotoSansArabic'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _maxRateController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'الحد الأعلى',
                          labelStyle: const TextStyle(
                            fontFamily: 'NotoSansArabic',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF600A),
                              width: 1.5,
                            ),
                          ),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (numberOfChildren > 1) {
                            setState(() {
                              numberOfChildren--;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                        ),
                        iconSize: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Text(
                              '$numberOfChildren',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'طفل',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            numberOfChildren++;
                          });
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFFFF007A),
                        ),
                        iconSize: 30,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                buildDivider(),
                const SizedBox(height: 32),
                const Text(
                  'هل أنتِ مدخنة؟',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabic',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Row(
                        children: const [
                          Text(
                            'نعم',
                            style: TextStyle(fontFamily: 'NotoSansArabic'),
                          ),
                          SizedBox(width: 6),
                          Text('😞'),
                        ],
                      ),
                      selected: isSmoker == true,
                      onSelected: (_) {
                        setState(() => isSmoker = true);
                      },
                      selectedColor: const Color(0xFFFFE3D3),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: Row(
                        children: const [
                          Text(
                            'لا',
                            style: TextStyle(fontFamily: 'NotoSansArabic'),
                          ),
                          SizedBox(width: 6),
                          Text('😊'),
                        ],
                      ),
                      selected: isSmoker == false,
                      onSelected: (_) {
                        setState(() => isSmoker = false);
                      },
                      selectedColor: const Color(0xFFFFE3D3),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 35.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/idverifyapi');
                      },
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
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
