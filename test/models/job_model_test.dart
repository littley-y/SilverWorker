import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/job_model.dart';

void main() {
  group('JobModel.fromJson', () {
    test('parses jobId from document data', () {
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

      expect(job.jobId, 'MOCK_001');
      expect(job.title, '아파트 경비원 모집');
      expect(job.physicalBadges, ['standing', 'outdoor']);
      expect(job.isActive, isTrue);
    });

    test(
        'jobId is injected from doc.id when Firestore document lacks jobId field',
        () {
      // Simulates Firestore document where jobId was popped before upload
      // and doc.id is injected at the Repository layer:
      //   JobModel.fromJson({...data, 'jobId': doc.id})
      final firestoreData = <String, dynamic>{
        'source': 'mock',
        'title': '시설 경비원 모집',
        'companyName': '시설 관리단',
        'companyAddress': '서울 용산구 한강대로 203',
        'locationCode': '11170',
        'jobCategory': 'security_management',
        'jobCategoryDetail': 'apt_security',
        'employmentType': 'full_time',
        'salaryType': 'monthly',
        'salaryAmount': 2100000,
        'workHours': '09:00 ~ 18:00',
        'workDays': '월~토',
        'workPeriod': '12개월',
        'requirements': '경비업무 경험자',
        'benefits': '4대보험, 퇴직금',
        'description': '시설물 순찰 및 보안 점검',
        'physicalIntensity': 'moderate',
        'physicalBadges': <String>['standing'],
        'minAge': 60,
        'maxAge': 75,
        'deadline': '2026-07-15T00:00:00Z',
        'isActive': true,
        'rawData': <String, dynamic>{},
      };

      const docId = 'MOCK_005';
      final job = JobModel.fromJson({...firestoreData, 'jobId': docId});

      expect(job.jobId, 'MOCK_005');
    });

    test('falls back to empty string when jobId is missing entirely', () {
      final json = <String, dynamic>{
        'source': 'mock',
        'title': 'test',
        'companyName': 'test',
        'companyAddress': 'test',
        'locationCode': '11110',
        'jobCategory': 'cleaning',
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
        'physicalBadges': <String>[],
        'isActive': true,
        'rawData': <String, dynamic>{},
      };

      final job = JobModel.fromJson(json);
      expect(job.jobId, '');
    });
  });
}
