import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/job_model.dart';

JobModel _jobWithIntensity(String intensity) {
  return JobModel(
    jobId: '1',
    source: 'mock',
    title: 'test',
    companyName: 'test',
    companyAddress: 'test',
    locationCode: '11110',
    jobCategory: 'security_management',
    jobCategoryDetail: 'test',
    employmentType: 'part_time',
    salaryType: 'monthly',
    salaryAmount: 1000000,
    workHours: '09:00 ~ 18:00',
    workDays: '월~금',
    workPeriod: '3개월',
    requirements: '',
    benefits: '',
    description: '',
    physicalIntensity: intensity,
    physicalBadges: const <String>[],
    isActive: true,
    rawData: const <String, dynamic>{},
  );
}

void main() {
  group('JobModel.physicalIntensityLabel', () {
    test('returns 가벼움 for light', () {
      expect(_jobWithIntensity('light').physicalIntensityLabel, '가벼움');
    });

    test('returns 보통 for moderate', () {
      expect(_jobWithIntensity('moderate').physicalIntensityLabel, '보통');
    });

    test('returns 무거움 for heavy', () {
      expect(_jobWithIntensity('heavy').physicalIntensityLabel, '무거움');
    });

    test('returns 알 수 없음 for unknown intensity', () {
      expect(_jobWithIntensity('unknown').physicalIntensityLabel, '알 수 없음');
    });
  });

  group('JobModel.physicalBadges', () {
    test('parses standing and outdoor badges from JSON', () {
      final json = <String, dynamic>{
        'jobId': 'MOCK_001',
        'source': 'mock',
        'title': '아파트 경비원 모집',
        'companyName': 'OO아파트 관리사무소',
        'companyAddress': '서울 종로구 종로 1',
        'locationCode': '11110',
        'jobCategory': 'security_management',
        'jobCategoryDetail': 'apt_security',
        'employmentType': 'part_time',
        'salaryType': 'monthly',
        'salaryAmount': 2000000,
        'workHours': '08:00 ~ 17:00',
        'workDays': '월~금',
        'workPeriod': '6개월',
        'requirements': '경비원 신임교육 이수자',
        'benefits': '중식 제공',
        'description': '공동주택 출입 및 순찰 관리',
        'physicalIntensity': 'moderate',
        'physicalBadges': <String>['standing', 'outdoor'],
        'minAge': 60,
        'maxAge': 75,
        'deadline': '2026-06-30T00:00:00Z',
        'isActive': true,
        'rawData': <String, dynamic>{},
      };

      final job = JobModel.fromJson(json);

      expect(job.physicalBadges, ['standing', 'outdoor']);
    });

    test('defaults to empty list when physicalBadges is missing', () {
      final json = <String, dynamic>{
        'jobId': '1',
        'source': 'mock',
        'title': 'test',
        'companyName': 'test',
        'companyAddress': 'test',
        'locationCode': '11110',
        'jobCategory': 'security_management',
        'jobCategoryDetail': 'test',
        'employmentType': 'part_time',
        'salaryType': 'monthly',
        'salaryAmount': 1000000,
        'workHours': '09:00 ~ 18:00',
        'workDays': '월~금',
        'workPeriod': '3개월',
        'requirements': '',
        'benefits': '',
        'description': '',
        'physicalIntensity': 'light',
        'isActive': true,
        'rawData': <String, dynamic>{},
      };

      final job = JobModel.fromJson(json);

      expect(job.physicalBadges, isEmpty);
    });

    test('defaults to empty list when physicalBadges is null', () {
      final json = <String, dynamic>{
        'jobId': '1',
        'source': 'mock',
        'title': 'test',
        'companyName': 'test',
        'companyAddress': 'test',
        'locationCode': '11110',
        'jobCategory': 'security_management',
        'jobCategoryDetail': 'test',
        'employmentType': 'part_time',
        'salaryType': 'monthly',
        'salaryAmount': 1000000,
        'workHours': '09:00 ~ 18:00',
        'workDays': '월~금',
        'workPeriod': '3개월',
        'requirements': '',
        'benefits': '',
        'description': '',
        'physicalIntensity': 'light',
        'physicalBadges': null,
        'isActive': true,
        'rawData': <String, dynamic>{},
      };

      final job = JobModel.fromJson(json);

      expect(job.physicalBadges, isEmpty);
    });

    test('handles all 6 known badge types', () {
      final json = <String, dynamic>{
        'jobId': '1',
        'source': 'mock',
        'title': 'test',
        'companyName': 'test',
        'companyAddress': 'test',
        'locationCode': '11110',
        'jobCategory': 'security_management',
        'jobCategoryDetail': 'test',
        'employmentType': 'part_time',
        'salaryType': 'monthly',
        'salaryAmount': 1000000,
        'workHours': '09:00 ~ 18:00',
        'workDays': '월~금',
        'workPeriod': '3개월',
        'requirements': '',
        'benefits': '',
        'description': '',
        'physicalIntensity': 'heavy',
        'physicalBadges': <String>[
          'standing',
          'sitting',
          'heavy_lifting',
          'outdoor',
          'repetitive',
          'stairs',
        ],
        'isActive': true,
        'rawData': <String, dynamic>{},
      };

      final job = JobModel.fromJson(json);

      expect(job.physicalBadges, [
        'standing',
        'sitting',
        'heavy_lifting',
        'outdoor',
        'repetitive',
        'stairs',
      ]);
    });
  });
}
