import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

/// Repository for job application operations.
class ApplicationRepository {
  final FirebaseFirestore _firestore;

  ApplicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches all applications for a given user.
  Future<List<ApplicationModel>> fetchApplications(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ApplicationModel.fromJson(doc.data()))
        .toList();
  }

  /// Submits a new application.
  Future<void> submitApplication(ApplicationModel application) async {
    await _firestore
        .collection('users')
        .doc(application.userId)
        .collection('applications')
        .doc(application.id)
        .set(application.toJson());
  }
}
