import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_worker_now/providers/alarm_provider.dart';
import 'package:silver_worker_now/services/mock_database_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'fakes/fake_alarm_scheduler.dart';

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

  Future<AlarmNotifier> buildNotifier(FakeAlarmScheduler scheduler) async {
    final notifier = AlarmNotifier(MockDatabaseService(), scheduler);
    while (notifier.state.isLoading) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    return notifier;
  }

  test('setupAlarm schedules wake-up alarm', () async {
    final fakeScheduler = FakeAlarmScheduler();
    final notifier = await buildNotifier(fakeScheduler);

    // _init() 완료 후 _calculateInitialTimeline -> setupAlarm 이 이미 한번 호출됨.
    // 직접 setupAlarm을 다시 호출해도 추가로 예약되는지 검증.
    final countBefore = fakeScheduler.scheduledWakeUps.length;

    final departureTime = DateTime.now().add(const Duration(hours: 2));
    notifier.setupAlarm(targetDepartureTime: departureTime);

    expect(fakeScheduler.scheduledWakeUps.length, greaterThan(countBefore),
        reason: 'setupAlarm이 wake-up 알람을 예약해야 한다');
  });

  test('startPreparation does not schedule additional wake-up', () async {
    final fakeScheduler = FakeAlarmScheduler();
    final notifier = await buildNotifier(fakeScheduler);

    final departureTime = DateTime.now().add(const Duration(hours: 2));
    notifier.setupAlarm(targetDepartureTime: departureTime);
    final countAfterSetup = fakeScheduler.scheduledWakeUps.length;

    notifier.startPreparation();

    expect(fakeScheduler.scheduledWakeUps.length, countAfterSetup,
        reason: 'startPreparation은 추가 wake-up 예약을 하면 안 된다');
  });
}
