import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/job_provider.dart';
import '../../router/app_router.dart';

class ApplicationResultScreen extends ConsumerWidget {
  final String jobId;

  const ApplicationResultScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      body: SafeArea(
        child: jobAsync.when(
          data: (job) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 72, color: AppColors.success),
                    const SizedBox(height: 24),
                    const Text('지원이 완료되었습니다!', style: AppTextStyles.headline),
                    if (job != null) ...[
                      const SizedBox(height: 16),
                      Text(job.title,
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center),
                      Text(job.companyName,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 12),
                    Text('마이페이지에서 지원 현황을 확인하세요',
                        style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.main),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('확인', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    size: 72, color: AppColors.success),
                const SizedBox(height: 24),
                const Text('지원이 완료되었습니다!',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('확인', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
