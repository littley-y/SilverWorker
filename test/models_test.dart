import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/models/models.dart';

void main() {
  group('Routine.departureDateTimeFrom', () {
    test('returns same-day time when now is before mustLeaveTime', () {
      final r = Routine(
        name: 'Test Routine',
        mustLeaveTime: '09:00',
      );
      final now = DateTime(2026, 4, 22, 7, 0);
      expect(r.departureDateTimeFrom(now), DateTime(2026, 4, 22, 9, 0));
    });

    test('returns next-day time when now is after mustLeaveTime', () {
      final r = Routine(
        name: 'Test Routine',
        mustLeaveTime: '09:00',
      );
      final now = DateTime(2026, 4, 22, 10, 0);
      expect(r.departureDateTimeFrom(now), DateTime(2026, 4, 23, 9, 0));
    });
  });

  group('Data Models Tests', () {
    test(
        'Routine.departureDateTime handles past time properly (Next day calculation)',
        () {
      final now = DateTime(2026, 4, 22, 10, 0);

      // 1. 현재 시각 기준 1시간 전으로 설정
      final pastHour = (now.hour - 1) % 24;
      // 음수 방지 처리 (자정 근처 테스트용)
      final safePastHour = pastHour < 0 ? 23 : pastHour;

      final pastTimeStr = '${safePastHour.toString().padLeft(2, '0')}:00';

      final routine = Routine(
        name: 'Test Routine',
        mustLeaveTime: pastTimeStr,
      );

      final calculatedTime = routine.departureDateTimeFrom(now);

      // 2. 결과 검증
      // 계산된 시간이 현재 시각보다 무조건 미래(혹은 정확히 같음)여야 합니다.
      expect(
          calculatedTime.isAfter(now) || calculatedTime.isAtSameMomentAs(now),
          true);

      // 3. 날짜가 내일(혹은 하루 뒤)인지 검증
      if (now.hour > safePastHour) {
        expect(calculatedTime.day, now.add(const Duration(days: 1)).day);
      }
    });

    test('Routine.departureDateTime handles future time properly (Same day)',
        () {
      final now = DateTime(2026, 4, 22, 10, 0);

      // 현재 시각 기준 1시간 후로 설정
      final futureHour = (now.hour + 1) % 24;
      final futureTimeStr = '${futureHour.toString().padLeft(2, '0')}:00';

      final routine = Routine(
        name: 'Test Routine Future',
        mustLeaveTime: futureTimeStr,
      );

      final calculatedTime = routine.departureDateTimeFrom(now);

      // 오늘 시간이어야 하며, 자정을 넘어간(23시 -> 00시) 케이스가 아니라면 날짜가 같아야 합니다.
      if (futureHour > now.hour) {
        expect(calculatedTime.day, now.day);
      }
      expect(calculatedTime.isAfter(now), true);
    });
  });
}
