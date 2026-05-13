import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/job_filter.dart';

void main() {
  group('JobFilter', () {
    test('empty filter has all null fields', () {
      const filter = JobFilter.empty;

      expect(filter.locationCode, isNull);
      expect(filter.jobCategory, isNull);
      expect(filter.employmentType, isNull);
      expect(filter.physicalIntensity, isNull);
      expect(filter.isActive, isNull);
    });

    test('constructs with all fields', () {
      const filter = JobFilter(
        locationCode: '11110',
        jobCategory: 'security_management',
        employmentType: 'part_time',
        physicalIntensity: 'light',
        isActive: true,
      );

      expect(filter.locationCode, '11110');
      expect(filter.jobCategory, 'security_management');
      expect(filter.employmentType, 'part_time');
      expect(filter.physicalIntensity, 'light');
      expect(filter.isActive, isTrue);
    });

    group('copyWith', () {
      test('updates a single field', () {
        const filter = JobFilter(locationCode: '11110');
        final updated = filter.copyWith(jobCategory: 'cleaning');

        expect(updated.locationCode, '11110');
        expect(updated.jobCategory, 'cleaning');
        expect(updated.employmentType, isNull);
      });

      test('clears a field when set to null', () {
        const filter = JobFilter(
          locationCode: '11110',
          jobCategory: 'security_management',
        );
        final updated = filter.copyWith(locationCode: null);

        expect(updated.locationCode, isNull);
        expect(updated.jobCategory, 'security_management');
      });

      test('leaves other fields unchanged when using sentinel', () {
        const filter = JobFilter(
          locationCode: '11110',
          jobCategory: 'security_management',
        );
        final updated = filter.copyWith();

        expect(updated.locationCode, '11110');
        expect(updated.jobCategory, 'security_management');
      });

      test('combines multiple filter conditions', () {
        const filter = JobFilter(
          locationCode: '11110',
          jobCategory: 'security_management',
        );
        final updated = filter.copyWith(
          employmentType: 'part_time',
          physicalIntensity: 'light',
        );

        expect(updated.locationCode, '11110');
        expect(updated.jobCategory, 'security_management');
        expect(updated.employmentType, 'part_time');
        expect(updated.physicalIntensity, 'light');
      });

      test('overwrites existing field with new value', () {
        const filter = JobFilter(locationCode: '11110');
        final updated = filter.copyWith(locationCode: '11170');

        expect(updated.locationCode, '11170');
      });
    });
  });
}
