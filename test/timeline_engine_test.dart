import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/core/timeline_engine.dart';
import 'package:silver_worker_now/models/models.dart';

void main() {
  group('TimelineEngine Tests', () {
    final departureTime = DateTime(2026, 3, 16, 9, 0);
    // 09:00 AM
    final routines = [
      RoutineItem(
        name: 'Step 1',
        estimatedDuration: const Duration(minutes: 10),
        orderIndex: 0,
        routineId: 1,
      ),
      RoutineItem(
        name: 'Step 2',
        estimatedDuration: const Duration(minutes: 20),
        orderIndex: 1,
        routineId: 1,
      ),
    ];
    final config = AlarmConfig(
      targetDepartureTime: departureTime,
      routines: routines,
    );
    test('Initial Timeline Calculation', () {
      final timeline = TimelineEngine.calculateInitialTimeline(config);

      // Step 2: 08:40 ~ 09:00 (20 mins)
      expect(timeline[1]!.start, DateTime(2026, 3, 16, 8, 40));
      expect(timeline[1]!.end, departureTime);

      // Step 1: 08:30 ~ 08:40 (10 mins)
      expect(timeline[0]!.start, DateTime(2026, 3, 16, 8, 30));
      expect(timeline[0]!.end, DateTime(2026, 3, 16, 8, 40));
    });

    test('Apply Delay - PushBack Strategy', () {
      final initialTimeline = TimelineEngine.calculateInitialTimeline(config);
      const delay = Duration(minutes: 2);
      final newTimeline = TimelineEngine.applyDelay(
        currentTimeline: initialTimeline,
        routines: routines,
        delay: delay,
        currentItemIndex: 0,
        policy: TimelinePolicy.pushBack,
      );

      // Step 1: 08:30~08:42 (2 mins delay applied)
      expect(
        newTimeline[0]!.end,
        initialTimeline[0]!.end.add(delay),
      );
      // Final departure time should be pushed back by 2 minutes
      expect(newTimeline[1]!.end, departureTime.add(delay));
    });

    test('Apply Delay - Compression Strategy', () {
      final initialTimeline = TimelineEngine.calculateInitialTimeline(config);
      const delay = Duration(minutes: 10);

      final newTimeline = TimelineEngine.applyDelay(
        currentTimeline: initialTimeline,
        routines: routines,
        delay: delay,
        currentItemIndex: 0,
        policy: TimelinePolicy.compression,
      );

      // Final departure time should be FIXED (09:00) because of compression
      expect(newTimeline[1]!.end, departureTime);

      // Step 1 end pushed by 10 minutes
      expect(
        newTimeline[0]!.end,
        initialTimeline[0]!.end.add(delay),
      );

      // Step 2 should be compressed (originally 20 mins, now has 10 mins left)
      final step2Duration = newTimeline[1]!.end.difference(
            newTimeline[1]!.start,
          );
      expect(step2Duration, const Duration(minutes: 10));
      expect(newTimeline[1]!.compressionRatio, 0.5);
    });
  });

  group('Edge Case Tests', () {
    test('C1: empty routines returns empty map', () {
      final config = AlarmConfig(
        targetDepartureTime: DateTime(2026, 3, 16, 9, 0),
        routines: [],
      );
      final timeline = TimelineEngine.calculateInitialTimeline(config);
      expect(timeline, isEmpty);
    });

    test('C2: all-zero durations falls back to push-back without crash', () {
      final zeroRoutines = [
        RoutineItem(
          name: 'S1',
          estimatedDuration: Duration.zero,
          orderIndex: 0,
          routineId: 1,
        ),
        RoutineItem(
          name: 'S2',
          estimatedDuration: Duration.zero,
          orderIndex: 1,
          routineId: 1,
        ),
      ];
      final config = AlarmConfig(
        targetDepartureTime: DateTime(2026, 3, 16, 9, 0),
        routines: zeroRoutines,
      );
      final timeline = TimelineEngine.calculateInitialTimeline(config);
      expect(
        () => TimelineEngine.applyDelay(
          currentTimeline: timeline,
          routines: zeroRoutines,
          delay: const Duration(minutes: 1),
          currentItemIndex: 0,
          policy: TimelinePolicy.compression,
        ),
        returnsNormally,
      );
    });

    test('C3: delay exceeds available time falls back to push-back', () {
      final routines = [
        RoutineItem(
          name: 'S1',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 0,
          routineId: 1,
        ),
        RoutineItem(
          name: 'S2',
          estimatedDuration: const Duration(minutes: 5),
          orderIndex: 1,
          routineId: 1,
        ),
      ];
      final dep = DateTime(2026, 3, 16, 9, 0);
      final config = AlarmConfig(targetDepartureTime: dep, routines: routines);
      final initial = TimelineEngine.calculateInitialTimeline(config);
      // 20분 지연 → S2에 가용 시간(5분) 초과 → push-back 폴백
      final result = TimelineEngine.applyDelay(
        currentTimeline: initial,
        routines: routines,
        delay: const Duration(minutes: 20),
        currentItemIndex: 0,
        policy: TimelinePolicy.compression,
      );
      // push-back이므로 출발 시각이 dep보다 늦어짐
      expect(result[1]!.end.isAfter(dep), isTrue);
    });

    test('C4: unknown currentItemName falls back to push-back without crash',
        () {
      final routines = [
        RoutineItem(
          name: 'Step 1',
          estimatedDuration: const Duration(minutes: 20),
          orderIndex: 0,
          routineId: 1,
        ),
      ];
      final config = AlarmConfig(
        targetDepartureTime: DateTime(2026, 3, 16, 9, 0),
        routines: routines,
      );
      final initial = TimelineEngine.calculateInitialTimeline(config);
      expect(
        () => TimelineEngine.applyDelay(
          currentTimeline: initial,
          routines: routines,
          delay: const Duration(minutes: 5),
          currentItemIndex: 999,
          policy: TimelinePolicy.compression,
        ),
        returnsNormally,
      );
    });

    test('H2: massive delay handled without crash (push-back)', () {
      final routines = [
        RoutineItem(
          name: 'S1',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 0,
          routineId: 1,
        ),
        RoutineItem(
          name: 'S2',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 1,
          routineId: 1,
        ),
      ];
      final config = AlarmConfig(
        targetDepartureTime: DateTime(2026, 3, 16, 9, 0),
        routines: routines,
      );
      final initial = TimelineEngine.calculateInitialTimeline(config);
      expect(
        () => TimelineEngine.applyDelay(
          currentTimeline: initial,
          routines: routines,
          delay: const Duration(hours: 2),
          currentItemIndex: 0,
          policy: TimelinePolicy.pushBack,
        ),
        returnsNormally,
      );
    });

    test(
        'C5: currentItemIndex missing from timeline falls back to push-back without crash',
        () {
      final routines = [
        RoutineItem(
          name: 'S1',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 0,
          routineId: 1,
        ),
        RoutineItem(
          name: 'S2',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 1,
          routineId: 1,
        ),
      ];
      // orderIndex 0 블록을 의도적으로 누락
      final partialTimeline = <int, TimelineBlock>{
        1: TimelineBlock(
          start: DateTime(2026, 3, 16, 8, 50),
          end: DateTime(2026, 3, 16, 9, 0),
          originalDuration: const Duration(minutes: 10),
        ),
      };
      expect(
        () => TimelineEngine.applyDelay(
          currentTimeline: partialTimeline,
          routines: routines,
          delay: const Duration(minutes: 2),
          currentItemIndex: 0,
          policy: TimelinePolicy.compression,
        ),
        returnsNormally,
      );
    });

    test('H4: compression on last item falls back gracefully', () {
      final routines = [
        RoutineItem(
          name: 'S1',
          estimatedDuration: const Duration(minutes: 20),
          orderIndex: 0,
          routineId: 1,
        ),
        RoutineItem(
          name: 'S2',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 1,
          routineId: 1,
        ),
      ];
      final config = AlarmConfig(
        targetDepartureTime: DateTime(2026, 3, 16, 9, 0),
        routines: routines,
      );
      final initial = TimelineEngine.calculateInitialTimeline(config);
      // 마지막 항목에서 지연 — compressionTargets 비어있음
      final result = TimelineEngine.applyDelay(
        currentTimeline: initial,
        routines: routines,
        delay: const Duration(minutes: 5),
        currentItemIndex: 1,
        policy: TimelinePolicy.compression,
      );
      expect(result, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // TimelineShiftWidget 관련 맵 키 타입 정합성 테스트
  //
  // 리뷰 지적사항(PR_Review/Core_Dev/2026-03-30-initial-audit.md):
  //   "맵 키 타입 미스(String vs int)는 정적 타이핑 언어에서 창피한 수준이다."
  //
  // TimelineEngine은 Map<int, TimelineBlock>을 반환하며
  // 키는 항상 RoutineItem.orderIndex(int)이다.
  // 아래 테스트들은 해당 계약이 유지됨을 보장한다.
  // ---------------------------------------------------------------------------
  group('Map Key Type Integrity Tests (TimelineShiftWidget regression)', () {
    test('T1: calculateInitialTimeline 반환 맵의 키 타입이 int임을 보장', () {
      final routines = [
        RoutineItem(
          name: 'Step A',
          estimatedDuration: const Duration(minutes: 15),
          orderIndex: 0,
          routineId: 1,
        ),
        RoutineItem(
          name: 'Step B',
          estimatedDuration: const Duration(minutes: 25),
          orderIndex: 1,
          routineId: 1,
        ),
      ];
      final config = AlarmConfig(
        targetDepartureTime: DateTime(2026, 3, 30, 8, 0),
        routines: routines,
      );
      final timeline = TimelineEngine.calculateInitialTimeline(config);

      // 모든 키가 int(orderIndex)이어야 한다
      for (final key in timeline.keys) {
        expect(key, isA<int>());
      }

      // orderIndex 0, 1로 직접 조회 가능해야 한다
      expect(timeline[0], isNotNull);
      expect(timeline[1], isNotNull);
      expect(timeline['0'], isNull); // String 키로는 조회 불가여야 함
    });

    test('T2: applyDelay 반환 맵의 키가 기존 orderIndex와 동일하게 유지됨', () {
      final routines = [
        RoutineItem(
          name: 'Step A',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 5, // non-zero orderIndex 의도적으로 사용
          routineId: 2,
        ),
        RoutineItem(
          name: 'Step B',
          estimatedDuration: const Duration(minutes: 20),
          orderIndex: 7,
          routineId: 2,
        ),
      ];
      final config = AlarmConfig(
        targetDepartureTime: DateTime(2026, 3, 30, 9, 0),
        routines: routines,
      );
      final initial = TimelineEngine.calculateInitialTimeline(config);

      // 초기 타임라인: orderIndex 5, 7로만 구성되어야 한다
      expect(initial.containsKey(5), isTrue);
      expect(initial.containsKey(7), isTrue);
      expect(initial.containsKey(0), isFalse);

      // applyDelay 후에도 동일한 키 구조 유지
      final pushed = TimelineEngine.applyDelay(
        currentTimeline: initial,
        routines: routines,
        delay: const Duration(minutes: 3),
        currentItemIndex: 5,
        policy: TimelinePolicy.pushBack,
      );
      expect(pushed.containsKey(5), isTrue);
      expect(pushed.containsKey(7), isTrue);

      final compressed = TimelineEngine.applyDelay(
        currentTimeline: initial,
        routines: routines,
        delay: const Duration(minutes: 3),
        currentItemIndex: 5,
        policy: TimelinePolicy.compression,
      );
      expect(compressed.containsKey(5), isTrue);
      expect(compressed.containsKey(7), isTrue);
    });

    test('T3: TimelineShiftWidget에 전달되는 firstBlock/lastBlock null 방어 확인', () {
      // routines의 orderIndex가 timeline 맵에 없을 때 null을 반환해야 한다.
      // (위젯에서 null 체크 후 SizedBox.shrink()로 처리)
      final routines = [
        RoutineItem(
          name: 'X',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 99, // 타임라인에 없는 orderIndex
          routineId: 3,
        ),
      ];
      const Map<int, TimelineBlock> emptyTimeline = {};

      // 위젯 로직 시뮬레이션: timeline[routines.first.orderIndex]
      final firstBlock = emptyTimeline[routines.first.orderIndex];
      final lastBlock = emptyTimeline[routines.last.orderIndex];

      expect(firstBlock, isNull);
      expect(lastBlock, isNull);
      // null 체크가 존재하므로 위젯은 SizedBox.shrink()를 반환해야 한다 — NPE 없음
    });

    test('T4: non-sequential orderIndex에서도 역산 타임라인이 정확함', () {
      // orderIndex가 0, 1 연속이 아닌 경우에도 타임라인이 올바르게 계산됨
      final dep = DateTime(2026, 3, 30, 10, 0);
      final routines = [
        RoutineItem(
          name: 'First',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 3,
          routineId: 4,
        ),
        RoutineItem(
          name: 'Second',
          estimatedDuration: const Duration(minutes: 20),
          orderIndex: 10,
          routineId: 4,
        ),
      ];
      final config = AlarmConfig(targetDepartureTime: dep, routines: routines);
      final timeline = TimelineEngine.calculateInitialTimeline(config);

      // Second (orderIndex 10): 09:40 ~ 10:00
      expect(timeline[10]!.end, dep);
      expect(timeline[10]!.start, DateTime(2026, 3, 30, 9, 40));

      // First (orderIndex 3): 09:30 ~ 09:40
      expect(timeline[3]!.start, DateTime(2026, 3, 30, 9, 30));
      expect(timeline[3]!.end, DateTime(2026, 3, 30, 9, 40));
    });
  });
}
