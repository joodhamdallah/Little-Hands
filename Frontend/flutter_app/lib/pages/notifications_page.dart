import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  final VoidCallback? onMarkedRead;
  const NotificationsPage({super.key, this.onMarkedRead});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  String selectedTab = 'all';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${url}notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        notifications = List<Map<String, dynamic>>.from(data['data']);
      });
    }
  }

  Future<void> markAsRead(String id) async {
    await http.put(Uri.parse('${url}notifications/$id/read'));
    widget.onMarkedRead?.call();
    fetchNotifications();
  }

  Future<void> deleteNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.delete(
      Uri.parse('${url}notifications/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        notifications.removeWhere((n) => n['_id'] == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => n['read'] == false).toList();
    notifications.where((n) => n['read'] == true).toList();
    final visibleNotifications =
        selectedTab == 'unread' ? unread : notifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // ✅ CENTER the buttons
              children: [
                _buildTabButton('all', 'الكل'),
                const SizedBox(width: 12),
                _buildUnreadTabWithBadge(), // ✅ special method for badge
              ],
            ),
          ),

          Expanded(
            child:
                visibleNotifications.isEmpty
                    ? const Center(child: Text('لا توجد إشعارات حالياً'))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: visibleNotifications.length,
                      itemBuilder: (context, index) {
                        final n = visibleNotifications[index];
                        final Map<String, dynamic>? extraData = n['data'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: ListTile(
                            leading:
                                n['read']
                                    ? null
                                    : Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF600A),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                            title: Text(
                              n['title'],
                              style: const TextStyle(
                                fontFamily: 'NotoSansArabic',
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n['message'],
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansArabic',
                                  ),
                                ),

                                if (extraData != null) ...[
                                  if (extraData['city'] != null)
                                    Text(
                                      'المدينة: ${extraData['city']}',
                                      style: TextStyle(fontSize: 15),
                                    ),

                                  if (extraData['session_date'] != null)
                                    Text(
                                      'التاريخ: ${_formatDate(extraData['session_date'])}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  if (extraData['session_start_time'] != null &&
                                      extraData['session_end_time'] != null)
                                    Text(
                                      'الوقت: من ${extraData['session_start_time']} حتى ${extraData['session_end_time']}',
                                      style: const TextStyle(fontSize: 15),
                                    ),

                                  if (extraData['parent_name'] != null)
                                    Text(
                                      'المرسل: ${extraData['parent_name']}',
                                      style: TextStyle(fontSize: 15),
                                    ),

                                  if (extraData['caregiver_name'] != null)
                                    Text(
                                      'الجليسة: ${extraData['caregiver_name']}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                ],
                              ],
                            ),

                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'read') markAsRead(n['_id']);
                                if (value == 'delete')
                                  deleteNotification(n['_id']);
                              },
                              itemBuilder:
                                  (_) => [
                                    if (!n['read'])
                                      const PopupMenuItem(
                                        value: 'read',
                                        child: ListTile(
                                          leading: Icon(Icons.done),
                                          title: Text('تحديد كمقروء'),
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('حذف الإشعار'),
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTabButton(String value, String label) {
    final isSelected = selectedTab == value;
    return ElevatedButton(
      onPressed: () => setState(() => selectedTab = value),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFFFF600A) : const Color(0xFFFFF3E9),
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 1,
      ),
      child: Text(label, style: const TextStyle(fontFamily: 'NotoSansArabic')),
    );
  }

  Widget _buildUnreadTabWithBadge() {
    final isSelected = selectedTab == 'unread';

    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => selectedTab = 'unread'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? const Color(0xFFFF600A) : const Color(0xFFFFF3E9),
            foregroundColor: isSelected ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'غير المقروءة',
            style: const TextStyle(fontFamily: 'NotoSansArabic'),
          ),
        ),
        if (notifications.any((n) => n['read'] == false))
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                notifications
                    .where((n) => n['read'] == false)
                    .length
                    .toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
