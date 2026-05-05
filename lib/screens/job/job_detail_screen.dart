import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/job_model.dart';
import '../../providers/job_provider.dart';
import '../../widgets/safety_curation_section.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('공고 상세', style: AppTextStyles.title),
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return const Center(child: Text('공고를 찾을 수 없습니다'));
          }
          return _JobDetailBody(job: job);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('공고를 불러오는 중 오류가 발생했습니다')),
      ),
    );
  }
}

class _JobDetailBody extends StatelessWidget {
  final JobModel job;

  const _JobDetailBody({required this.job});

  @override
  Widget build(BuildContext context) {
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
              SafetyCurationSection(
                physicalIntensity: job.physicalIntensity,
                physicalBadges: job.physicalBadges,
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 20),
              _WorkConditionSection(job: job),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 20),
              _SectionBlock(title: '자격 요건', content: job.requirements),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 20),
              _SectionBlock(title: '복리후생', content: job.benefits),
              const SizedBox(height: 20),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 20),
              _SectionBlock(title: '업무 내용', content: job.description),
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
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('지원하기', style: AppTextStyles.button),
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
        Text(job.title, style: AppTextStyles.headline),
        const SizedBox(height: 8),
        Text(job.companyName, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Text(
          _formatSalary(job),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  static String _formatSalary(JobModel job) {
    final formatter = NumberFormat('#,###');
    switch (job.salaryType) {
      case 'hourly':
        return '시급 ${formatter.format(job.salaryAmount)}원';
      case 'daily':
        return '일급 ${formatter.format(job.salaryAmount)}원';
      case 'monthly':
        final manwon = job.salaryAmount ~/ 10000;
        return '월 ${manwon}만원';
      default:
        return '${formatter.format(job.salaryAmount)}원';
    }
  }
}

class _WorkConditionSection extends StatelessWidget {
  final JobModel job;

  const _WorkConditionSection({required this.job});

  String get _employmentLabel => switch (job.employmentType) {
    'part_time' => '파트타임',
    'daily' => '일용직',
    'short_term' => '단기',
    'full_time' => '정규직',
    _ => job.employmentType,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('근무 조건', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        _ConditionRow(label: '근무지', value: job.companyAddress),
        _ConditionRow(label: '급여', value: _HeaderSection._formatSalary(job)),
        _ConditionRow(label: '근무 시간', value: job.workHours),
        _ConditionRow(label: '근무 요일', value: job.workDays),
        _ConditionRow(label: '근무 기간', value: job.workPeriod),
        _ConditionRow(label: '고용 형태', value: _employmentLabel),
      ],
    );
  }
}

class _ConditionRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConditionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final String content;

  const _SectionBlock({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        Text(content.isNotEmpty ? content : '정보 없음', style: AppTextStyles.body),
      ],
    );
  }
}
