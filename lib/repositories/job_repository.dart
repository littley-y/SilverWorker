import '../models/job_model.dart';

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

/// Repository for job posting operations.
class JobRepository {
  /// Fetches job postings matching the given filter.
  ///
  /// Currently returns an empty list as a skeleton.
  /// Will be wired to Firestore or Cloud Functions later.
  Future<List<JobModel>> fetchJobs(JobFilter filter) async {
    // TODO(spec_03): integrate with Firestore / Cloud Functions proxy.
    return <JobModel>[];
  }

  /// Fetches a single job posting by ID.
  Future<JobModel?> fetchJobById(String jobId) async {
    // TODO(spec_05): implement detail fetch.
    return null;
  }
}
