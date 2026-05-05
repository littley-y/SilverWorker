import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore;

  ApplicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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

  Future<void> submitApplication({
    required String jobId,
    required String selfIntroduction,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final existing = await _firestore
        .collection('users')
        .doc(uid)
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('already_applied');
    }

    final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) {
      throw Exception('job_not_found');
    }

    final jobData = jobDoc.data()!;
    final isActive = jobData['isActive'] as bool? ?? true;
    if (!isActive) {
      throw Exception('job_closed');
    }

    final deadline = jobData['deadline'] as Timestamp?;
    if (deadline != null && deadline.toDate().isBefore(DateTime.now())) {
      throw Exception('job_closed');
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('applications')
        .add({
      'jobId': jobId,
      'jobTitle': jobData['title'] as String? ?? '',
      'companyName': jobData['companyName'] as String? ?? '',
      'selfIntroduction': selfIntroduction,
      'status': 'submitted',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
