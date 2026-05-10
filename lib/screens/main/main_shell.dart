import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/error_retry_view.dart';

/// Main shell with BottomNavigationBar for the 3 primary tabs.
///
/// Wraps [child] in a Scaffold with a persistent bottom nav.
/// Also handles the profile-guard redirect (logged in but no profile
/// → redirect to profile setup).
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _tabs = <_TabItem>[
    _TabItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '홈',
      route: AppRoutes.home,
    ),
    _TabItem(
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      label: '지원현황',
      route: AppRoutes.applications,
    ),
    _TabItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '마이페이지',
      route: AppRoutes.mypage,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          // Router redirect handles this; safe fallback.
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final profileAsync = ref.watch(userProfileProvider(user.uid));

        return profileAsync.when(
          data: (profile) {
            if (profile == null) {
              // Logged in but no profile → redirect to profile setup.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go(AppRoutes.profile);
              });
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return _buildScaffold(context);
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, __) => Scaffold(
            body: Center(
              child: ErrorRetryView(
                message: '프로필을 불러오는 중 오류가 발생했습니다.',
                onRetry: () => ref.invalidate(userProfileProvider(user.uid)),
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

  Widget _buildScaffold(BuildContext context) {
    final currentIndex = _resolveIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        elevation: 8,
      ),
    );
  }

  int _resolveIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].route) return i;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final route = _tabs[index].route;
    // Use go() to replace the current tab route, keeping the shell.
    context.go(route);
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
