import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  Timer? _pollingTimer;

  int get unreadCount => _unreadCount;

  Future<void> loadUnreadCount() async {
    final count = await NotificationService.getUnreadCount();
    if (_unreadCount != count) {
      _unreadCount = count;
      notifyListeners();
    }
  }

  void startAutoRefresh() {
    // Cancel any existing timer
    _pollingTimer?.cancel();

    // Start new polling timer every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      loadUnreadCount();
    });
  }

  void stopAutoRefresh() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void reset() {
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
