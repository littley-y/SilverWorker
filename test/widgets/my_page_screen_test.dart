import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/application_model.dart';
import 'package:silver_worker_now/models/user_model.dart';
import 'package:silver_worker_now/providers/application_provider.dart';
import 'package:silver_worker_now/providers/auth_provider.dart';
import 'package:silver_worker_now/repositories/application_repository.dart';
import 'package:silver_worker_now/repositories/auth_repository.dart';
import 'package:silver_worker_now/screens/mypage/my_page_screen.dart';

import '../helpers/test_doubles.dart';

class _MockAuthRepository extends Fake implements AuthRepository {
  final User? _user;
  int signOutCallCount = 0;

  _MockAuthRepository({User? user}) : _user = user;

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(_user);

  @override
  Future<void> signOut() async {
    signOutCallCount++;
  }

  @override
  Future<UserModel?> fetchProfile(String userId) async {
    return UserModel(
      userId: userId,
      phoneNumber: '+821012345678',
      name: '김은빛',
      gender: 'male',
      address: const Address(sido: '서울', sigungu: '종로구'),
      careerSummary: '10년 경비 경력 보유',
      physicalConditions: const <String>[],
      preferredJobTypes: const <String>[],
      preferredLocations: const <String>[],
      isPushEnabled: true,
    );
  }
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
  testWidgets('MyPageScreen shows profile name, address, career summary',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(user: MockUser()),
          ),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: MyPageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('김은빛'), findsOneWidget);
    expect(find.text('서울 종로구'), findsOneWidget);
    expect(find.text('10년 경비 경력 보유'), findsOneWidget);
  });

  testWidgets('MyPageScreen shows application count badge', (tester) async {
    final applications = [
      ApplicationModel(
        applicationId: 'app1',
        jobId: 'job1',
        jobTitle: '경비원',
        companyName: 'OO아파트',
        selfIntroduction: '열심히 하겠습니다',
        status: 'submitted',
        submittedAt: DateTime(2026, 5, 1),
      ),
      ApplicationModel(
        applicationId: 'app2',
        jobId: 'job2',
        jobTitle: '청소원',
        companyName: 'XX빌딩',
        selfIntroduction: '성실합니다',
        status: 'reviewing',
        submittedAt: DateTime(2026, 5, 2),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(user: MockUser()),
          ),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(applications: applications),
          ),
        ],
        child: const MaterialApp(
          home: MyPageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('총 2건 지원'), findsOneWidget);
  });

  testWidgets('MyPageScreen shows menu items', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(user: MockUser()),
          ),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: MyPageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('지원 내역'), findsOneWidget);
    expect(find.text('찜한 공고'), findsOneWidget);
    expect(find.text('알림 설정'), findsOneWidget);
  });

  testWidgets('MyPageScreen shows logout button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _MockAuthRepository(user: MockUser()),
          ),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: MyPageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('로그아웃'), findsOneWidget);
  });

  testWidgets('tapping logout shows confirmation dialog and calls signOut',
      (tester) async {
    final mockRepo = _MockAuthRepository(user: MockUser());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: MyPageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();

    expect(find.text('로그아웃 하시겠습니까?'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);

    // 다이얼로그 actions 내 "로그아웃" 액션 버튼만 카운트
    final dialogActions = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    );
    final dialogLogoutAction = find.descendant(
      of: dialogActions,
      matching: find.text('로그아웃'),
    );
    expect(dialogLogoutAction, findsOneWidget);

    // 로그아웃 액션 탭 → signOut 호출 확인
    await tester.tap(dialogLogoutAction);
    await tester.pumpAndSettle();

    expect(mockRepo.signOutCallCount, 1);
  });

  testWidgets('MyPageScreen shows loading while profile loads', (tester) async {
    final mockRepo = _SlowAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
          applicationRepositoryProvider.overrideWithValue(
            _MockApplicationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: MyPageScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Allow the delayed future to complete so no timer is pending.
    await tester.pump(const Duration(milliseconds: 150));
  });
}

class _SlowAuthRepository extends Fake implements AuthRepository {
  @override
  User? get currentUser => MockUser();

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(currentUser);

  @override
  Future<UserModel?> fetchProfile(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return UserModel(
      userId: userId,
      phoneNumber: '+821012345678',
      name: '김은빛',
      gender: 'male',
      address: const Address(sido: '서울', sigungu: '종로구'),
      careerSummary: '10년 경비 경력 보유',
      physicalConditions: const <String>[],
      preferredJobTypes: const <String>[],
      preferredLocations: const <String>[],
      isPushEnabled: true,
    );
  }
}
