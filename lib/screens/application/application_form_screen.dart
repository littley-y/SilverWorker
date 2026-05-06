import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/application_provider.dart';
import '../../providers/job_provider.dart';
import '../../repositories/application_repository.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final String jobId;

  const ApplicationFormScreen({super.key, required this.jobId});

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _alreadyApplied = false;

  @override
  void initState() {
    super.initState();
    _checkAlreadyApplied();
  }

  Future<void> _checkAlreadyApplied() async {
    try {
      final applied = await ref
          .read(applicationRepositoryProvider)
          .hasApplied(widget.jobId);
      if (mounted && applied) setState(() => _alreadyApplied = true);
    } on Exception {
      // Ignore errors during pre-check
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(applicationRepositoryProvider).submitApplication(
            jobId: widget.jobId,
            selfIntroduction: _controller.text,
          );
      if (mounted) context.go('/apply/${widget.jobId}/done');
    } on AlreadyAppliedException {
      setState(() => _alreadyApplied = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 지원한 공고입니다')),
        );
      }
    } on JobClosedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마감된 공고입니다')),
        );
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지원에 실패했습니다. 다시 시도해 주세요')),
        );
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('지원서 작성', style: AppTextStyles.title),
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return const Center(child: Text('공고를 찾을 수 없습니다'));
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text(job.companyName, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('자기소개', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        maxLength: 200,
                        maxLines: 5,
                        minLines: 5,
                        enabled: !_alreadyApplied,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: '간단한 자기소개를 작성해 주세요 (선택)',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text('공고 정보를 불러올 수 없습니다', style: AppTextStyles.body),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _alreadyApplied || _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('지원 중...', style: AppTextStyles.button),
                      ],
                    )
                  : Text(
                      _alreadyApplied ? '이미 지원한 공고입니다' : '지원하기',
                      style: AppTextStyles.button,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
