/// Must Go Out Alarm - 핵심 데이터 모델 (v1.5 - Clean Models)

class UserConfig {
  final int id;
  final bool isPremium;
  final String delayPolicy;
  final String languageCode;

  UserConfig({
    required this.id,
    required this.isPremium,
    required this.delayPolicy,
    this.languageCode = 'auto',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_premium': isPremium ? 1 : 0,
      'delay_policy': delayPolicy,
      'language_code': languageCode,
    };
  }

  factory UserConfig.fromMap(Map<String, dynamic> map) {
    return UserConfig(
      id: map['id'],
      isPremium: map['is_premium'] == 1,
      delayPolicy: map['delay_policy'] ?? 'NONE',
      languageCode: map['language_code'] ?? 'auto',
    );
  }

  UserConfig copyWith({
    int? id,
    bool? isPremium,
    String? delayPolicy,
    String? languageCode,
  }) {
    return UserConfig(
      id: id ?? this.id,
      isPremium: isPremium ?? this.isPremium,
      delayPolicy: delayPolicy ?? this.delayPolicy,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class Routine {
  final int? id;
  final String name;
  final bool isActive;
  final bool isPreset;
  final List<bool> activeDays;
  final String mustLeaveTime;

  Routine({
    this.id,
    required this.name,
    this.isActive = false,
    this.isPreset = false,
    this.activeDays = const [true, true, true, true, true, false, false],
    this.mustLeaveTime = "08:00",
  });

  /// `now` 기준으로 다음 mustLeaveTime 발생 시각을 계산한다.
  /// 순수 함수로 만들어 테스트·리빌드 안정성을 확보.
  DateTime departureDateTimeFrom(DateTime now) {
    final parts = mustLeaveTime.split(':');
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }

  /// 현재 시각 기준 편의 getter. 테스트에서는 `departureDateTimeFrom` 사용 권장.
  DateTime get departureDateTime => departureDateTimeFrom(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive ? 1 : 0,
      'is_preset': isPreset ? 1 : 0,
      'active_days': activeDays.map((e) => e ? 1 : 0).join(','),
      'must_leave_time': mustLeaveTime,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      isActive: map['is_active'] == 1,
      isPreset: map['is_preset'] == 1,
      activeDays: (map['active_days'] as String?)
              ?.split(',')
              .map((e) => e == '1')
              .toList() ??
          const [true, true, true, true, true, false, false],
      mustLeaveTime: map['must_leave_time'] ?? "08:00",
    );
  }

  Routine copyWith({
    int? id,
    String? name,
    bool? isActive,
    bool? isPreset,
    List<bool>? activeDays,
    String? mustLeaveTime,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isPreset: isPreset ?? this.isPreset,
      activeDays: activeDays ?? this.activeDays,
      mustLeaveTime: mustLeaveTime ?? this.mustLeaveTime,
    );
  }
}

class RoutineItem {
  final int? id;
  final int routineId;
  final String name;
  final Duration estimatedDuration;
  final int orderIndex;

  RoutineItem({
    this.id,
    required this.routineId,
    required this.name,
    required this.estimatedDuration,
    required this.orderIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routine_id': routineId,
      'name': name,
      'estimated_minutes': estimatedDuration.inMinutes,
      'order_index': orderIndex,
    };
  }

  factory RoutineItem.fromMap(Map<String, dynamic> map) {
    return RoutineItem(
      id: map['id'],
      routineId: map['routine_id'],
      name: map['name'],
      estimatedDuration: Duration(minutes: map['estimated_minutes']),
      orderIndex: map['order_index'],
    );
  }

  RoutineItem copyWith({
    int? id,
    int? routineId,
    String? name,
    Duration? estimatedDuration,
    int? orderIndex,
  }) {
    return RoutineItem(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

class AlarmConfig {
  final DateTime targetDepartureTime;
  final List<RoutineItem> routines;

  AlarmConfig({
    required this.targetDepartureTime,
    required this.routines,
  });

  Duration get totalRoutineDuration {
    return routines.fold(
      Duration.zero,
      (total, item) => total + item.estimatedDuration,
    );
  }

  DateTime get wakeUpTime => targetDepartureTime.subtract(totalRoutineDuration);
}

// AlarmState 등은 providers에서 정의하도록 유도 (Circular Dependency 방지)
