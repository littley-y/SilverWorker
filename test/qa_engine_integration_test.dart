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
      return null;
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

  group('QA Integration: Delay Strategy Deep Dive', () {
    test('[TC-CORE-03-1] 압축(Compression) 테스트', () async {
      // 압축 검증을 위해 프리미엄 활성화
      await notifier.togglePremium();
      notifier.startPreparation();
      // 최종 외출 시간 (마지막 루틴의 끝) 확보
      final lastItem = notifier.state.routineItems.last;
      final originalDepartureTime =
          notifier.state.currentTimeline[lastItem.orderIndex]!.end;

      // 5분 지연 발생
      notifier.extendCurrentStep(duration: const Duration(minutes: 5));

      final updatedDepartureTime =
          notifier.state.currentTimeline[lastItem.orderIndex]!.end;

      // Compression이므로 최종 출발 시간은 변하지 않아야 함
      expect(updatedDepartureTime, originalDepartureTime);

      // 마지막 단계의 압축률이 1.0 미만이어야 함
      expect(
          notifier.state.currentTimeline[lastItem.orderIndex]!
                  .compressionRatio <
              1.0,
          true);
    });
  });
}
