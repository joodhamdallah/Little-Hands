import 'package:flutter/material.dart';

class ExpertProvider extends ChangeNotifier {
  final Map<String, dynamic> _data = {};
String _bio = '';
int _rate = 0;

String get bio => _bio;
int get rate => _rate;

  void update(String key, dynamic value) {
    _data[key] = value;
    notifyListeners();
  }

  void updateMany(Map<String, dynamic> newData) {
    _data.addAll(newData);
    notifyListeners();
  }
void setBioAndRate({
  required String bio,
  required int rate,
}) {
  _bio = bio;
  _rate = rate;
  _data['bio'] = bio;
  _data['rate'] = rate;
  _data['rate_type'] = 'ساعة'; 
  notifyListeners();
}


void setExperienceDetails({
  required int yearsOfExperience,
  required List<String> sessionTypes,
  required String deliveryMethod,
  required List<String> ageGroups,
}) {
  _data['years_of_experience'] = yearsOfExperience;
  _data['session_types'] = sessionTypes;
  _data['delivery_method'] = deliveryMethod;
  _data['age_groups'] = ageGroups;
  notifyListeners();
}

 void setQualificationsAndLicense({
  required List<Map<String, dynamic>> degrees,
  required Map<String, dynamic>? license,
}) {
  _data['degrees'] = degrees;
  _data['has_license'] = license != null;
  if (license != null) {
    _data['license_authority'] = license['authority'];
    _data['license_expiry'] = license['expiry_date'];
    _data['license_file_name'] = license['attachment'];
  }
  notifyListeners();
}



  dynamic get(String key) => _data[key];

  Map<String, dynamic> getAll() => _data;
  
  void clear() {
    _data.clear();
    notifyListeners();
  }
}
