import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/job_model.dart';
import 'package:silver_worker_now/widgets/job_card.dart';

void main() {
  late JobModel sampleJob;

  setUp(() {
    sampleJob = JobModel(
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
      physicalBadges: ['standing'],
      minAge: 60,
      maxAge: 75,
      deadline: DateTime(2026, 06, 30),
      isActive: true,
      rawData: {},
    );
  });

  testWidgets('JobCard renders title and company name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: sampleJob, onTap: () {}),
        ),
      ),
    );

    expect(find.text('아파트 경비원 모집'), findsOneWidget);
    expect(find.text('OO아파트 관리사무소'), findsOneWidget);
  });

  testWidgets('JobCard renders monthly salary as "월 N만원"', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: sampleJob, onTap: () {}),
        ),
      ),
    );

    // 2000000 → 월 200만원
    expect(find.text('월 200만원'), findsOneWidget);
  });

  testWidgets('JobCard renders hourly salary as "시급 N,NNN원"', (tester) async {
    final hourlyJob = JobModel(
      jobId: 'TEST_002',
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
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: hourlyJob, onTap: () {}),
        ),
      ),
    );

    expect(find.text('시급 12,000원'), findsOneWidget);
  });

  testWidgets('JobCard renders daily salary as "일급 N,NNN원"', (tester) async {
    final dailyJob = JobModel(
      jobId: 'TEST_003',
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
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: dailyJob, onTap: () {}),
        ),
      ),
    );

    expect(find.text('일급 80,000원'), findsOneWidget);
  });

  testWidgets('JobCard renders employment type chip in Korean', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: sampleJob, onTap: () {}),
        ),
      ),
    );

    expect(find.text('파트타임'), findsOneWidget);
  });

  testWidgets('JobCard renders D-n deadline format', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: sampleJob, onTap: () {}),
        ),
      ),
    );

    // deadline is 2026-06-30, so D-something should appear
    final deadlineFinder = find.textContaining('D-');
    expect(deadlineFinder, findsOneWidget);
  });

  testWidgets('JobCard renders intensity badge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: sampleJob, onTap: () {}),
        ),
      ),
    );

    // moderate → "보통"
    expect(find.text('보통'), findsOneWidget);
  });

  testWidgets('JobCard calls onTap when tapped', (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(
            job: sampleJob,
            onTap: () => tapCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('아파트 경비원 모집'));
    expect(tapCount, 1);
  });

  testWidgets('JobCard renders "마감" for past deadline', (tester) async {
    final closedJob = sampleJob.copyWith(
      deadline: DateTime(2025, 01, 01),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: closedJob, onTap: () {}),
        ),
      ),
    );

    expect(find.text('마감'), findsOneWidget);
  });

  testWidgets('JobCard renders "상시" for null deadline', (tester) async {
    // copyWith cannot set nullable fields to null (uses ?? for defaults),
    // so construct directly to set deadline = null.
    final openJob = JobModel(
      jobId: sampleJob.jobId,
      source: sampleJob.source,
      title: sampleJob.title,
      companyName: sampleJob.companyName,
      companyAddress: sampleJob.companyAddress,
      locationCode: sampleJob.locationCode,
      jobCategory: sampleJob.jobCategory,
      jobCategoryDetail: sampleJob.jobCategoryDetail,
      employmentType: sampleJob.employmentType,
      salaryType: sampleJob.salaryType,
      salaryAmount: sampleJob.salaryAmount,
      workHours: sampleJob.workHours,
      workDays: sampleJob.workDays,
      workPeriod: sampleJob.workPeriod,
      requirements: sampleJob.requirements,
      benefits: sampleJob.benefits,
      description: sampleJob.description,
      physicalIntensity: sampleJob.physicalIntensity,
      physicalBadges: sampleJob.physicalBadges,
      isActive: sampleJob.isActive,
      rawData: sampleJob.rawData,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobCard(job: openJob, onTap: () {}),
        ),
      ),
    );

    expect(find.text('상시'), findsOneWidget);
  });
}
