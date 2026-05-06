import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/application_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';

/// 지원 내역 목록 화면.
class ApplicationListScreen extends ConsumerWidget {
  const ApplicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final applicationsAsync = ref.watch(myApplicationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('지원 내역', style: AppTextStyles.headline),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ApplicationCard(application: applications[index]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            '지원 내역을 불러오는 중 오류가 발생했습니다.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// 개별 지원 항목 카드.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.application});

  final ApplicationModel application;

  static const Map<String, String> _statusLabels = <String, String>{
    'submitted': '접수',
    'reviewing': '검토 중',
    'accepted': '합격',
    'rejected': '불합격',
    'cancelled': '취소됨',
  };

  static const Map<String, Color> _statusColors = <String, Color>{
    'submitted': AppColors.statusSubmitted,
    'reviewing': AppColors.statusReviewing,
    'accepted': AppColors.statusAccepted,
    'rejected': AppColors.statusRejected,
    'cancelled': AppColors.statusCancelled,
  };

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabels[application.status] ?? application.status;
    final statusColor =
        _statusColors[application.status] ?? AppColors.textSecondary;
    final submittedAt = application.submittedAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  application.jobTitle,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  application.companyName,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                if (submittedAt != null)
                  Text(
                    _formatDate(submittedAt),
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }
}

// ---------------------------------------------------------------------------
// 빈 상태
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 지원한 공고가 없습니다',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
