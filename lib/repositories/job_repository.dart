import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/job_filter.dart';
import '../utils/clock.dart';

/// Repository for job posting operations.
///
/// Reads from Firestore `/jobs` collection. Write access is restricted
/// to Cloud Functions / admin SDK per `firestore.rules` §jobs.
class JobRepository {
  static const String _collection = 'jobs';
  final FirebaseFirestore _firestore;
  final Clock _clock;

  JobRepository({
    FirebaseFirestore? firestore,
    Clock? clock,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _clock = clock ?? const SystemClock();

  /// Fetches job postings matching the given filter.
  ///
  /// Filters are applied in this order:
  /// 1. `isActive == true` (always)
  /// 2. `deadline > now` (always)
  ///    NOTE: Firestore inequality queries exclude documents where the
  ///    field is null. Jobs with `deadline: null` (상시 모집) will NOT
  ///    appear. If 상시 jobs are needed, add a second query for
  ///    `where('deadline', isNull: true)` and merge results.
  /// 3. `locationCode` if provided
  /// 4. `jobCategory` if provided
  ///
  /// Results are ordered by deadline ascending, limited to 50.
  /// Requires composite index: `jobs` `isActive` ASC, `deadline` ASC
  /// (see firestore.indexes.json).
  Future<List<JobModel>> fetchJobs(JobFilter filter) async {
    Query query = _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('deadline', isGreaterThan: _clock.nowTimestamp());

    if (filter.locationCode != null) {
      query = query.where('locationCode', isEqualTo: filter.locationCode);
    }
    if (filter.jobCategory != null) {
      query = query.where('jobCategory', isEqualTo: filter.jobCategory);
    }

    query = query.orderBy('deadline').limit(50);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return JobModel.fromJson({...data, 'jobId': doc.id});
    }).toList();
  }

  /// Fetches a single job posting by document ID.
  Future<JobModel?> fetchJobById(String jobId) async {
    final doc = await _firestore.collection(_collection).doc(jobId).get();
    if (!doc.exists) return null;
    return JobModel.fromJson({...doc.data()!, 'jobId': doc.id});
  }
}
