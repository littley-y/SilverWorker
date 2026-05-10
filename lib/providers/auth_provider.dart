import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

/// Global instance of [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

/// Stream of Firebase authentication state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Fetches the current user's profile by UID.
final userProfileProvider =
    FutureProvider.family<UserModel?, String>((ref, uid) {
  ref.watch(authStateProvider); // auto-invalidate on auth change
  return ref.read(authRepositoryProvider).fetchProfile(uid);
});

// ---------------------------------------------------------------------------
// Phone auth flow state
// ---------------------------------------------------------------------------

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

/// Immutable state for phone authentication flow.
class PhoneAuthState {
  final bool isLoading;
  final String? verificationId;
  final int? resendToken;
  final String phoneNumber;
  final String? errorMessage;

  const PhoneAuthState({
    this.isLoading = false,
    this.verificationId,
    this.resendToken,
    this.phoneNumber = '',
    this.errorMessage,
  });

  PhoneAuthState copyWith({
    bool? isLoading,
    Object? verificationId = _sentinel,
    Object? resendToken = _sentinel,
    String? phoneNumber,
    Object? errorMessage = _sentinel,
  }) {
    return PhoneAuthState(
      isLoading: isLoading ?? this.isLoading,
      verificationId: verificationId == _sentinel
          ? this.verificationId
          : verificationId as String?,
      resendToken:
          resendToken == _sentinel ? this.resendToken : resendToken as int?,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// Notifier that manages phone authentication state.
class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  final AuthRepository _repository;

  PhoneAuthNotifier(this._repository) : super(const PhoneAuthState());

  /// Clears any stored error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Initiates phone verification via [AuthRepository].
  ///
  /// On success stores [verificationId] and [resendToken] in state.
  /// [forceResendingToken] is used for OTP re-sending on the same session.
  Future<void> startVerification(
    String phoneNumber, {
    int? forceResendingToken,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      phoneNumber: phoneNumber,
    );

    try {
      await _repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _repository.signInWithCredential(credential);
          } on Exception catch (e) {
            appLogger.w('Auto-verification failed', error: e);
            state = state.copyWith(
              isLoading: false,
              errorMessage: '자동 인증 중 오류가 발생했습니다.',
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
            resendToken: resendToken,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
      );
    } on FirebaseAuthException catch (e) {
      if (state.errorMessage == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
        );
      }
    } on Exception catch (e) {
      appLogger.w('Phone verification request failed', error: e);
      if (state.errorMessage == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '인증 요청 중 오류가 발생했습니다.',
        );
      }
    }
  }

  /// Signs in with the SMS code and verification ID.
  ///
  /// Returns the signed-in [User] on success.
  Future<User?> verifyOtp(String smsCode) async {
    final verificationId = state.verificationId;

    if (verificationId == null || verificationId.isEmpty) {
      state = state.copyWith(
        errorMessage: '인증 정보가 없습니다. 다시 시도해 주세요.',
      );
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await _repository.signInWithCredential(credential);
      state = state.copyWith(isLoading: false);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _exceptionToMessage(mapFirebaseAuthException(e)),
      );
      return null;
    } on Exception catch (e) {
      appLogger.w('OTP verification failed', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: '인증 중 오류가 발생했습니다.',
      );
      return null;
    }
  }
}

/// Provider for phone authentication state and operations.
final phoneAuthProvider =
    StateNotifierProvider<PhoneAuthNotifier, PhoneAuthState>((ref) {
  return PhoneAuthNotifier(ref.read(authRepositoryProvider));
});

/// The phone number entered by the user (for display and profile creation).
/// Kept for backward compatibility with [ProfileSetupScreen].
final phoneNumberProvider = Provider<String>((ref) {
  return ref.watch(phoneAuthProvider.select((s) => s.phoneNumber));
});

String _exceptionToMessage(AuthException e) {
  return switch (e) {
    InvalidPhoneException() => '올바른 번호를 입력하세요.',
    InvalidCodeException() => '인증번호가 맞지 않습니다. 다시 확인해 주세요.',
    SessionExpiredException() => '인증번호가 만료되었습니다. 재발송해 주세요.',
    TooManyRequestsException() => '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해 주세요.',
    NetworkRequestFailedException() => '인터넷 연결을 확인해 주세요.',
    UnknownAuthException(:final message) =>
      message ?? '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
  };
}
