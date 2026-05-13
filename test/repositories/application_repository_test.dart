import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/repositories/application_repository.dart';

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'test_uid';
}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final User? _user;

  _FakeFirebaseAuth([this._user]);

  @override
  User? get currentUser => _user;
}

void main() {
  group('ApplicationRepository.hasApplied', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ApplicationRepository repo;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repo = ApplicationRepository(
        firestore: fakeFirestore,
        auth: _FakeFirebaseAuth(_FakeUser()),
      );
    });

    test('returns true when application document exists', () async {
      await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('applications')
          .doc('job_001')
          .set(<String, dynamic>{
        'jobId': 'job_001',
        'status': 'submitted',
      });

      final result = await repo.hasApplied('job_001');
      expect(result, isTrue);
    });

    test('returns false when application document does not exist', () async {
      final result = await repo.hasApplied('job_999');
      expect(result, isFalse);
    });
  });

  group('ApplicationRepository.submitApplication', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ApplicationRepository repo;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repo = ApplicationRepository(
        firestore: fakeFirestore,
        auth: _FakeFirebaseAuth(_FakeUser()),
      );
    });

    test('saves application when job is open and not yet applied', () async {
      await fakeFirestore
          .collection('jobs')
          .doc('job_001')
          .set(<String, dynamic>{
        'title': '아파트 경비원',
        'companyName': 'OO아파트',
        'isActive': true,
        'deadline': null,
      });

      await repo.submitApplication(
        jobId: 'job_001',
        selfIntroduction: '열심히 하겠습니다.',
      );

      final doc = await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('applications')
          .doc('job_001')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()?['jobId'], 'job_001');
      expect(doc.data()?['jobTitle'], '아파트 경비원');
      expect(doc.data()?['companyName'], 'OO아파트');
      expect(doc.data()?['selfIntroduction'], '열심히 하겠습니다.');
      expect(doc.data()?['status'], 'submitted');
    });

    test('throws AlreadyAppliedException when already applied', () async {
      await fakeFirestore
          .collection('jobs')
          .doc('job_001')
          .set(<String, dynamic>{
        'title': 'test',
        'companyName': 'test',
        'isActive': true,
      });
      await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('applications')
          .doc('job_001')
          .set(<String, dynamic>{'jobId': 'job_001'});

      expect(
        () => repo.submitApplication(
          jobId: 'job_001',
          selfIntroduction: 'test',
        ),
        throwsA(isA<AlreadyAppliedException>()),
      );
    });

    test('throws JobNotFoundException when job does not exist', () async {
      expect(
        () => repo.submitApplication(
          jobId: 'job_missing',
          selfIntroduction: 'test',
        ),
        throwsA(isA<JobNotFoundException>()),
      );
    });

    test('throws JobClosedException when job is inactive', () async {
      await fakeFirestore
          .collection('jobs')
          .doc('job_001')
          .set(<String, dynamic>{
        'title': 'test',
        'companyName': 'test',
        'isActive': false,
      });

      expect(
        () => repo.submitApplication(
          jobId: 'job_001',
          selfIntroduction: 'test',
        ),
        throwsA(isA<JobClosedException>()),
      );
    });

    test('throws JobClosedException when deadline has passed', () async {
      await fakeFirestore
          .collection('jobs')
          .doc('job_001')
          .set(<String, dynamic>{
        'title': 'test',
        'companyName': 'test',
        'isActive': true,
        'deadline': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      });

      expect(
        () => repo.submitApplication(
          jobId: 'job_001',
          selfIntroduction: 'test',
        ),
        throwsA(isA<JobClosedException>()),
      );
    });
  });
}
