import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/otp_input_screen.dart';
import '../screens/auth/phone_input_screen.dart';
import '../screens/auth/profile_register_screen.dart';
import '../screens/job/job_detail_screen.dart';
import '../screens/application/application_form_screen.dart';
import '../screens/application/application_result_screen.dart';
import '../screens/job/job_list_screen.dart';
import '../screens/main/main_shell.dart';
import '../screens/mypage/application_list_screen.dart';
import '../screens/mypage/my_page_screen.dart';

/// ---------------------------------------------------------------------------
/// Route paths
/// ---------------------------------------------------------------------------
abstract final class AppRoutes {
  static const String phone = '/auth/phone';
  static const String otp = '/auth/otp';
  static const String profile = '/auth/profile';
  static const String home = '/home';
  static const String applications = '/applications';
  static const String mypage = '/mypage';
  static const String jobDetail = '/job/:jobId';
  static const String apply = '/apply/:jobId';
  static const String applyDone = '/apply/:jobId/done';

  /// Builders for parameterised routes.
  static String jobDetailRoute(String jobId) => '/job/$jobId';
  static String applyRoute(String jobId) => '/apply/$jobId';
  static String applyDoneRoute(String jobId) => '/apply/$jobId/done';
}

/// ---------------------------------------------------------------------------
/// Refresh listenable — bridges Firebase auth stream to go_router.
/// ---------------------------------------------------------------------------
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<User?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// ---------------------------------------------------------------------------
/// Router provider
/// ---------------------------------------------------------------------------
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final refresh = _AuthRefresh(authRepository.authStateChanges());

  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final user = authRepository.currentUser;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.phone ||
          state.matchedLocation == AppRoutes.otp ||
          state.matchedLocation == AppRoutes.profile;

      // Not logged in → must stay on auth routes
      if (!isLoggedIn) {
        return isAuthRoute ? null : AppRoutes.phone;
      }

      // Logged in on auth route → redirect to home (except profile setup)
      if (isLoggedIn && isAuthRoute) {
        if (state.matchedLocation == AppRoutes.phone ||
            state.matchedLocation == AppRoutes.otp) {
          return AppRoutes.home;
        }
        // Profile route is allowed when logged in (it checks itself)
        return null;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.phone,
        builder: (BuildContext context, GoRouterState state) {
          return const PhoneInputScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (BuildContext context, GoRouterState state) {
          return const OtpInputScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileSetupScreen();
        },
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainShell(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.home,
            builder: (BuildContext context, GoRouterState state) {
              return const JobListScreen();
            },
          ),
          GoRoute(
            path: AppRoutes.applications,
            builder: (BuildContext context, GoRouterState state) {
              return const ApplicationListScreen();
            },
          ),
          GoRoute(
            path: AppRoutes.mypage,
            builder: (BuildContext context, GoRouterState state) {
              return const MyPageScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.jobDetail,
        builder: (BuildContext context, GoRouterState state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return JobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: AppRoutes.apply,
        builder: (BuildContext context, GoRouterState state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return ApplicationFormScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: AppRoutes.applyDone,
        builder: (BuildContext context, GoRouterState state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return ApplicationResultScreen(jobId: jobId);
        },
      ),
    ],
  );
});
