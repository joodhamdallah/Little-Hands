import 'package:flutter/material.dart';

class SpecialNeedsProvider extends ChangeNotifier {
  final Map<String, dynamic> _data = {};

  void update(String key, dynamic value) {
    _data[key] = value;
    notifyListeners();
  }

  void updateMany(Map<String, dynamic> values) {
    _data.addAll(values);
    notifyListeners();
  }

  Map<String, dynamic> getAll() {
    return _data;
  }
}

