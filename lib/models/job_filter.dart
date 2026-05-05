/// Filter parameters for job search.
///
/// Aligned with spec_03~05 filtering requirements.
///
/// [copyWith] uses a sentinel pattern so nullable fields can be
/// explicitly set to `null` (e.g. clearing a location filter).
class JobFilter {
  static const Object _unset = Object();

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
    Object? locationCode = _unset,
    Object? jobCategory = _unset,
    Object? employmentType = _unset,
    Object? physicalIntensity = _unset,
    Object? isActive = _unset,
  }) {
    return JobFilter(
      locationCode: locationCode == _unset
          ? this.locationCode
          : locationCode as String?,
      jobCategory: jobCategory == _unset
          ? this.jobCategory
          : jobCategory as String?,
      employmentType: employmentType == _unset
          ? this.employmentType
          : employmentType as String?,
      physicalIntensity: physicalIntensity == _unset
          ? this.physicalIntensity
          : physicalIntensity as String?,
      isActive: isActive == _unset ? this.isActive : isActive as bool?,
    );
  }
}
