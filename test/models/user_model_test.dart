import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses address correctly', () {
      final json = <String, dynamic>{
        'userId': 'uid123',
        'phoneNumber': '+821012345678',
        'name': '김OO',
        'address': <String, String>{
          'sido': '서울특별시',
          'sigungu': '종로구',
        },
        'careerSummary': '30년 경비 경력',
        'gender': 'male',
        'physicalConditions': const <String>[],
        'preferredJobTypes': const <String>[],
        'preferredLocations': const <String>[],
        'isPushEnabled': true,
      };

      final user = UserModel.fromJson(json);

      expect(user.userId, 'uid123');
      expect(user.name, '김OO');
      expect(user.address.sido, '서울특별시');
      expect(user.address.sigungu, '종로구');
      expect(user.address.display, '서울특별시 종로구');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{
        'userId': 'uid456',
        'phoneNumber': '+821098765432',
        'name': '박OO',
      };

      final user = UserModel.fromJson(json);

      expect(user.address.sido, '');
      expect(user.address.sigungu, '');
      expect(user.careerSummary, '');
      expect(user.isPushEnabled, true);
      expect(user.physicalConditions, isEmpty);
    });

    test('toJson serializes correctly', () {
      const user = UserModel(
        userId: 'uid789',
        phoneNumber: '+821011112222',
        name: '이OO',
        gender: 'female',
        address: Address(sido: '부산광역시', sigungu: '해욱대구'),
        careerSummary: '청소 업무',
        physicalConditions: const <String>[],
        preferredJobTypes: const <String>[],
        preferredLocations: const <String>[],
        isPushEnabled: false,
      );

      final json = user.toJson();

      expect(json['userId'], 'uid789');
      expect(json['name'], '이OO');
      expect(json['address'], <String, String>{
        'sido': '부산광역시',
        'sigungu': '해욱대구',
      });
      expect(json['isPushEnabled'], false);
    });
  });
}
