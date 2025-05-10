class CaregiverProfileModel {
  final String firstName;
  final String lastName;
  final String? image;
  final String city;
  final int yearsExperience;
  final bool? isSmoker;
  final List<String> skillsAndServices;
  final List<String> trainingCertification;
  final String bio;
  final String rateText; // ✅ أضفنا الحقل الجديد

  final Map<String, dynamic>? location; // ✅ New: raw coordinates
  final double? distanceInKm; // ✅ New: distance in km

  CaregiverProfileModel({
    required this.firstName,
    required this.lastName,
    this.image,
    required this.city,
    required this.yearsExperience,
    this.isSmoker,
    required this.skillsAndServices,
    required this.trainingCertification,
    required this.bio,
    required this.rateText, // ✅ أضفناه هنا أيضاً
    this.location, // ✅ added
    this.distanceInKm, // ✅ added
  });

  factory CaregiverProfileModel.fromJson(Map<String, dynamic> json) {
    return CaregiverProfileModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      image: json['image'],
      city: json['city'] ?? '',
      yearsExperience: json['years_experience'] ?? 0,
      isSmoker: json['is_smoker'],
      skillsAndServices: List<String>.from(json['skills_and_services'] ?? []),
      trainingCertification: List<String>.from(
        json['training_certification'] ?? [],
      ),
      bio: json['bio'] ?? '',
      rateText:
          json['rateText'] ?? 'لم يتم تحديد الأجر', // ✅ وهنا نقرأه من الـ JSON
      location: json['location'], // ✅ expects {lat, lng}
      distanceInKm: json['distanceInKm']?.toDouble(), // ✅ optional
    );
  }
}
