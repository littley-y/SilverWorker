import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../core/timeline_engine.dart';
import '../services/alarm_scheduler_service.dart';
import '../services/database_interface.dart';
import '../services/database_service_impl.dart';
import '../services/mock_database_service.dart';

/// AlarmState 정의 (Circular Dependency 방지를 위해 Provider 파일 내 정의)
class AlarmState {
  final UserConfig? userConfig;
  final List<Routine> allRoutines;
  final Routine? activeRoutine;
  final List<RoutineItem> routineItems;
  final AlarmConfig? currentAlarm;
  final Map<int, TimelineBlock> currentTimeline;
  final bool isLoading;

  final bool isStarted;
  final bool isFinished;
  final int currentStepIndex;
  final Duration stepElapsedTime;
  final List<Duration> actualDurations;

  AlarmState({
    this.userConfig,
    this.allRoutines = const [],
    this.activeRoutine,
    this.routineItems = const [],
    this.currentAlarm,
    this.currentTimeline = const {},
    this.isLoading = false,
    this.isStarted = false,
    this.isFinished = false,
    this.currentStepIndex = 0,
    this.stepElapsedTime = Duration.zero,
    this.actualDurations = const [],
  });

  AlarmState copyWith({
    UserConfig? userConfig,
    List<Routine>? allRoutines,
    Routine? activeRoutine,
    List<RoutineItem>? routineItems,
    AlarmConfig? currentAlarm,
    Map<int, TimelineBlock>? currentTimeline,
    bool? isLoading,
    bool? isStarted,
    bool? isFinished,
    int? currentStepIndex,
    Duration? stepElapsedTime,
    List<Duration>? actualDurations,
  }) {
    return AlarmState(
      userConfig: userConfig ?? this.userConfig,
      allRoutines: allRoutines ?? this.allRoutines,
      activeRoutine: activeRoutine ?? this.activeRoutine,
      routineItems: routineItems ?? this.routineItems,
      currentAlarm: currentAlarm ?? this.currentAlarm,
      currentTimeline: currentTimeline ?? this.currentTimeline,
      isLoading: isLoading ?? this.isLoading,
      isStarted: isStarted ?? this.isStarted,
      isFinished: isFinished ?? this.isFinished,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      stepElapsedTime: stepElapsedTime ?? this.stepElapsedTime,
      actualDurations: actualDurations ?? this.actualDurations,
    );
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  if (kIsWeb) return MockDatabaseService();
  return DatabaseServiceImpl();
});

final alarmSchedulerProvider = Provider<AlarmSchedulerService>((ref) {
  return AlarmSchedulerService.instance;
});

class AlarmNotifier extends StateNotifier<AlarmState> {
  final DatabaseService _dbService;
  final AlarmSchedulerService _alarmService;
  Timer? _timer;

  AlarmNotifier(this._dbService, this._alarmService)
      : super(AlarmState(isLoading: true)) {
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final config = await _dbService.getUserConfig();
    final allRoutines = await _dbService.getRoutines();

    Routine? activeRoutine;
    try {
      activeRoutine = allRoutines.firstWhere((r) => r.isActive);
    } catch (_) {
      if (allRoutines.isNotEmpty) {
        activeRoutine = allRoutines.first;
        await _dbService.setActiveRoutine(activeRoutine.id!);
      }
    }

    List<RoutineItem> items = [];
    if (activeRoutine != null && activeRoutine.id != null) {
      items = await _dbService.getRoutineItems(activeRoutine.id!);
    }

    state = state.copyWith(
      userConfig: config,
      allRoutines: allRoutines,
      activeRoutine: activeRoutine,
      routineItems: items,
      isLoading: false,
    );

    if (activeRoutine != null) _calculateInitialTimeline();
  }

  void _calculateInitialTimeline() {
    if (state.activeRoutine == null) return;
    setupAlarm(targetDepartureTime: state.activeRoutine!.departureDateTime);
  }

  void setupAlarm({required DateTime targetDepartureTime}) {
    if (state.userConfig == null) return;

    final alarmConfig = AlarmConfig(
      targetDepartureTime: targetDepartureTime,
      routines: state.routineItems,
    );

    final timeline = TimelineEngine.calculateInitialTimeline(alarmConfig);

    state = state.copyWith(
      currentAlarm: alarmConfig,
      currentTimeline: timeline,
    );

    _alarmService.scheduleWakeUpAlarm(
      alarmConfig.wakeUpTime,
      state.activeRoutine?.name ?? '루틴',
    );
    _alarmService.scheduleDepartureReminder(alarmConfig.targetDepartureTime);
  }

  Future<void> updateLanguage(String code) async {
    if (state.userConfig == null) return;
    final updatedConfig = state.userConfig!.copyWith(languageCode: code);
    await _dbService.saveUserConfig(updatedConfig);
    state = state.copyWith(userConfig: updatedConfig);
  }

  Future<void> togglePremium() async {
    if (state.userConfig == null) return;
    final isCurrentlyPremium = state.userConfig!.isPremium;
    final newIsPremium = !isCurrentlyPremium;

    final newConfig = state.userConfig!.copyWith(
      isPremium: newIsPremium,
    );
    await _dbService.saveUserConfig(newConfig);

    // 프리미엄 해지 시 루틴 개수 제한 강제 (최대 2개)
    if (!newIsPremium && state.allRoutines.length > 2) {
      final routinesToRemove = state.allRoutines.sublist(2);
      for (var r in routinesToRemove) {
        if (r.id != null) {
          await _dbService.deleteRoutine(r.id!);
        }
      }

      // 현재 활성 루틴이 삭제 대상에 포함되었는지 확인 후 안전하게 전환
      final remainingRoutines = state.allRoutines.take(2).toList();
      final isActiveRoutineDeleted =
          !remainingRoutines.any((r) => r.id == state.activeRoutine?.id);

      if (isActiveRoutineDeleted && remainingRoutines.isNotEmpty) {
        await _dbService.setActiveRoutine(remainingRoutines.first.id!);
      }
    }

    await _init(); // 전체 상태 다시 로드 및 UI 갱신
  }

  void startPreparation() {
    if (state.routineItems.isEmpty) return;
    state = state.copyWith(
      isStarted: true,
      isFinished: false,
      currentStepIndex: 0,
      stepElapsedTime: Duration.zero,
      actualDurations: [],
    );
    _startTimer();
  }

  void completeCurrentStep() {
    if (!state.isStarted) return;
    final completedItem = state.routineItems[state.currentStepIndex];
    final actualDuration = state.stepElapsedTime;

    // History DB에 기록 (fire-and-forget — UI 블로킹 없음)
    _dbService.logExecution(
      itemName: completedItem.name,
      planned: completedItem.estimatedDuration,
      actual: actualDuration,
    );

    final updatedActuals = List<Duration>.from(state.actualDurations)
      ..add(actualDuration);

    if (state.currentStepIndex < state.routineItems.length - 1) {
      state = state.copyWith(
        currentStepIndex: state.currentStepIndex + 1,
        stepElapsedTime: Duration.zero,
        actualDurations: updatedActuals,
      );
    } else {
      _timer?.cancel();
      state = state.copyWith(
        isStarted: false,
        isFinished: true,
        actualDurations: updatedActuals,
      );
    }
  }

  void extendCurrentStep({Duration duration = const Duration(minutes: 1)}) {
    if (!state.isStarted) return;
    _applyDelay(duration);
  }

  void stopPreparation() {
    _timer?.cancel();
    _alarmService.cancelAllAlarms();
    state = state.copyWith(
      isStarted: false,
      currentStepIndex: 0,
      stepElapsedTime: Duration.zero,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        stepElapsedTime: state.stepElapsedTime + const Duration(seconds: 1),
      );
      _checkDelay();
    });
  }

  void _checkDelay() {
    if (!state.isStarted || state.routineItems.isEmpty) return;
    final currentItem = state.routineItems[state.currentStepIndex];
    final block = state.currentTimeline[currentItem.orderIndex];
    if (block == null) return;

    final excessSeconds =
        state.stepElapsedTime.inSeconds - block.duration.inSeconds;

    // 60초 단위로 지연을 적용 (매 1분 초과 시마다 한 번씩 타임라인 재계산 및 알림)
    if (excessSeconds > 0 && excessSeconds % 60 == 0) {
      _applyDelay(const Duration(minutes: 1), isAutomatic: true);
    }
  }

  void _applyDelay(Duration delay, {bool isAutomatic = false}) {
    if (state.userConfig == null || state.routineItems.isEmpty) return;
    final currentItem = state.routineItems[state.currentStepIndex];

    // 프리미엄 여부에 따른 정책 결정
    final policy = state.userConfig!.isPremium
        ? TimelinePolicy.compression
        : TimelinePolicy.pushBack;

    final newTimeline = TimelineEngine.applyDelay(
      currentTimeline: state.currentTimeline,
      routines: state.routineItems,
      delay: delay,
      currentItemIndex: currentItem.orderIndex,
      policy: policy,
    );

    // 지연 발생 시 햅틱 피드백 + 알림
    if (!kIsWeb) {
      if (!isAutomatic) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.mediumImpact();
        // 자동 지연(1분 초과 감지) 시 알림 및 진동으로 사용자에게 경고
        _alarmService.showDelayNotification(
          stepName: currentItem.name,
          delayMinutes: delay.inMinutes,
        );
      }
    }

    state = state.copyWith(currentTimeline: newTimeline);
  }

  // --- 기존 기타 메서드 유지 ---
  Future<bool> addRoutine(String name) async {
    final isPremium = state.userConfig?.isPremium ?? false;
    if (!isPremium && state.allRoutines.length >= 2) return false;

    final newRoutine = Routine(
      name: name,
      isActive: false,
      isPreset: false,
      mustLeaveTime: '08:00',
    );

    await _dbService.saveRoutine(newRoutine);
    final updatedRoutines = await _dbService.getRoutines();
    state = state.copyWith(allRoutines: updatedRoutines);
    return true;
  }

  Future<void> deleteRoutine(int id) async {
    await _dbService.deleteRoutine(id);
    final isActiveDeleted = state.activeRoutine?.id == id;
    if (isActiveDeleted) {
      await _init(); // 활성 루틴 삭제 시 전체 재로드 필요
    } else {
      final updatedRoutines = await _dbService.getRoutines();
      state = state.copyWith(allRoutines: updatedRoutines);
    }
  }

  Future<bool> addRoutineItem() async {
    if (state.activeRoutine == null || state.activeRoutine!.id == null) {
      return false;
    }
    if (state.routineItems.length >= 10) {
      return false;
    }
    final newItem = RoutineItem(
      routineId: state.activeRoutine!.id!,
      name: 'l10n:item_step ${state.routineItems.length + 1}',
      estimatedDuration: const Duration(minutes: 10),
      orderIndex: state.routineItems.length,
    );
    await _dbService.saveRoutineItem(newItem);
    final updatedItems = await _dbService.getRoutineItems(
      state.activeRoutine!.id!,
    );
    state = state.copyWith(routineItems: updatedItems);
    _calculateInitialTimeline();
    return true;
  }

  Future<void> updateRoutineItem(RoutineItem updatedItem) async {
    if (state.activeRoutine == null || state.activeRoutine!.id == null) return;
    await _dbService.saveRoutineItem(updatedItem);
    final updatedItems =
        await _dbService.getRoutineItems(state.activeRoutine!.id!);
    state = state.copyWith(routineItems: updatedItems);
    _calculateInitialTimeline();
  }

  Future<void> deleteRoutineItem(int itemId) async {
    await _dbService.deleteRoutineItem(itemId);
    final remaining =
        state.routineItems.where((item) => item.id != itemId).toList();
    // orderIndex 재정렬
    for (int i = 0; i < remaining.length; i++) {
      if (remaining[i].orderIndex != i) {
        final reordered = remaining[i].copyWith(orderIndex: i);
        await _dbService.saveRoutineItem(reordered);
        remaining[i] = reordered;
      }
    }
    state = state.copyWith(routineItems: remaining);
    _calculateInitialTimeline();
  }

  Future<void> updateActiveDays(List<bool> days) async {
    if (state.activeRoutine == null) return;
    final updated = state.activeRoutine!.copyWith(activeDays: days);
    await _dbService.saveRoutine(updated);
    state = state.copyWith(activeRoutine: updated);
    final allUpdated =
        state.allRoutines.map((r) => r.id == updated.id ? updated : r).toList();
    state = state.copyWith(allRoutines: allUpdated);
  }

  Future<void> updateMustLeaveTime(String time) async {
    if (state.activeRoutine == null) return;
    final updated = state.activeRoutine!.copyWith(mustLeaveTime: time);
    state = state.copyWith(activeRoutine: updated);
    _calculateInitialTimeline();
  }

  Future<void> switchRoutine(int routineId) async {
    state = state.copyWith(isLoading: true);
    await _dbService.setActiveRoutine(routineId);
    final allRoutines = await _dbService.getRoutines();
    final activeRoutine = allRoutines.firstWhere((r) => r.id == routineId);
    final items = await _dbService.getRoutineItems(routineId);
    state = state.copyWith(
      allRoutines: allRoutines,
      activeRoutine: activeRoutine,
      routineItems: items,
      isLoading: false,
    );
    _calculateInitialTimeline();
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmState>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final alarmService = ref.watch(alarmSchedulerProvider);
  return AlarmNotifier(dbService, alarmService);
});
