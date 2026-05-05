import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/job_model.dart';
import 'package:silver_worker_now/providers/job_provider.dart';
import 'package:silver_worker_now/screens/application/application_form_screen.dart';

JobModel _sampleJob() => JobModel(
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
    );

void main() {
  testWidgets('ApplicationFormScreen shows job summary and textarea', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_001').overrideWith((ref) => Future.value(_sampleJob())),
        ],
        child: const MaterialApp(
          home: ApplicationFormScreen(jobId: 'TEST_001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('지원서 작성'), findsOneWidget);
    expect(find.text('아파트 경비원 모집'), findsOneWidget);
    expect(find.text('OO아파트 관리사무소'), findsOneWidget);
    expect(find.text('자기소개'), findsOneWidget);
    expect(find.text('지원하기'), findsOneWidget);
  });

  testWidgets('ApplicationFormScreen shows textarea with 200 char limit', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobDetailProvider('TEST_001').overrideWith((ref) => Future.value(_sampleJob())),
        ],
        child: const MaterialApp(
          home: ApplicationFormScreen(jobId: 'TEST_001'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.maxLength, 200);
    expect(textField.maxLines, 5);
  });
}
