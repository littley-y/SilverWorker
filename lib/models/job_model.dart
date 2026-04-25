/// Job posting model.
///
/// Represents a job listing fetched from GoYong24 (or mock data).
class JobModel {
  final String id;
  final String title;
  final String companyName;
  final String region;
  final String jobCategory; // e.g. "경비/관리", "청소/미화"
  final String workType; // e.g. "파트타임", "일용직", "정규직"
  final String salary;
  final String workHours;
  final String welfare;
  final String description;
  final String physicalIntensity; // "가벼움" / "보통" / "무거움"
  final List<String> badges; // e.g. ["계속 서있기", "좌식 업무"]
  final DateTime? postedAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.region,
    required this.jobCategory,
    required this.workType,
    required this.salary,
    required this.workHours,
    required this.welfare,
    required this.description,
    required this.physicalIntensity,
    required this.badges,
    this.postedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      region: json['region'] as String? ?? '',
      jobCategory: json['jobCategory'] as String? ?? '',
      workType: json['workType'] as String? ?? '',
      salary: json['salary'] as String? ?? '',
      workHours: json['workHours'] as String? ?? '',
      welfare: json['welfare'] as String? ?? '',
      description: json['description'] as String? ?? '',
      physicalIntensity: json['physicalIntensity'] as String? ?? '보통',
      badges:
          (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      postedAt: json['postedAt'] != null
          ? DateTime.tryParse(json['postedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'companyName': companyName,
      'region': region,
      'jobCategory': jobCategory,
      'workType': workType,
      'salary': salary,
      'workHours': workHours,
      'welfare': welfare,
      'description': description,
      'physicalIntensity': physicalIntensity,
      'badges': badges,
      'postedAt': postedAt?.toIso8601String(),
    };
  }
}
