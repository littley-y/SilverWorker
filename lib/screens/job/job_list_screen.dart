import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/job_filter.dart';
import '../../models/job_model.dart';
import '../../providers/job_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/error_retry_view.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/job_card.dart';

/// Job list screen — main home screen showing job postings.
///
/// Displays AppBar, FilterBar, and a list of JobCards.
/// Handles loading, error, and empty states per spec_04 §5.
class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(jobFilterProvider);
    final jobsAsync = ref.watch(jobListProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text('은빛일자리', style: AppTextStyles.headline),
        centerTitle: false,
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Filter bar with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: FilterBar(
              currentFilter: filter,
              onFilterChanged: (newFilter) {
                ref.read(jobFilterProvider.notifier).state = newFilter;
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Content area
          Expanded(
            child: jobsAsync.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return _EmptyState(
                    onResetFilter: () {
                      ref.read(jobFilterProvider.notifier).state =
                          JobFilter.empty;
                    },
                  );
                }
                return _JobListView(
                  jobs: jobs,
                  onJobTap: (job) =>
                      context.push(AppRoutes.jobDetailRoute(job.jobId)),
                );
              },
              loading: () => const _LoadingState(),
              error: (error, _) => _ErrorState(
                onRetry: () => ref.invalidate(jobListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List view of job cards.
class _JobListView extends StatelessWidget {
  final List<JobModel> jobs;
  final void Function(JobModel job) onJobTap;

  const _JobListView({required this.jobs, required this.onJobTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return JobCard(
          job: jobs[index],
          onTap: () => onJobTap(jobs[index]),
        );
      },
    );
  }
}

/// Skeleton loading cards — gray blocks without shimmer (spec_04 §5).
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Company skeleton
                  Container(
                    height: 16,
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColors.skeleton,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Bottom row skeleton
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.skeleton,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.skeleton,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Error state — icon + message + retry button (spec_04 §5).
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ErrorRetryView(
        message: '공고를 불러올 수 없습니다',
        onRetry: onRetry,
      ),
    );
  }
}

/// Empty state — icon + message + filter reset button (spec_04 §5).
class _EmptyState extends StatelessWidget {
  final VoidCallback onResetFilter;

  const _EmptyState({required this.onResetFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              '해당 조건의 공고가 없습니다',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onResetFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('필터 초기화', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
