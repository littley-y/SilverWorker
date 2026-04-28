import '../utils/timestamp_helper.dart';

/// User address value object.
class Address {
  final String sido;
  final String sigungu;

  const Address({required this.sido, required this.sigungu});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      sido: json['sido'] as String? ?? '',
      sigungu: json['sigungu'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'sido': sido, 'sigungu': sigungu};
  }

  String get display => '$sido $sigungu';
}

/// User profile model.
///
/// Represents a senior job seeker's profile.
/// Aligned with `overview/04_db_schema.md` §2.1.
class UserModel {
  final String userId;
  final String phoneNumber;
  final String name;
  final DateTime? birthDate;
  final String gender; // "male" | "female"
  final Address address;
  final String careerSummary;
  final List<String> physicalConditions;
  final List<String> preferredJobTypes;
  final List<String> preferredLocations;
  final bool isPushEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.userId,
    required this.phoneNumber,
    required this.name,
    this.birthDate,
    required this.gender,
    required this.address,
    required this.careerSummary,
    required this.physicalConditions,
    required this.preferredJobTypes,
    required this.preferredLocations,
    required this.isPushEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      name: json['name'] as String? ?? '',
      birthDate: TimestampHelper.toDateTime(json['birthDate']),
      gender: json['gender'] as String? ?? '',
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : const Address(sido: '', sigungu: ''),
      careerSummary: json['careerSummary'] as String? ?? '',
      physicalConditions: (json['physicalConditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      preferredJobTypes: (json['preferredJobTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      preferredLocations: (json['preferredLocations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isPushEnabled: json['isPushEnabled'] as bool? ?? true,
      createdAt: TimestampHelper.toDateTime(json['createdAt']),
      updatedAt: TimestampHelper.toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'phoneNumber': phoneNumber,
      'name': name,
      'birthDate': TimestampHelper.fromDateTime(birthDate),
      'gender': gender,
      'address': address.toJson(),
      'careerSummary': careerSummary,
      'physicalConditions': physicalConditions,
      'preferredJobTypes': preferredJobTypes,
      'preferredLocations': preferredLocations,
      'isPushEnabled': isPushEnabled,
      'createdAt': TimestampHelper.fromDateTime(createdAt),
      'updatedAt': TimestampHelper.fromDateTime(updatedAt),
    };
  }

  UserModel copyWith({
    String? userId,
    String? phoneNumber,
    String? name,
    DateTime? birthDate,
    String? gender,
    Address? address,
    String? careerSummary,
    List<String>? physicalConditions,
    List<String>? preferredJobTypes,
    List<String>? preferredLocations,
    bool? isPushEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      careerSummary: careerSummary ?? this.careerSummary,
      physicalConditions: physicalConditions ?? this.physicalConditions,
      preferredJobTypes: preferredJobTypes ?? this.preferredJobTypes,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
