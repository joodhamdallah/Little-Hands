import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/models/caregiver_profile_model.dart';
import 'package:flutter_app/pages/config.dart';

class CaregiverHomeMainPage extends StatelessWidget {
  final CaregiverProfileModel profile;

  const CaregiverHomeMainPage({super.key, required this.profile});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "صباح الخير";
    if (hour < 17) return "مساء الخير";
    return "مساء الخير";
  }

  @override
  Widget build(BuildContext context) {
    final String caregiverName = "${profile.firstName} ${profile.lastName}";
    const primaryColor = Color(0xFFFF600A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "${getGreeting()}, $caregiverName",
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.image != null && profile.image!.isNotEmpty)
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.orange.shade100,
                  backgroundImage: NetworkImage(
                    profile.image!.replaceAll('\\', '/').startsWith('http')
                        ? profile.image!
                        : '$baseUrl/${profile.image!.replaceAll('\\', '/')}',
                  ),
                ),
              ),
            const SizedBox(height: 20),

            _buildCard(
              child: const Text(
                "يمكنك من هنا إدارة مواعيد عملك، مراجعة حجوزاتك، وتتبع التقييمات الخاصة بك.",
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 360,
                ), // Adjust based on your design
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard(
                      "عدد الجلسات",
                      "${profile.totalBookings}",
                      Icons.calendar_today,
                      primaryColor,
                    ),
                    _buildStatCard(
                      "متوسط التقييم",
                      profile.averageRating.toStringAsFixed(1),
                      Icons.star,
                      Colors.amber,
                    ),
                    _buildStatCard(
                      "التقييمات",
                      "${profile.totalFeedbacks}",
                      Icons.feedback,
                      Colors.teal,
                    ),
                    _buildStatCard(
                      "جلسات اليوم",
                      "${profile.todaySessions}",
                      Icons.schedule,
                      Colors.deepPurple,
                    ),
                    _buildStatCard(
                      "إجمالي الدخل",
                      "${profile.totalIncome.toStringAsFixed(0)} ₪",
                      Icons.monetization_on,
                      Colors.green,
                    ),
                    _buildStatCard(
                      "معدل الجلسة",
                      "${profile.averageSessionRate.toStringAsFixed(1)} ₪",
                      Icons.price_check,
                      Colors.blueGrey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (profile.todaySessionInfo != null)
              _buildCard(
                color: const Color(0xFFEAF9F1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "جلسة اليوم:",
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "🕒 الوقت: ${profile.todaySessionInfo!['time']['start']} - ${profile.todaySessionInfo!['time']['end']}",
                    ),
                    Text(
                      "👶 الأعمار: ${(profile.todaySessionInfo!['children_ages'] as List).join(', ')}",
                    ),
                    Text(
                      "📍 العنوان: ${profile.todaySessionInfo!['address']['city']}",
                    ),
                    Text("💰 الدفع: cash"),
                    if (profile.todaySessionInfo!['parent'] != null)
                      Text(
                        "👨‍👩‍👧‍👦 ولي الأمر: ${profile.todaySessionInfo!['parent']['first_name']} ${profile.todaySessionInfo!['parent']['last_name']}",
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Highlighted Feedback
            if (profile.highlightedFeedback != null)
              _buildCard(
                color: const Color(0xFFFDF4F2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تقييم مميز:",
                      style: TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (profile
                                .highlightedFeedback!['from_user']?['image'] !=
                            null)
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              profile
                                  .highlightedFeedback!['parent_id']['image'],
                            ),
                            radius: 20,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          "${profile.highlightedFeedback!['from_user']['first_name']} ${profile.highlightedFeedback!['from_user']['last_name']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "⭐ (${profile.highlightedFeedback!['overall_rating']?.toStringAsFixed(1) ?? '0.0'})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(5, (index) {
                            final ratingValue =
                                profile.highlightedFeedback!['overall_rating'];
                            double rating =
                                (ratingValue is num)
                                    ? ratingValue.toDouble()
                                    : 0.0;
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    if (profile.highlightedFeedback!['comments'] != null &&
                        profile.highlightedFeedback!['comments'].isNotEmpty)
                      ...profile.highlightedFeedback!['comments'].map<Widget>((
                        c,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "${c['comment']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    else
                      const Text("💬 لا يوجد تعليق"),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "عدد الجلسات خلال الأسابيع الأربعة الماضية",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansArabic',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups:
                            profile.sessionsChart.asMap().entries.map((entry) {
                              final index = entry.key;
                              final week = entry.value['week'] ?? '';
                              final count = entry.value['count'] ?? 0;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: count.toDouble(),
                                    color: primaryColor,
                                    width: 20,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final index = value.toInt();
                                if (index < profile.sessionsChart.length) {
                                  return Text(
                                    profile.sessionsChart[index]['week'],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildCard(
              color: const Color(0xFFFFF3E8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "نصائح لتحسين ملفك:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("🔸 أكمل بياناتك وتحديث الصورة الشخصية."),
                  Text("🔸 حدد تفضيلات العمل لتظهر في نتائج البحث."),
                  Text("🔸 تابع التقييمات لتحسين تجربتك مع الأهل."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: child,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: iconColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoSansArabic',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
