import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/core/timeline_engine.dart';
import 'package:silver_worker_now/models/models.dart';

void main() {
  group('QA Automation Suite: Core Engine Verification', () {
    test(
      'Timeline Calculation: Target 09:00, Routine 30m -> Start at 08:30',
      () {
        final routines = [
          RoutineItem(
            routineId: 1,
            name: 'Step 1',
            estimatedDuration: const Duration(minutes: 20),
            orderIndex: 0,
          ),
          RoutineItem(
            routineId: 1,
            name: 'Step 2',
            estimatedDuration: const Duration(minutes: 10),
            orderIndex: 1,
          ),
        ];
        final departureTime = DateTime(2026, 3, 16, 9, 0);
        final config = AlarmConfig(
          targetDepartureTime: departureTime,
          routines: routines,
        );

        final timeline = TimelineEngine.calculateInitialTimeline(config);

        // Final step should end at 09:00
        expect(timeline[1]!.end, departureTime);
        // First routine start should be 08:30 (20m + 10m = 30m before 09:00)
        expect(timeline[0]!.start, DateTime(2026, 3, 16, 8, 30));
      },
    );

    test('Delay Strategy: Push-back should extend final departure time', () {
      final routines = [
        RoutineItem(
          routineId: 1,
          name: 'Step 1',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 0,
        ),
      ];
      final departureTime = DateTime(2026, 3, 16, 9, 0);
      final initialConfig = AlarmConfig(
        targetDepartureTime: departureTime,
        routines: routines,
      );

      final initialTimeline = TimelineEngine.calculateInitialTimeline(
        initialConfig,
      );

      // 10m delay
      const delay = Duration(minutes: 10);
      final adjustedTimeline = TimelineEngine.applyDelay(
        currentTimeline: initialTimeline,
        routines: routines,
        delay: delay,
        currentItemIndex: 0,
        policy: TimelinePolicy.pushBack,
      );

      // Final departure (Step 1 end) should be 09:10
      expect(adjustedTimeline[0]!.end, departureTime.add(delay));
    });

    test(
      'Delay Strategy: Compression should try to maintain departure time',
      () {
        final routines = [
          RoutineItem(
            routineId: 1,
            name: 'Step 1',
            estimatedDuration: const Duration(minutes: 10),
            orderIndex: 0,
          ),
          RoutineItem(
            routineId: 1,
            name: 'Step 2',
            estimatedDuration: const Duration(minutes: 10),
            orderIndex: 1,
          ),
        ];
        final departureTime = DateTime(2026, 3, 16, 9, 0);
        final initialConfig = AlarmConfig(
          targetDepartureTime: departureTime,
          routines: routines,
        );

        final initialTimeline = TimelineEngine.calculateInitialTimeline(
          initialConfig,
        );

        // 10m delay at Step 1, but total available time is fixed
        // In this case, Step 2 should be compressed or pushed back if no buffer exists.
        // Since we removed the buffer, the departure time WILL be pushed back
        // unless there is enough remaining time to compress.

        const delay = Duration(minutes: 5);
        final adjustedTimeline = TimelineEngine.applyDelay(
          currentTimeline: initialTimeline,
          routines: routines,
          delay: delay,
          currentItemIndex: 0,
          policy: TimelinePolicy.compression,
        );

        // Without buffer, Step 1 delay pushes Step 2, and Step 2 will be compressed
        // to fit the original 09:00 departure time if possible.
        expect(adjustedTimeline[1]!.end, departureTime);
        expect(adjustedTimeline[1]!.compressionRatio, lessThan(1.0));
      },
    );
  });
}
