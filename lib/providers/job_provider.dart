import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/job_repository.dart';
import '../models/job_model.dart';
import '../models/job_filter.dart';
import '../utils/app_logger.dart';
import 'application_provider.dart';
import 'auth_provider.dart';

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

/// Job postings excluding already-applied jobs for the current user.
final visibleJobListProvider = FutureProvider<List<JobModel>>((ref) async {
  final jobs = await ref.watch(jobListProvider.future);
  final user = ref.watch(authStateProvider).valueOrNull;

  if (user == null) return jobs;

  try {
    final applications =
        await ref.watch(myApplicationsProvider(user.uid).future);
    final appliedIds = applications.map((a) => a.jobId).toSet();
    return jobs.where((job) => !appliedIds.contains(job.jobId)).toList();
  } on Object catch (e, st) {
    // Graceful degradation: 애플리케이션 조회 실패 시 전체 공고 표시
    appLogger.w('Failed to filter applied jobs', error: e, stackTrace: st);
    return jobs;
  }
});

/// Fetches a single job posting by document ID.
final jobDetailProvider =
    FutureProvider.family<JobModel?, String>((ref, jobId) {
  return ref.read(jobRepositoryProvider).fetchJobById(jobId);
});
