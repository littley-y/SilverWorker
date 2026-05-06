import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/job_model.dart';
import 'package:silver_worker_now/providers/job_provider.dart';
import 'package:silver_worker_now/screens/job/job_detail_screen.dart';

JobModel _sampleJob() => JobModel(
      jobId: 'TEST_001',
      source: 'mock',
      title: '아파트 경비원 모집',
      companyName: 'OO아파트 관리사무소',
      companyAddress: '서울 종로구 종로 1',
      locationCode: '11110',
      jobCategory: 'security_management',
      jobCategoryDetail: 'apt_security',
      employmentType: 'part_time',
      salaryType: 'monthly',
      salaryAmount: 2000000,
      workHours: '08:00 ~ 17:00',
      workDays: '월~금',
      workPeriod: '6개월',
      requirements: '경비원 신임교육 이수자',
      benefits: '중식 제공',
      description: '공동주택 출입 및 순찰 관리',
      physicalIntensity: 'moderate',
      physicalBadges: ['standing', 'outdoor'],
      minAge: 60,
      maxAge: 75,
      deadline: DateTime(2026, 6, 30),
      isActive: true,
      rawData: {},
    );

void main() {
  testWidgets('JobDetailScreen shows job details', (tester) async {
    final job = _sampleJob();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_001')
              .overrideWith((ref) => Future.value(job)),
        ],
        child: const MaterialApp(
          home: JobDetailScreen(jobId: 'TEST_001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('공고 상세'), findsOneWidget);
    expect(find.text('아파트 경비원 모집'), findsOneWidget);
    expect(find.text('OO아파트 관리사무소'), findsOneWidget);
    expect(find.text('월 200만원'), findsAtLeastNWidgets(1));
  });

  testWidgets('JobDetailScreen shows work conditions', (tester) async {
    final job = _sampleJob();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_001')
              .overrideWith((ref) => Future.value(job)),
        ],
        child: const MaterialApp(
          home: JobDetailScreen(jobId: 'TEST_001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('근무 조건'), findsOneWidget);
    expect(find.text('서울 종로구 종로 1'), findsOneWidget);
    expect(find.text('08:00 ~ 17:00'), findsOneWidget);
    expect(find.text('월~금'), findsOneWidget);
    expect(find.text('파트타임'), findsOneWidget);
  });

  testWidgets('JobDetailScreen shows safety curation', (tester) async {
    final job = _sampleJob();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_001')
              .overrideWith((ref) => Future.value(job)),
        ],
        child: const MaterialApp(
          home: JobDetailScreen(jobId: 'TEST_001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('업무 강도'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('계속 서있기'), findsOneWidget);
    expect(find.text('야외 근무'), findsOneWidget);
  });

  testWidgets('JobDetailScreen shows fixed apply button', (tester) async {
    final job = _sampleJob();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_001')
              .overrideWith((ref) => Future.value(job)),
        ],
        child: const MaterialApp(
          home: JobDetailScreen(jobId: 'TEST_001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('지원하기'), findsOneWidget);
  });

  testWidgets('JobDetailScreen shows not found message for null job',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('MISSING')
              .overrideWith((ref) => Future.value(null)),
        ],
        child: const MaterialApp(
          home: JobDetailScreen(jobId: 'MISSING'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('공고를 찾을 수 없습니다'), findsOneWidget);
  });

  testWidgets('JobDetailScreen shows hourly salary correctly', (tester) async {
    final hourlyJob = JobModel(
      jobId: 'TEST_HOURLY',
      source: 'mock',
      title: '청소 도우미',
      companyName: 'OO빌딩',
      companyAddress: '서울 중구',
      locationCode: '11140',
      jobCategory: 'cleaning',
      jobCategoryDetail: '',
      employmentType: 'daily',
      salaryType: 'hourly',
      salaryAmount: 12000,
      workHours: '09:00 ~ 17:00',
      workDays: '월~금',
      workPeriod: '3개월',
      requirements: '',
      benefits: '',
      description: '',
      physicalIntensity: 'light',
      physicalBadges: [],
      isActive: true,
      rawData: {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_HOURLY')
              .overrideWith((ref) => Future.value(hourlyJob)),
        ],
        child: const MaterialApp(
          home: JobDetailScreen(jobId: 'TEST_HOURLY'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('시급 12,000원'), findsAtLeastNWidgets(1));
  });

  testWidgets('JobDetailScreen shows daily salary correctly', (tester) async {
    final dailyJob = JobModel(
      jobId: 'TEST_DAILY',
      source: 'mock',
      title: '건설 현장',
      companyName: 'OO건설',
      companyAddress: '서울 용산구',
      locationCode: '11170',
      jobCategory: 'simple_labor',
      jobCategoryDetail: '',
      employmentType: 'daily',
      salaryType: 'daily',
      salaryAmount: 80000,
      workHours: '08:00 ~ 17:00',
      workDays: '월~토',
      workPeriod: '1개월',
      requirements: '',
      benefits: '',
      description: '',
      physicalIntensity: 'heavy',
      physicalBadges: [],
      isActive: true,
      rawData: {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_DAILY')
              .overrideWith((ref) => Future.value(dailyJob)),
        ],
        child: const MaterialApp(
          home: JobDetailScreen(jobId: 'TEST_DAILY'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('일급 80,000원'), findsAtLeastNWidgets(1));
  });
}
