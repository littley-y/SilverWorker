import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/job_filter.dart';

/// Repository for job posting operations.
///
/// Reads from Firestore `/jobs` collection. Write access is restricted
/// to Cloud Functions / admin SDK per `firestore.rules` §jobs.
class JobRepository {
  static const String _collection = 'jobs';

  /// Fetches job postings matching the given filter.
  ///
  /// Filters are applied in this order:
  /// 1. `isActive == true` (always)
  /// 2. `deadline > now` (always)
  /// 3. `locationCode` if provided
  /// 4. `jobCategory` if provided
  ///
  /// Results are ordered by deadline ascending, limited to 50.
  /// Requires composite index: `jobs` `isActive` ASC, `deadline` ASC
  /// (see firestore.indexes.json).
  Future<List<JobModel>> fetchJobs(JobFilter filter) async {
    Query query = FirebaseFirestore.instance
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('deadline', isGreaterThan: Timestamp.now());

    if (filter.locationCode != null) {
      query = query.where('locationCode', isEqualTo: filter.locationCode);
    }
    if (filter.jobCategory != null) {
      query = query.where('jobCategory', isEqualTo: filter.jobCategory);
    }

    query = query.orderBy('deadline').limit(50);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => JobModel.fromJson(doc.data()! as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single job posting by document ID.
  Future<JobModel?> fetchJobById(String jobId) async {
    final doc = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(jobId)
        .get();
    if (!doc.exists) return null;
    return JobModel.fromJson(doc.data()!);
  }
}
