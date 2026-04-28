import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/otp_input_screen.dart';
import '../screens/auth/phone_input_screen.dart';
import '../screens/auth/profile_register_screen.dart';
import '../screens/main/main_screen.dart';

/// ---------------------------------------------------------------------------
/// Route paths
/// ---------------------------------------------------------------------------
abstract final class AppRoutes {
  static const String phone = '/auth/phone';
  static const String otp = '/auth/otp';
  static const String profile = '/auth/profile';
  static const String main = '/';
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
    initialLocation: AppRoutes.phone,
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

      // Logged in — check profile existence asynchronously via provider
      // Synchronous check: if we're on an auth route and logged in,
      // let the route resolve (profile screen will redirect if needed).
      // For Day 2 we use a simple heuristic: if navigating to / and
      // we don't know profile state yet, allow it; profile route handles
      // its own guard via FutureBuilder if needed.
      if (isLoggedIn && isAuthRoute) {
        // If on phone/otp but already logged in, redirect to main
        if (state.matchedLocation == AppRoutes.phone ||
            state.matchedLocation == AppRoutes.otp) {
          return AppRoutes.main;
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
      GoRoute(
        path: AppRoutes.main,
        builder: (BuildContext context, GoRouterState state) {
          return const MainScreen();
        },
      ),
    ],
  );
});
