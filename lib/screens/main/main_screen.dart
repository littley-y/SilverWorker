import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../job/job_list_screen.dart';

/// Main screen shown after successful authentication + profile setup.
///
/// Placeholder for Day 8/10 navigation overhaul (BottomNav + go_router).
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    if (user == null) {
      // Should never happen because of router redirect, but guard anyway.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.phone);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profileAsync = ref.watch(userProfileProvider(user.uid));

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          // Logged in but no profile → redirect to profile setup
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRoutes.profile);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // For Day 2, simply show the job list screen.
        // Day 8 will replace this with a BottomNavigationBar scaffold.
        return const JobListScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('프로필을 불러오는 중 오류가 발생했습니다.')),
      ),
    );
  }
}
