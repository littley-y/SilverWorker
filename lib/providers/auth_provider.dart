import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

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
  return ref.read(authRepositoryProvider).fetchProfile(uid);
});

// ---------------------------------------------------------------------------
// Phone auth flow state
// ---------------------------------------------------------------------------

/// Tracks whether an auth operation is in progress.
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// The verification ID returned by Firebase after sending an OTP.
final verificationIdProvider = StateProvider<String?>((ref) => null);

/// The resend token for OTP re-sending.
final resendTokenProvider = StateProvider<int?>((ref) => null);

/// The phone number entered by the user (for display and profile creation).
final phoneNumberProvider = StateProvider<String>((ref) => '');

/// Initiates phone verification via [AuthRepository].
///
/// On success stores [verificationId] and [resendToken] in providers.
/// On failure shows a [SnackBar] with the error message.
/// [forceResendingToken] is used for OTP resend on the same session.
Future<void> startPhoneVerification({
  required WidgetRef ref,
  required String phoneNumber,
  int? forceResendingToken,
  required void Function(String errorMessage) onError,
  required void Function() onCodeSent,
}) async {
  final repository = ref.read(authRepositoryProvider);
  final notifier = ref.read(authLoadingProvider.notifier);

  notifier.state = true;
  ref.read(phoneNumberProvider.notifier).state = phoneNumber;

  try {
    await repository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (e.g. on Android with instant verification)
        try {
          await repository.signInWithCredential(credential);
        } on Exception catch (_) {
          onError('자동 인증 중 오류가 발생했습니다.');
        } finally {
          notifier.state = false;
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        notifier.state = false;
        onError(_mapAuthError(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        ref.read(verificationIdProvider.notifier).state = verificationId;
        ref.read(resendTokenProvider.notifier).state = resendToken;
        notifier.state = false;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        ref.read(verificationIdProvider.notifier).state = verificationId;
      },
    );
  } on Exception catch (_) {
    notifier.state = false;
    onError('인증 요청 중 오류가 발생했습니다.');
  }
}

/// Signs in with the SMS code and verification ID.
///
/// Returns the signed-in [User] on success.
Future<User?> verifyOtp({
  required WidgetRef ref,
  required String smsCode,
  required void Function(String errorMessage) onError,
}) async {
  final repository = ref.read(authRepositoryProvider);
  final verificationId = ref.read(verificationIdProvider);
  final notifier = ref.read(authLoadingProvider.notifier);

  if (verificationId == null || verificationId.isEmpty) {
    onError('인증 정보가 없습니다. 다시 시도해 주세요.');
    return null;
  }

  notifier.state = true;

  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final cred = await repository.signInWithCredential(credential);
    notifier.state = false;
    return cred.user;
  } on FirebaseAuthException catch (e) {
    notifier.state = false;
    onError(_mapAuthError(e));
    return null;
  } on Exception catch (_) {
    notifier.state = false;
    onError('인증 중 오류가 발생했습니다.');
    return null;
  }
}

String _mapAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-phone-number':
      return '올바른 번호를 입력하세요.';
    case 'invalid-verification-code':
      return '인증번호가 맞지 않습니다. 다시 확인해 주세요.';
    case 'session-expired':
      return '인증번호가 만료되었습니다. 재발송해 주세요.';
    case 'too-many-requests':
      return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해 주세요.';
    case 'network-request-failed':
      return '인터넷 연결을 확인해 주세요.';
    default:
      return e.message ?? '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
  }
}
