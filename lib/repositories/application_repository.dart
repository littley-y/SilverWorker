import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';

sealed class ApplicationException implements Exception {}

class AlreadyAppliedException extends ApplicationException {}

class JobClosedException extends ApplicationException {}

class JobNotFoundException extends ApplicationException {}

class ApplicationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ApplicationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<List<ApplicationModel>> fetchApplications(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('applications')
        .orderBy('submittedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ApplicationModel.fromJson(doc.data()))
        .toList();
  }

  Future<bool> hasApplied(String jobId) async {
    final uid = _auth.currentUser!.uid;
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('applications')
        .doc(jobId)
        .get();
    return snap.exists;
  }

  Future<void> submitApplication({
    required String jobId,
    required String selfIntroduction,
  }) async {
    final uid = _auth.currentUser!.uid;
    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('applications')
        .doc(jobId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) throw AlreadyAppliedException();

      final jobDoc = await tx.get(_firestore.collection('jobs').doc(jobId));
      if (!jobDoc.exists) throw JobNotFoundException();

      final jobData = jobDoc.data()!;
      final isActive = jobData['isActive'] as bool? ?? true;
      if (!isActive) throw JobClosedException();

      final deadline = jobData['deadline'] as Timestamp?;
      if (deadline != null && deadline.toDate().isBefore(DateTime.now())) {
        throw JobClosedException();
      }

      tx.set(ref, {
        'jobId': jobId,
        'jobTitle': jobData['title'] as String? ?? '',
        'companyName': jobData['companyName'] as String? ?? '',
        'selfIntroduction': selfIntroduction,
        'status': 'submitted',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
