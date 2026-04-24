import 'package:silver_worker_now/services/alarm_scheduler_service.dart';

class FakeAlarmScheduler implements AlarmSchedulerService {
  final List<DateTime> scheduledWakeUps = [];
  final List<DateTime> scheduledDepartures = [];
  final List<String> delayNotifications = [];
  int cancelAllCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleWakeUpAlarm(DateTime time, String name) async {
    scheduledWakeUps.add(time);
  }

  @override
  Future<void> scheduleDepartureReminder(DateTime time) async {
    scheduledDepartures.add(time);
  }

  @override
  Future<void> showDelayNotification({
    required String stepName,
    required int delayMinutes,
  }) async {
    delayNotifications.add('$stepName:$delayMinutes');
  }

  @override
  Future<void> cancelAllAlarms() async => cancelAllCount++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
