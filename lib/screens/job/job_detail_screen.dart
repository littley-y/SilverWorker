import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/job_model.dart';
import '../../models/physical_badge.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../repositories/application_repository.dart';
import '../../router/app_router.dart';
import '../../widgets/error_retry_view.dart';
import '../../widgets/primary_button.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));
    final authAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('공고 상세', style: AppTextStyles.title),
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return Center(
              child: Text('공고를 찾을 수 없습니다', style: AppTextStyles.body),
            );
          }
          return _JobDetailBody(job: job, authAsync: authAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: ErrorRetryView(
            message: '공고를 불러오는 중 오류가 발생했습니다',
            onRetry: () => ref.invalidate(jobDetailProvider(jobId)),
          ),
        ),
      ),
    );
  }
}

class _JobDetailBody extends ConsumerWidget {
  final JobModel job;
  final AsyncValue<User?> authAsync;

  const _JobDetailBody({required this.job, required this.authAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAppliedAsync = authAsync.when(
      data: (user) => user != null
          ? ref.watch(hasAppliedProvider(job.jobId))
          : const AsyncData(false),
      loading: () => const AsyncData(false),
      error: (_, __) => const AsyncData(false),
    );

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(job: job),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 20),

              // 2x2 Small cards
              _InfoCardGrid(job: job),
              const SizedBox(height: 16),

              // 근무 시간 상세
              _DetailCard(
                icon: Icons.access_time,
                title: '근무 시간',
                content: job.workHoursPerDay != null
                    ? '${job.workHoursPerDay}시간'
                    : job.workHours,
              ),

              // 업무 세부 내용
              _DetailCard(
                icon: Icons.description_outlined,
                title: '업무 세부 내용',
                content: job.description,
              ),

              // 자격 요건
              _DetailCard(
                icon: Icons.verified_outlined,
                title: '자격 요건',
                content: job.requirements,
              ),

              // 업무 강도 상세
              _PhysicalDetailCard(badges: job.physicalBadges),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: hasAppliedAsync.when(
                data: (hasApplied) => hasApplied
                    ? _CancelButton(jobId: job.jobId)
                    : PrimaryButton(
                        label: '지원하기',
                        onPressed: () {
                          context.push(AppRoutes.applyRoute(job.jobId));
                        },
                      ),
                loading: () => const PrimaryButton(
                  label: '지원하기',
                  onPressed: null,
                ),
                error: (_, __) => PrimaryButton(
                  label: '지원하기',
                  onPressed: () {
                    context.push(AppRoutes.applyRoute(job.jobId));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final JobModel job;

  const _HeaderSection({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(job.displayTitle, style: AppTextStyles.headline),
        const SizedBox(height: 8),
        Text(job.companyName,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Text(
          job.formattedSalary,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
      ],
    );
  }
}

class _InfoCardGrid extends StatelessWidget {
  final JobModel job;

  const _InfoCardGrid({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.access_time,
                label: '근무시간',
                value: job.workHoursPerDay != null
                    ? '${job.workHoursPerDay}시간'
                    : job.workHours,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.calendar_today,
                label: '근무기간',
                value: job.workPeriod,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.date_range,
                label: '근무요일',
                value: job.workDays,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.work_outline,
                label: '고용형태',
                value: job.employmentTypeLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyBold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content.trim().isNotEmpty ? content : '정보 없음',
            style: AppTextStyles.body.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _PhysicalDetailCard extends StatelessWidget {
  final List<String> badges;

  const _PhysicalDetailCard({required this.badges});

  String _standingTime() {
    if (badges.contains(PhysicalBadge.standing)) return '계속 서있기';
    if (badges.contains(PhysicalBadge.sitting)) return '좌식 업무';
    return '보통';
  }

  String _heavyLifting() {
    return badges.contains(PhysicalBadge.heavyLifting) ? '있음' : '없음';
  }

  String _indoorOutdoor() {
    return badges.contains(PhysicalBadge.outdoor) ? '야외 근무' : '실내 위주';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('업무 강도 상세', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 12),
          _PhysicalRow(
            icon: Icons.accessibility_new,
            label: '서있는 시간',
            value: _standingTime(),
          ),
          const Divider(height: 16),
          _PhysicalRow(
            icon: Icons.inventory_2,
            label: '무거운 짐',
            value: _heavyLifting(),
          ),
          const Divider(height: 16),
          _PhysicalRow(
            icon: Icons.home,
            label: '실내 / 외',
            value: _indoorOutdoor(),
          ),
        ],
      ),
    );
  }
}

class _PhysicalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PhysicalRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppTextStyles.bodyBold),
      ],
    );
  }
}

class _CancelButton extends ConsumerStatefulWidget {
  final String jobId;

  const _CancelButton({required this.jobId});

  @override
  ConsumerState<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends ConsumerState<_CancelButton> {
  bool _isCancelling = false;
  bool _showSuccessCard = false;

  void _showFloatingCard() {
    setState(() => _showSuccessCard = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSuccessCard = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ElevatedButton(
          onPressed: _isCancelling
              ? null
              : () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('지원 취소', style: AppTextStyles.title),
                      content: const Text(
                        '이 공고의 지원을 취소하시겠습니까?',
                        style: AppTextStyles.body,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('아니오', style: AppTextStyles.body),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            '취소하기',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;

                  setState(() => _isCancelling = true);
                  try {
                    await ref
                        .read(applicationRepositoryProvider)
                        .cancelApplication(widget.jobId);
                    if (mounted) {
                      _showFloatingCard();
                      ref.invalidate(myApplicationsProvider(
                        ref.read(authStateProvider).value!.uid,
                      ));
                      ref.invalidate(hasAppliedProvider(widget.jobId));
                    }
                  } catch (e) {
                    if (mounted) {
                      final message = e is NoApplicationException
                          ? '지원 내역이 없습니다.'
                          : '취소에 실패했습니다. 다시 시도해 주세요.';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isCancelling = false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          child: _isCancelling
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('지원 취소'),
        ),
        if (_showSuccessCard)
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '지원이 취소되었습니다',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
