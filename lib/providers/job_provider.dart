import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/job_repository.dart';
import '../models/job_model.dart';

/// Global instance of [JobRepository].
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

/// Current filter state for job search.
final jobFilterProvider = StateProvider<JobFilter>((ref) {
  return JobFilter.empty;
});

/// Fetches job postings based on the current filter.
final jobListProvider = FutureProvider<List<JobModel>>((ref) {
  final filter = ref.watch(jobFilterProvider);
  return ref.read(jobRepositoryProvider).fetchJobs(filter);
});
