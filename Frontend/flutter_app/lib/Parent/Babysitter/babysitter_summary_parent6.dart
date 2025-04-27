import 'package:flutter/material.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_address_parent1.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_animation.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_childdage_parent3.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_rate_parent4.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_requirments_parent5.dart';
import 'package:flutter_app/Parent/Babysitter/babysitter_type_parent2.dart';

class BabysitterSummaryPage extends StatelessWidget {
  final Map<String, dynamic> jobDetails;

  const BabysitterSummaryPage({super.key, required this.jobDetails});

  @override
  Widget build(BuildContext context) {
    final sessionTypeTranslations = {
      'regular': 'جليسة منتظمة',
      'once': 'جليسة لمرة واحدة',
      'nanny': 'مربية (Nanny)',
    };

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
          title: const Text(
            'ملخص تفاصيل الجلسة',
            style: TextStyle(fontFamily: 'NotoSansArabic'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.grey,
                color: Color(0xFFFF600A),
                minHeight: 6,
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                context,
                'موقع الجلسة:',
                jobDetails['session_address'] == 'home'
                    ? 'في منزل ولي الأمر'
                    : '${jobDetails['city'] ?? ''} - ${jobDetails['neighborhood'] ?? ''} - ${jobDetails['street'] ?? ''} - ${jobDetails['building'] ?? ''}',
              ),

              _buildInfoRow(
                context,
                'نوع الجليسة:',
                sessionTypeTranslations[jobDetails['session_type']] ??
                    'غير محدد',
              ),

              _buildInfoRow(
                context,
                'تواريخ وأوقات الجلسة:',
                jobDetails['session_start_date'] != null
                    ? """التاريخ: ${jobDetails['session_start_date'].toString().split(' ')[0]}
الوقت: ${jobDetails['session_start_time']} إلى ${jobDetails['session_end_time']} 
الأيام: ${(jobDetails['session_days'] as List?)?.join("، ") ?? ''}
 نهايةالجلسات: ${jobDetails['session_end_date'] != null ? jobDetails['session_end_date'].toString().split(' ')[0] : ''}"""
                    : 'غير محدد',
              ),

              _buildInfoRow(
                context,
                'الأطفال الذين يحتاجون للرعاية:',
                (jobDetails['children_ages'] != null &&
                        (jobDetails['children_ages'] as List).isNotEmpty)
                    ? (jobDetails['children_ages'] as List).join('، ')
                    : 'لا يوجد أطفال مضافين',
              ),

              _buildInfoRow(
                context,
                'الحالة الصحية:',
                (jobDetails['has_medical_condition'] == true)
                    ? jobDetails['medical_condition_details'] ??
                        'لم يتم ذكر تفاصيل'
                    : 'لا يوجد',
              ),

              _buildInfoRow(
                context,
                'تناول أدوية:',
                (jobDetails['takes_medicine'] == true)
                    ? jobDetails['medicine_details'] ?? 'لم يتم ذكر تعليمات'
                    : 'لا يوجد',
              ),

              _buildInfoRow(
                context,
                'ملاحظات إضافية:',
                jobDetails['additional_notes']?.toString().isNotEmpty == true
                    ? jobDetails['additional_notes']
                    : 'لا يوجد',
              ),

              _buildInfoRow(
                context,
                'نطاق السعر المتوقع:',
                '₪ ${jobDetails['rate_min'] ?? 0} - ₪ ${jobDetails['rate_max'] ?? 0} / ساعة',
              ),

              _buildInfoRow(
                context,
                'متطلبات إضافية:',
                (jobDetails['additional_requirements'] != null &&
                        (jobDetails['additional_requirements'] as List)
                            .isNotEmpty)
                    ? (jobDetails['additional_requirements'] as List).join('، ')
                    : 'لا يوجد متطلبات إضافية',
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BabysitterSearchAnimationPage(
          jobDetails: jobDetails,
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
                    'تأكيد وإرسال',
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
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'NotoSansArabic',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
            onPressed: () {
              if (title == 'موقع الجلسة:') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BabysitterSessionAddressPage(
                          previousData: jobDetails,
                          isEditing: true,
                        ),
                  ),
                );
              } else if (title == 'نوع الجليسة:' ||
                  title == 'تواريخ وأوقات الجلسة:') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BabysitterTypeSelectionPage(
                          previousData: jobDetails,
                        ),
                  ),
                );
              } else if (title == 'الأطفال الذين يحتاجون للرعاية:' ||
                  title == 'الحالة الصحية:' ||
                  title == 'تناول أدوية:' ||
                  title == 'ملاحظات إضافية:') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddChildrenAgePage(previousData: jobDetails),
                  ),
                );
              } else if (title == 'النطاق السعري المتوقع:') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            BabysitterRateRangePage(previousData: jobDetails),
                  ),
                );
              } else if (title == 'متطلبات إضافية:') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ParentOtherRequirementsPage(
                          previousData: jobDetails,
                        ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansArabic',
      ),
    );
  }
}
