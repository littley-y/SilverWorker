/// Filter parameters for job search.
///
/// Aligned with spec_03~05 filtering requirements.
class JobFilter {
  final String? locationCode;
  final String? jobCategory;
  final String? employmentType;
  final String? physicalIntensity;
  final bool? isActive;

  const JobFilter({
    this.locationCode,
    this.jobCategory,
    this.employmentType,
    this.physicalIntensity,
    this.isActive,
  });

  static const JobFilter empty = JobFilter();

  JobFilter copyWith({
    String? locationCode,
    String? jobCategory,
    String? employmentType,
    String? physicalIntensity,
    bool? isActive,
  }) {
    return JobFilter(
      locationCode: locationCode ?? this.locationCode,
      jobCategory: jobCategory ?? this.jobCategory,
      employmentType: employmentType ?? this.employmentType,
      physicalIntensity: physicalIntensity ?? this.physicalIntensity,
      isActive: isActive ?? this.isActive,
    );
  }
}
