import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppVibration {
  static final Int64List wakeUp =
      Int64List.fromList([0, 500, 200, 500, 200, 1000]);
  static final Int64List reminder = Int64List.fromList([0, 300, 100, 300]);
  static final Int64List delay = Int64List.fromList([0, 200, 100, 200]);
}

class AlarmSchedulerService {
  AlarmSchedulerService._();
  static final AlarmSchedulerService instance = AlarmSchedulerService._();
  factory AlarmSchedulerService() => instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 알림 탭 시 호출될 콜백 (main.dart에서 설정)
  static VoidCallback? onNotificationTap;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;
    tz.initializeTimeZones();
    final String localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call();
      },
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // 기존 채널 삭제 (클렌징 로직)
    await androidImpl?.deleteNotificationChannel('wake_up_channel_v1');
    await androidImpl?.deleteNotificationChannel('wake_up_channel_v2');
    await androidImpl?.deleteNotificationChannel('departure_channel_v1');
    await androidImpl?.deleteNotificationChannel('departure_channel_v2');
    await androidImpl?.deleteNotificationChannel('delay_channel_v1');

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'routine_channel_v3',
        '준비 알람',
        description: '루틴 시작 알림',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'departure_channel_v3',
        '출발 알림',
        description: '출발 5분 전 알림',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'delay_channel_v2',
        '지연 알림',
        description: '단계 지연 발생 알림',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      ),
    );

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;
  }

  Future<void> scheduleWakeUpAlarm(
      DateTime wakeUpTime, String routineName) async {
    if (kIsWeb) return;
    if (wakeUpTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      0,
      '나갈준비 알리미',
      '$routineName 시작할 시간입니다!',
      tz.TZDateTime.from(wakeUpTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'routine_channel_v3',
          '준비 알람',
          channelDescription: '루틴 시작 알림',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: AppVibration.wakeUp,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleDepartureReminder(DateTime departureTime) async {
    if (kIsWeb) return;
    final reminderTime = departureTime.subtract(const Duration(minutes: 5));
    if (reminderTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      1,
      '나갈준비 알리미',
      '출발 5분 전입니다!',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'departure_channel_v3',
          '출발 알림',
          channelDescription: '출발 5분 전 알림',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: AppVibration.reminder,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 단계 지연 발생 시 즉시 알림 + 진동
  Future<void> showDelayNotification({
    required String stepName,
    required int delayMinutes,
  }) async {
    if (kIsWeb) return;
    await _plugin.show(
      2,
      '지연 발생: $stepName',
      '$delayMinutes분 지연되었습니다.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'delay_channel_v2',
          '지연 알림',
          channelDescription: '단계 지연 발생 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: true,
          enableVibration: true,
          vibrationPattern: AppVibration.delay,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAllAlarms() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
