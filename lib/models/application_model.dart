/// Job application model.
///
/// Represents a user's application to a specific job posting.
class ApplicationModel {
  final String id;
  final String userId;
  final String jobId;
  final String jobTitle; // denormalized for quick display
  final String selfIntroduction; // up to 200 characters
  final String status; // "접수" / "검토" / "합격" / "불합격"
  final DateTime appliedAt;

  const ApplicationModel({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.jobTitle,
    required this.selfIntroduction,
    required this.status,
    required this.appliedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      jobId: json['jobId'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      selfIntroduction: json['selfIntroduction'] as String? ?? '',
      status: json['status'] as String? ?? '접수',
      appliedAt: json['appliedAt'] != null
          ? DateTime.tryParse(json['appliedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'selfIntroduction': selfIntroduction,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? jobId,
    String? jobTitle,
    String? selfIntroduction,
    String? status,
    DateTime? appliedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      selfIntroduction: selfIntroduction ?? this.selfIntroduction,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}
