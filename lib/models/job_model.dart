import '../utils/timestamp_helper.dart';

/// Job posting model.
///
/// Represents a job listing. Aligned with `overview/04_db_schema.md` §2.2.
///
/// Enum fields store English codes (e.g. `security_management`, `light`).
/// UI labels are mapped at the presentation layer.
class JobModel {
  final String jobId;
  final String source;
  final String title;
  final String companyName;
  final String companyAddress;
  final String locationCode;
  final String jobCategory; // e.g. "security_management"
  final String jobCategoryDetail;
  final String employmentType; // "part_time" | "daily" | "short_term" | "full_time"
  final String salaryType; // "hourly" | "daily" | "monthly"
  final double salaryAmount;
  final String workHours;
  final String workDays;
  final String workPeriod;
  final String requirements;
  final String benefits;
  final String description;
  final String physicalIntensity; // "light" | "moderate" | "heavy"
  final List<String> physicalBadges; // e.g. ["standing", "outdoor"]
  final int? minAge;
  final int? maxAge;
  final DateTime? deadline;
  final bool isActive;
  final Map<String, dynamic> rawData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JobModel({
    required this.jobId,
    required this.source,
    required this.title,
    required this.companyName,
    required this.companyAddress,
    required this.locationCode,
    required this.jobCategory,
    required this.jobCategoryDetail,
    required this.employmentType,
    required this.salaryType,
    required this.salaryAmount,
    required this.workHours,
    required this.workDays,
    required this.workPeriod,
    required this.requirements,
    required this.benefits,
    required this.description,
    required this.physicalIntensity,
    required this.physicalBadges,
    this.minAge,
    this.maxAge,
    this.deadline,
    required this.isActive,
    required this.rawData,
    this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['jobId'] as String? ?? '',
      source: json['source'] as String? ?? '',
      title: json['title'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      companyAddress: json['companyAddress'] as String? ?? '',
      locationCode: json['locationCode'] as String? ?? '',
      jobCategory: json['jobCategory'] as String? ?? '',
      jobCategoryDetail: json['jobCategoryDetail'] as String? ?? '',
      employmentType: json['employmentType'] as String? ?? '',
      salaryType: json['salaryType'] as String? ?? '',
      salaryAmount: (json['salaryAmount'] as num?)?.toDouble() ?? 0.0,
      workHours: json['workHours'] as String? ?? '',
      workDays: json['workDays'] as String? ?? '',
      workPeriod: json['workPeriod'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
      benefits: json['benefits'] as String? ?? '',
      description: json['description'] as String? ?? '',
      physicalIntensity: json['physicalIntensity'] as String? ?? 'moderate',
      physicalBadges:
          (json['physicalBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      deadline: TimestampHelper.toDateTime(json['deadline']),
      isActive: json['isActive'] as bool? ?? true,
      rawData: json['rawData'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      createdAt: TimestampHelper.toDateTime(json['createdAt']),
      updatedAt: TimestampHelper.toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'jobId': jobId,
      'source': source,
      'title': title,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'locationCode': locationCode,
      'jobCategory': jobCategory,
      'jobCategoryDetail': jobCategoryDetail,
      'employmentType': employmentType,
      'salaryType': salaryType,
      'salaryAmount': salaryAmount,
      'workHours': workHours,
      'workDays': workDays,
      'workPeriod': workPeriod,
      'requirements': requirements,
      'benefits': benefits,
      'description': description,
      'physicalIntensity': physicalIntensity,
      'physicalBadges': physicalBadges,
      'minAge': minAge,
      'maxAge': maxAge,
      'deadline': TimestampHelper.fromDateTime(deadline),
      'isActive': isActive,
      'rawData': rawData,
      'createdAt': TimestampHelper.fromDateTime(createdAt),
      'updatedAt': TimestampHelper.fromDateTime(updatedAt),
    };
  }

  JobModel copyWith({
    String? jobId,
    String? source,
    String? title,
    String? companyName,
    String? companyAddress,
    String? locationCode,
    String? jobCategory,
    String? jobCategoryDetail,
    String? employmentType,
    String? salaryType,
    double? salaryAmount,
    String? workHours,
    String? workDays,
    String? workPeriod,
    String? requirements,
    String? benefits,
    String? description,
    String? physicalIntensity,
    List<String>? physicalBadges,
    int? minAge,
    int? maxAge,
    DateTime? deadline,
    bool? isActive,
    Map<String, dynamic>? rawData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      jobId: jobId ?? this.jobId,
      source: source ?? this.source,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      locationCode: locationCode ?? this.locationCode,
      jobCategory: jobCategory ?? this.jobCategory,
      jobCategoryDetail: jobCategoryDetail ?? this.jobCategoryDetail,
      employmentType: employmentType ?? this.employmentType,
      salaryType: salaryType ?? this.salaryType,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      workHours: workHours ?? this.workHours,
      workDays: workDays ?? this.workDays,
      workPeriod: workPeriod ?? this.workPeriod,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      description: description ?? this.description,
      physicalIntensity: physicalIntensity ?? this.physicalIntensity,
      physicalBadges: physicalBadges ?? this.physicalBadges,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      deadline: deadline ?? this.deadline,
      isActive: isActive ?? this.isActive,
      rawData: rawData ?? this.rawData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
