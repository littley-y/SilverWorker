import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/constants/address_data.dart';

void main() {
  group('AddressData', () {
    test('sidoList should not be empty', () {
      expect(AddressData.sidoList, isNotEmpty);
    });

    test('sidoList contains 서울특별시', () {
      expect(AddressData.sidoList, contains('서울특별시'));
    });

    test('sigunguList returns districts for known sido', () {
      final seoulDistricts = AddressData.sigunguList('서울특별시');
      expect(seoulDistricts, isNotEmpty);
      expect(seoulDistricts, contains('종로구'));
    });

    test('sigunguList returns empty list for unknown sido', () {
      final districts = AddressData.sigunguList('Unknown');
      expect(districts, isEmpty);
    });

    test('all sido entries have at least one sigungu', () {
      for (final sido in AddressData.sidoList) {
        final districts = AddressData.sigunguList(sido);
        expect(districts, isNotEmpty, reason: '$sido should have districts');
      }
    });
  });
}
