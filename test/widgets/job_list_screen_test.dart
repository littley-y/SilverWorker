import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/job_model.dart';
import 'package:silver_worker_now/providers/job_provider.dart';
import 'package:silver_worker_now/screens/job/job_list_screen.dart';

void main() {
  testWidgets('JobListScreen shows empty state when no jobs match filter',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobListProvider.overrideWith((ref) => Future.value(<JobModel>[])),
        ],
        child: const MaterialApp(
          home: JobListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('해당 조건의 공고가 없습니다'), findsOneWidget);
    expect(find.text('필터 초기화'), findsOneWidget);
  });

  testWidgets('JobListScreen shows error state with retry button',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobListProvider
              .overrideWith((ref) => Future.error(Exception('Network error'))),
        ],
        child: const MaterialApp(
          home: JobListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('공고를 불러올 수 없습니다'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('JobListScreen shows job cards when data is available',
      (tester) async {
    final jobs = [
      JobModel(
        jobId: 'TEST_001',
        source: 'mock',
        title: '아파트 경비원 모집',
        companyName: 'OO아파트 관리사무소',
        companyAddress: '서울 종로구',
        locationCode: '11110',
        jobCategory: 'security_management',
        jobCategoryDetail: '',
        employmentType: 'part_time',
        salaryType: 'monthly',
        salaryAmount: 2000000,
        workHours: '08:00 ~ 17:00',
        workDays: '월~금',
        workPeriod: '6개월',
        requirements: '',
        benefits: '',
        description: '',
        physicalIntensity: 'moderate',
        physicalBadges: [],
        isActive: true,
        rawData: {},
        deadline: DateTime(2026, 06, 30),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobListProvider.overrideWith((ref) => Future.value(jobs)),
        ],
        child: const MaterialApp(
          home: JobListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('아파트 경비원 모집'), findsOneWidget);
    expect(find.text('OO아파트 관리사무소'), findsOneWidget);
  });

  testWidgets('JobListScreen shows AppBar with correct title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobListProvider.overrideWith((ref) => Future.value(<JobModel>[])),
        ],
        child: const MaterialApp(
          home: JobListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('은빛일자리'), findsOneWidget);
  });

  testWidgets('JobListScreen shows FilterBar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobListProvider.overrideWith((ref) => Future.value(<JobModel>[])),
        ],
        child: const MaterialApp(
          home: JobListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('지역'), findsOneWidget);
    expect(find.text('직종'), findsOneWidget);
    expect(find.text('종로구'), findsOneWidget);
  });
}
