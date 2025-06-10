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
  final String rateText;
  final Map<String, dynamic>? ratePerHour;

  final Map<String, dynamic>? location;
  final double? distanceInKm;

  final int totalBookings;
  final int totalFeedbacks;
  final double averageRating;
  final int todaySessions;

  final double totalIncome;
  final double averageSessionRate;
  final List<Map<String, dynamic>> sessionsChart;

  final Map<String, dynamic>? todaySessionInfo;
  final Map<String, dynamic>? highlightedFeedback;
  final List<Map<String, dynamic>>? highlightedComments;

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
    required this.rateText,
    this.ratePerHour, // ✅
    this.location,
    this.distanceInKm,
    this.totalBookings = 0,
    this.totalFeedbacks = 0,
    this.averageRating = 0,
    this.todaySessions = 0,
    this.totalIncome = 0.0,
    this.averageSessionRate = 0.0,
    this.sessionsChart = const [],
    this.todaySessionInfo,
    this.highlightedFeedback,
    this.highlightedComments,
  });

  factory CaregiverProfileModel.fromJson(Map<String, dynamic> json) {
    return CaregiverProfileModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      image: json['image'],
      city: json['city'] ?? '',
      yearsExperience: json['years_experience'] ?? 0,
      isSmoker: json['is_smoker'],
      skillsAndServices: List<String>.from(
        json['skills_and_services'] ?? json['session_types'] ?? [],
      ),
      trainingCertification: List<String>.from(
        json['training_certification'] ?? json['categories'] ?? [],
      ),
      bio: json['bio'] ?? '',
      rateText:
          json['rateText'] ??
          (json['rate'] != null
              ? '${json['rate']} شيكل'
              : 'لم يتم تحديد الأجر'),
      ratePerHour:
          json['rate_per_hour'], // ✅ this will be a Map<String, dynamic>
      location: json['location'],
      distanceInKm: json['distanceInKm']?.toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
      totalFeedbacks: json['totalFeedbacks'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      todaySessions: json['todaySessions'] ?? 0,
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      averageSessionRate: (json['averageSessionRate'] ?? 0).toDouble(),
      sessionsChart: List<Map<String, dynamic>>.from(
        json['sessions_chart'] ?? [],
      ),
      todaySessionInfo: json['today_session_info'],
      highlightedFeedback: json['highlighted_feedback'],
      highlightedComments: List<Map<String, dynamic>>.from(
        json['highlighted_feedback']?['comments'] ?? [],
      ),
    );
  }
}
