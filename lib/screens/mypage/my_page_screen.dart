import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/error_retry_view.dart';

/// 마이페이지 화면.
///
/// 프로필 요약, 지원 내역 진입점, 로그아웃을 제공합니다.
///
/// 인증 상태는 go_router redirect가 보장하므로 본 화면에서는
/// currentUser가 non-null임을 가정합니다.
class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      data: (user) {
        // Router redirect가 user null을 보장하지만, defensive null-guard.
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileAsync = ref.watch(userProfileProvider(user.uid));
        final applicationsAsync = ref.watch(myApplicationsProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: const Text('마이페이지', style: AppTextStyles.headline),
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          backgroundColor: AppColors.background,
          body: profileAsync.when(
            data: (profile) {
              if (profile == null) {
                // Router redirect가 profile null을 보장하지만, defensive guard.
                return const Center(child: CircularProgressIndicator());
              }

              final applicationCount = applicationsAsync.value?.length ?? 0;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 프로필 요약 카드
                      _ProfileSummaryCard(
                        name: profile.name,
                        address: profile.address.display,
                        careerSummary: profile.careerSummary,
                        applicationCount: applicationCount,
                      ),
                      const SizedBox(height: 24),
                      // 메뉴 리스트
                      _MenuList(),
                      const Spacer(),
                      // 로그아웃 버튼
                      _LogoutButton(
                        onLogout: () => _showLogoutDialog(context, ref),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: ErrorRetryView(
                message: '프로필을 불러오는 중 오류가 발생했습니다.',
                onRetry: () {
                  ref.invalidate(userProfileProvider(user.uid));
                },
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('인증 상태를 확인할 수 없습니다.')),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃', style: AppTextStyles.title),
          content: const Text(
            '로그아웃 하시겠습니까?',
            style: AppTextStyles.body,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소', style: AppTextStyles.body),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(authRepositoryProvider).signOut();
              },
              child: Text(
                '로그아웃',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 프로필 요약 카드
// ---------------------------------------------------------------------------
class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.name,
    required this.address,
    required this.careerSummary,
    required this.applicationCount,
  });

  final String name;
  final String address;
  final String careerSummary;
  final int applicationCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name, style: AppTextStyles.title.copyWith(fontSize: 22)),
          const SizedBox(height: 8),
          Text(address, style: AppTextStyles.body),
          const SizedBox(height: 8),
          Text(
            careerSummary,
            style: AppTextStyles.body.copyWith(fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '총 $applicationCount건 지원',
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 메뉴 리스트
// ---------------------------------------------------------------------------
class _MenuList extends StatelessWidget {
  const _MenuList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _MenuItem(
            icon: Icons.favorite_border,
            label: '찜한 공고',
            // TODO(spec_XX): Bookmark 기능 구현 시 연결
            // 현재 MVP 범위 외이므로 비활성화 상태 유지
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _MenuItem(
            icon: Icons.notifications_none,
            label: '알림 설정',
            onTap: () {
              // 추후 구현
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _MenuItem(
            icon: Icons.settings,
            label: '설정',
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 24, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: AppTextStyles.body),
            ),
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 로그아웃 버튼
// ---------------------------------------------------------------------------
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onLogout,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: AppColors.error,
        ),
        child: const Text('로그아웃', style: AppTextStyles.body),
      ),
    );
  }
}
