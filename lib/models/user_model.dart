/// User profile model.
///
/// Represents a senior job seeker's basic profile information.
class UserModel {
  final String uid;
  final String name;
  final String birthDate; // YYYY-MM-DD
  final String region; // e.g. "서울 종로구"
  final String careerSummary; // up to ~500 characters
  final String phoneNumber;

  const UserModel({
    required this.uid,
    required this.name,
    required this.birthDate,
    required this.region,
    required this.careerSummary,
    required this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      region: json['region'] as String? ?? '',
      careerSummary: json['careerSummary'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'birthDate': birthDate,
      'region': region,
      'careerSummary': careerSummary,
      'phoneNumber': phoneNumber,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? birthDate,
    String? region,
    String? careerSummary,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      region: region ?? this.region,
      careerSummary: careerSummary ?? this.careerSummary,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
