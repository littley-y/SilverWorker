import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/constants/app_colors.dart';
import 'package:silver_worker_now/models/application_model.dart';
import 'package:silver_worker_now/providers/application_provider.dart';
import 'package:silver_worker_now/providers/auth_provider.dart';
import 'package:silver_worker_now/repositories/application_repository.dart';
import 'package:silver_worker_now/repositories/auth_repository.dart';
import 'package:silver_worker_now/screens/mypage/application_list_screen.dart';

import '../helpers/test_doubles.dart';

class _MockAuthRepository extends Fake implements AuthRepository {
  @override
  User? get currentUser => MockUser();

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(currentUser);
}

class _MockApplicationRepository extends Fake implements ApplicationRepository {
  final List<ApplicationModel> _applications;

  _MockApplicationRepository({List<ApplicationModel>? applications})
      : _applications = applications ?? const <ApplicationModel>[];

  @override
  Future<List<ApplicationModel>> fetchApplications(String userId) async {
    return _applications;
  }
}

void main() {
  testWidgets('ApplicationListScreen shows empty state when no applications',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ApplicationListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('지원 내역'), findsOneWidget);
    expect(find.text('아직 지원한 공고가 없습니다'), findsOneWidget);
  });

  testWidgets('ApplicationListScreen shows application cards', (tester) async {
    final applications = [
      ApplicationModel(
        applicationId: 'app1',
        jobId: 'job1',
        jobTitle: '아파트 경비원 모집',
        companyName: 'OO아파트 관리사무소',
        selfIntroduction: '열심히 하겠습니다',
        status: 'submitted',
        submittedAt: DateTime(2026, 5, 1),
      ),
      ApplicationModel(
        applicationId: 'app2',
        jobId: 'job2',
        jobTitle: '사무실 청소원',
        companyName: 'XX빌딩 관리',
        selfIntroduction: '성실합니다',
        status: 'accepted',
        submittedAt: DateTime(2026, 5, 3),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(applications: applications),
          ),
        ],
        child: const MaterialApp(
          home: ApplicationListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('아파트 경비원 모집'), findsOneWidget);
    expect(find.text('OO아파트 관리사무소'), findsOneWidget);
    expect(find.text('사무실 청소원'), findsOneWidget);
    expect(find.text('XX빌딩 관리'), findsOneWidget);
    expect(find.text('05월 01일'), findsOneWidget);
    expect(find.text('05월 03일'), findsOneWidget);
  });

  testWidgets('ApplicationCard shows correct status badge colors',
      (tester) async {
    final applications = [
      ApplicationModel(
        applicationId: 'app1',
        jobId: 'job1',
        jobTitle: '접수 테스트',
        companyName: 'A사',
        selfIntroduction: 'test',
        status: 'submitted',
        submittedAt: DateTime(2026, 5, 1),
      ),
      ApplicationModel(
        applicationId: 'app2',
        jobId: 'job2',
        jobTitle: '검토 중 테스트',
        companyName: 'B사',
        selfIntroduction: 'test',
        status: 'reviewing',
        submittedAt: DateTime(2026, 5, 2),
      ),
      ApplicationModel(
        applicationId: 'app3',
        jobId: 'job3',
        jobTitle: '합격 테스트',
        companyName: 'C사',
        selfIntroduction: 'test',
        status: 'accepted',
        submittedAt: DateTime(2026, 5, 3),
      ),
      ApplicationModel(
        applicationId: 'app4',
        jobId: 'job4',
        jobTitle: '불합격 테스트',
        companyName: 'D사',
        selfIntroduction: 'test',
        status: 'rejected',
        submittedAt: DateTime(2026, 5, 4),
      ),
      ApplicationModel(
        applicationId: 'app5',
        jobId: 'job5',
        jobTitle: '취소됨 테스트',
        companyName: 'E사',
        selfIntroduction: 'test',
        status: 'cancelled',
        submittedAt: DateTime(2026, 5, 5),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(applications: applications),
          ),
        ],
        child: const MaterialApp(
          home: ApplicationListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Status labels
    expect(find.text('접수'), findsOneWidget);
    expect(find.text('검토 중'), findsOneWidget);
    expect(find.text('합격'), findsOneWidget);
    expect(find.text('불합격'), findsOneWidget);
    expect(find.text('취소됨'), findsOneWidget);

    // Verify badge colors by finding Text widgets with specific colors
    final submittedText = tester.widget<Text>(find.text('접수'));
    final reviewingText = tester.widget<Text>(find.text('검토 중'));
    final acceptedText = tester.widget<Text>(find.text('합격'));
    final rejectedText = tester.widget<Text>(find.text('불합격'));
    final cancelledText = tester.widget<Text>(find.text('취소됨'));

    expect(submittedText.style?.color, AppColors.statusSubmitted);
    expect(reviewingText.style?.color, AppColors.statusReviewing);
    expect(acceptedText.style?.color, AppColors.statusAccepted);
    expect(rejectedText.style?.color, AppColors.statusRejected);
    expect(cancelledText.style?.color, AppColors.statusCancelled);
  });

  testWidgets('ApplicationListScreen shows error state', (tester) async {
    final mockRepo = _ErrorApplicationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
          applicationRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: ApplicationListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('지원 내역을 불러오는 중 오류가 발생했습니다.'),
      findsOneWidget,
    );
  });

  testWidgets('ApplicationListScreen shows loading state', (tester) async {
    final mockRepo = _SlowApplicationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
          applicationRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: ApplicationListScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Allow the delayed future to complete so no timer is pending.
    await tester.pump(const Duration(milliseconds: 150));
  });
}

class _ErrorApplicationRepository extends Fake
    implements ApplicationRepository {
  @override
  Future<List<ApplicationModel>> fetchApplications(String userId) async {
    throw Exception('Network error');
  }
}

class _SlowApplicationRepository extends Fake implements ApplicationRepository {
  @override
  Future<List<ApplicationModel>> fetchApplications(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return <ApplicationModel>[];
  }
}
