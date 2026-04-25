import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository for user authentication and profile operations.
class AuthRepository {
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches a user profile by UID.
  Future<UserModel?> fetchProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()!);
  }

  /// Creates or updates a user profile.
  Future<void> saveProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toJson());
  }
}
