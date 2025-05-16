import 'package:flutter/material.dart';

class ExpertProvider extends ChangeNotifier {
  final Map<String, dynamic> _data = {};

  void update(String key, dynamic value) {
    _data[key] = value;
    notifyListeners();
  }

  void updateMany(Map<String, dynamic> newData) {
    _data.addAll(newData);
    notifyListeners();
  }

  dynamic get(String key) => _data[key];

  Map<String, dynamic> getAll() => _data;
  
  void clear() {
    _data.clear();
    notifyListeners();
  }
}
