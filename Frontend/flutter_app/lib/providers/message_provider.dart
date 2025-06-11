import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  int _unreadCount = 0;
  Map<String, List<Message>> _conversations = {};

  int get unreadCount => _unreadCount;
  List<Message> get messages => _messages;
  Map<String, List<Message>> get conversations => _conversations; // ✅ ADD THIS

  List<Message> getConversationWith(String otherUserId) {
    return _conversations[otherUserId] ?? [];
  }

  void addMessage(Message msg) async {
    _messages.add(msg);

    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getString('userId');

    // ✅ Find the other person in the conversation
    final otherUserId = msg.senderId == myId ? msg.receiverId : msg.senderId;

    final convo = _conversations[otherUserId] ?? [];
    convo.add(msg);
    _conversations[otherUserId] = convo;

    if (msg.receiverId == myId && !msg.isRead) {
      _unreadCount++;
    }

    notifyListeners();
  }

  void markConversationAsRead(String otherUserId) {
    if (_conversations.containsKey(otherUserId)) {
      for (var msg in _conversations[otherUserId]!) {
        msg.isRead = true;
      }
    }
    _unreadCount = _messages.where((m) => !m.isRead).length;
    notifyListeners();
  }

  void setAllMessages(List<Message> msgs) {
    _messages = msgs;
    _unreadCount = msgs.where((m) => !m.isRead).length;
    _conversations = {};
    for (var msg in msgs) {
      final other = msg.senderId;
      _conversations.putIfAbsent(other, () => []);
      _conversations[other]!.add(msg);
    }
    notifyListeners();
  }

  Future<void> loadInitialMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/messages/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final messages = jsonData.map((e) => Message.fromJson(e)).toList();
      setAllMessages(messages);
    }
  }
}
