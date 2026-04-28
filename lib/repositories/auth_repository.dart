import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Repository for user authentication and profile operations.
class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Current authenticated user.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Starts phone number verification.
  ///
  /// [phoneNumber] must include country code (e.g. +821012345678).
  /// [forceResendingToken] is used for resending OTP on the same session.
  /// Callbacks are wired by the caller (UI layer).
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(PhoneAuthCredential credential)
        verificationCompleted,
    required void Function(FirebaseAuthException error) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Signs in with a phone auth credential.
  Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    return _auth.signInWithCredential(credential);
  }

  /// Fetches a user profile by UID.
  Future<UserModel?> fetchProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()!);
  }

  /// Creates a new user profile after initial registration.
  ///
  /// Uses [FieldValue.serverTimestamp] for created/updated timestamps.
  ///
  /// Fields initialized as empty (gender, physicalConditions, etc.) are
  /// placeholders for future spec implementations (spec_03~07). They are
  /// omitted from the initial document to avoid "empty string" ambiguity
  /// in downstream logic. Firestore merge is not needed because this is
  /// always a new document creation.
  Future<void> createProfile({
    required String uid,
    required String phoneNumber,
    required String name,
    required String sido,
    required String sigungu,
    required String careerSummary,
  }) async {
    await _firestore.collection('users').doc(uid).set(<String, dynamic>{
      'userId': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'address': <String, String>{'sido': sido, 'sigungu': sigungu},
      'careerSummary': careerSummary,
      'isPushEnabled': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
