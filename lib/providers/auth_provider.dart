import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Global instance of [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Stream of Firebase authentication state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Fetches the current user's profile by UID.
final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) {
  return ref.read(authRepositoryProvider).fetchProfile(uid);
});
