import '../utils/timestamp_helper.dart';

/// Job application model.
///
/// Aligned with `overview/04_db_schema.md` §2.3.
class ApplicationModel {
  final String applicationId;
  final String jobId;
  final String jobTitle; // denormalized
  final String companyName; // denormalized
  final String selfIntroduction;
  final String status; // "submitted" | "reviewing" | "accepted" | "rejected" | "cancelled"
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  const ApplicationModel({
    required this.applicationId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.selfIntroduction,
    required this.status,
    this.submittedAt,
    this.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationId'] as String? ?? '',
      jobId: json['jobId'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      selfIntroduction: json['selfIntroduction'] as String? ?? '',
      status: json['status'] as String? ?? 'submitted',
      submittedAt: TimestampHelper.toDateTime(json['submittedAt']),
      updatedAt: TimestampHelper.toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'selfIntroduction': selfIntroduction,
      'status': status,
      'submittedAt': TimestampHelper.fromDateTime(submittedAt),
      'updatedAt': TimestampHelper.fromDateTime(updatedAt),
    };
  }

  ApplicationModel copyWith({
    String? applicationId,
    String? jobId,
    String? jobTitle,
    String? companyName,
    String? selfIntroduction,
    String? status,
    DateTime? submittedAt,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      selfIntroduction: selfIntroduction ?? this.selfIntroduction,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
