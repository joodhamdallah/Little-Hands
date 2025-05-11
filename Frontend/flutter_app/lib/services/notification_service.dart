import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/pages/config.dart'; // adjust path if needed

class NotificationService {
  static Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('${url}notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List notifications = data['data'];
        return notifications.where((n) => !n['read']).length;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${url}notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> markAsRead(String id) async {
    try {
      await http.put(Uri.parse('$url$id/read'));
    } catch (_) {}
  }
}
