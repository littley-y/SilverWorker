import '../models/job_model.dart';
import '../models/job_filter.dart';

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
