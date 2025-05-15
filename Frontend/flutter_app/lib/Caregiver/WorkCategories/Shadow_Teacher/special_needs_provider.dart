import 'package:flutter/material.dart';

class SpecialNeedsProvider extends ChangeNotifier {
  Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;

  void update(String key, dynamic value) {
    _data[key] = value;
    notifyListeners();
  }

  void updateMany(Map<String, dynamic> newData) {
    _data.addAll(newData);
    notifyListeners();
  }

  void clear() {
    _data.clear();
    notifyListeners();
  }
}
