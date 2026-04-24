import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/core/ad_utils.dart';

void main() {
  group('AdUtils - extractKeyword', () {
    test('루틴 이름에서 핵심 키워드를 정확히 추출해야 함', () {
      expect(extractKeyword('아침 샤워하기'), equals('샤워'));
      expect(extractKeyword('따뜻한 커피 한 잔'), equals('커피'));
      expect(extractKeyword('빠르게 화장하기'), equals('메이크업'));
      expect(extractKeyword('회사로 운전해서 이동'), equals('운전'));
    });

    test('관련 키워드가 없을 경우 null을 반환해야 함', () {
      expect(extractKeyword('신발 신기'), isNull);
      expect(extractKeyword('가방 챙기기'), isNull);
    });

    test('다양한 유의어를 처리할 수 있어야 함', () {
      expect(extractKeyword('개운하게 씻기'), equals('샤워'));
      expect(extractKeyword('녹차 마시기'), equals('커피')); // 커피 카테고리로 분류
      expect(extractKeyword('메이크업 수정'), equals('메이크업'));
    });
  });
}
