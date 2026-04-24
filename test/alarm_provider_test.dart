import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/providers/alarm_provider.dart';
import 'package:silver_worker_now/services/alarm_scheduler_service.dart';
import 'package:silver_worker_now/services/mock_database_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  const MethodChannel channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null; // 모든 호출에 대해 성공(null) 반환
    });
  });

  late AlarmNotifier notifier;
  late MockDatabaseService mockDb;

  setUp(() async {
    mockDb = MockDatabaseService();
    notifier = AlarmNotifier(mockDb, AlarmSchedulerService());

    // 비동기 초기화 대기
    while (notifier.state.isLoading) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  });

  test('준비 시작(startPreparation) 시 상태가 올바르게 변경되어야 함', () async {
    notifier.startPreparation();

    expect(notifier.state.isStarted, true);
    expect(notifier.state.currentStepIndex, 0);
    expect(notifier.state.stepElapsedTime, Duration.zero);
  });

  test('단계 완료(completeCurrentStep) 시 인덱스가 증가해야 함', () async {
    notifier.startPreparation();

    final initialIndex = notifier.state.currentStepIndex;
    notifier.completeCurrentStep();

    expect(notifier.state.currentStepIndex, initialIndex + 1);
    expect(notifier.state.stepElapsedTime, Duration.zero);
  });

  test('모든 단계 완료 시 준비 모드가 종료되어야 함', () async {
    notifier.startPreparation();

    // 모든 단계 완료 처리 (Mock 루틴 아이템 개수만큼)
    final itemCount = notifier.state.routineItems.length;
    for (int i = 0; i < itemCount; i++) {
      notifier.completeCurrentStep();
    }

    expect(notifier.state.isStarted, false);
  });

  test('지연 발생 시 타임라인이 압축 정책에 따라 변경되어야 함', () async {
    // Compression 검증을 위해 프리미엄 활성화
    await notifier.togglePremium();
    notifier.startPreparation();

    final lastItem = notifier.state.routineItems.last;
    final originalDepartureTime =
        notifier.state.currentTimeline[lastItem.orderIndex]!.end;

    // 1분 지연 발생
    notifier.extendCurrentStep(duration: const Duration(minutes: 1));

    final updatedDepartureTime =
        notifier.state.currentTimeline[lastItem.orderIndex]!.end;

    // 압축 정책이므로 최종 외출 시각(Departure Time)은 1분 전체가 밀리지 않고 일부 상쇄되어야 함
    expect(
      updatedDepartureTime.isBefore(
        originalDepartureTime.add(const Duration(minutes: 1)),
      ),
      true,
    );
  });

  group('logExecution persistence', () {
    test('completeCurrentStep writes history entry per completed step',
        () async {
      final mockDbLocal = MockDatabaseService();
      final notifierLocal = AlarmNotifier(mockDbLocal, AlarmSchedulerService());

      // 비동기 초기화 대기
      while (notifierLocal.state.isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      notifierLocal.startPreparation();
      notifierLocal.completeCurrentStep();
      notifierLocal.completeCurrentStep();
      await Future.delayed(const Duration(milliseconds: 10));

      final history = await mockDbLocal.getHistory();
      expect(history.length, greaterThanOrEqualTo(2),
          reason: '각 완료 단계마다 history 레코드가 기록되어야 한다');

      notifierLocal.dispose();
    });
  });

  test('updateRoutineItem을 호출하면 루틴 아이템의 이름과 시간이 수정되어야 함', () async {
    final initialItems = notifier.state.routineItems;
    expect(initialItems.isNotEmpty, true);

    final itemToUpdate = initialItems.first;
    const newName = '수정된 단계 이름';
    const newDuration = Duration(minutes: 45);

    final updatedItem = itemToUpdate.copyWith(
      name: newName,
      estimatedDuration: newDuration,
    );

    await notifier.updateRoutineItem(updatedItem);

    final newItems = notifier.state.routineItems;
    final resultItem =
        newItems.firstWhere((item) => item.id == itemToUpdate.id);

    expect(resultItem.name, newName);
    expect(resultItem.estimatedDuration, newDuration);

    // 타임라인도 재계산 되었는지 확인
    final block = notifier.state.currentTimeline[resultItem.orderIndex];
    expect(block != null, true);
    expect(block!.originalDuration, newDuration);
  });
}
