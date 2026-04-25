import '../models/job_model.dart';

/// Filter parameters for job search.
class JobFilter {
  final String? region;
  final String? category;
  final String? workType;

  const JobFilter({this.region, this.category, this.workType});

  static const JobFilter empty = JobFilter();

  JobFilter copyWith({String? region, String? category, String? workType}) {
    return JobFilter(
      region: region ?? this.region,
      category: category ?? this.category,
      workType: workType ?? this.workType,
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
  Future<JobModel?> fetchJobById(String id) async {
    // TODO(spec_05): implement detail fetch.
    return null;
  }
}
