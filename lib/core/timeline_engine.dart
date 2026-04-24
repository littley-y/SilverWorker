import '../models/models.dart';

/// 지연 대응 전략
enum TimelinePolicy {
  /// 단순 지연: 모든 일정을 지연된 시간만큼 뒤로 미룸 (무료 버전 기본)
  pushBack,

  /// 압축 지연: 남은 루틴 항목의 시간을 축소하여 최대한 외출 시각을 맞춤 (프리미엄 전용)
  compression,
}

/// 타임라인 블록 정보 (UI 렌더링용)
class TimelineBlock {
  final DateTime start;
  final DateTime end;
  final Duration originalDuration;
  final double compressionRatio; // 1.0 = 원본, < 1.0 = 압축됨

  TimelineBlock({
    required this.start,
    required this.end,
    required this.originalDuration,
    this.compressionRatio = 1.0,
  });

  Duration get duration => end.difference(start);
}

/// TimelineEngine
/// 나갈 시각으로부터 역산하여 타임라인을 생성하고, 지연 발생 시 실시간으로 조정하는 핵심 엔진
class TimelineEngine {
  /// 초기 타임라인 생성 (Target Departure Time으로부터 역산)
  static Map<int, TimelineBlock> calculateInitialTimeline(
    AlarmConfig config,
  ) {
    // C1: 빈 루틴 리스트 방어
    if (config.routines.isEmpty) return {};

    final Map<int, TimelineBlock> timeline = {};

    DateTime currentTime = config.targetDepartureTime;

    // 루틴 항목 정렬 및 배치 (역순)
    final sortedRoutines = List<RoutineItem>.from(config.routines)
      ..sort((a, b) => b.orderIndex.compareTo(a.orderIndex));

    for (var routine in sortedRoutines) {
      final endTime = currentTime;
      final startTime = endTime.subtract(routine.estimatedDuration);

      timeline[routine.orderIndex] = TimelineBlock(
        start: startTime,
        end: endTime,
        originalDuration: routine.estimatedDuration,
      );

      currentTime = startTime;
    }

    return timeline;
  }

  /// 지연 발생 시 타임라인 조정
  static Map<int, TimelineBlock> applyDelay({
    required Map<int, TimelineBlock> currentTimeline,
    required List<RoutineItem> routines,
    required Duration delay,
    required int currentItemIndex,
    required TimelinePolicy policy,
  }) {
    if (policy == TimelinePolicy.pushBack) {
      return _applyPushBack(currentTimeline, delay, currentItemIndex);
    } else {
      return _applyCompression(
        currentTimeline,
        routines,
        delay,
        currentItemIndex,
      );
    }
  }

  /// 전략 A: Push-back (뒤로 밀기)
  static Map<int, TimelineBlock> _applyPushBack(
    Map<int, TimelineBlock> currentTimeline,
    Duration delay,
    int currentItemIndex,
  ) {
    final Map<int, TimelineBlock> finalTimeline = {};
    bool isCurrentOrFuture = false;

    // currentTimeline의 키 순서가 역순이므로, 안전하게 처리하기 위해 루틴 목록을 모를 때는
    // 시작 시간을 기준으로 정렬하거나, Map 엔트리들을 시작 시간 순으로 접근합니다.
    final entries = currentTimeline.entries.toList()
      ..sort((a, b) => a.value.start.compareTo(b.value.start));

    for (final entry in entries) {
      if (entry.key == currentItemIndex) {
        isCurrentOrFuture = true;
      }

      if (isCurrentOrFuture) {
        finalTimeline[entry.key] = TimelineBlock(
          start: entry.value.start.add(delay),
          end: entry.value.end.add(delay),
          originalDuration: entry.value.originalDuration,
          compressionRatio: entry.value.compressionRatio,
        );
      } else {
        finalTimeline[entry.key] = entry.value;
      }
    }

    return finalTimeline;
  }

  /// 전략 B: Compression (시간 압축)
  static Map<int, TimelineBlock> _applyCompression(
    Map<int, TimelineBlock> currentTimeline,
    List<RoutineItem> routines,
    Duration delay,
    int currentItemIndex,
  ) {
    final Map<int, TimelineBlock> newTimeline = {};
    final int listIndex = routines.indexWhere(
      (r) => r.orderIndex == currentItemIndex,
    );

    if (listIndex == -1) {
      return _applyPushBack(currentTimeline, delay, currentItemIndex);
    }

    // 1. 목표 출발 시각 (마지막 루틴의 끝)
    final lastBlock = currentTimeline[routines.last.orderIndex];
    if (lastBlock == null) {
      return _applyPushBack(currentTimeline, delay, currentItemIndex);
    }
    final DateTime targetDepartureTime = lastBlock.end;

    // 2. 현재 단계 이전 단계들은 그대로 유지 (현재 단계는 delay만큼 연장)
    for (int i = 0; i <= listIndex; i++) {
      final routine = routines[i];
      final block = currentTimeline[routine.orderIndex];
      if (block != null) {
        newTimeline[routine.orderIndex] = TimelineBlock(
          start: block.start,
          end: (i == listIndex) ? block.end.add(delay) : block.end,
          originalDuration: block.originalDuration,
          compressionRatio: block.compressionRatio,
        );
      }
    }

    final currentBlock = newTimeline[currentItemIndex];
    if (currentBlock == null) {
      return _applyPushBack(currentTimeline, delay, currentItemIndex);
    }
    DateTime lastEndTime = currentBlock.end;

    // 3. 남은 항목들 리스트업
    final List<RoutineItem> remainingRoutines = routines.sublist(
      listIndex + 1,
    );

    // 압축 대상 항목들 (orderIndex, 원래 소요 시간)
    final List<MapEntry<int, Duration>> compressionTargets = [];
    for (var r in remainingRoutines) {
      compressionTargets.add(MapEntry(r.orderIndex, r.estimatedDuration));
    }

    final totalRemainingOriginalDuration = compressionTargets.fold(
      Duration.zero,
      (t, e) => t + e.value,
    );

    // C2: division by zero 방어 — 모든 남은 항목이 Duration.zero인 경우
    if (totalRemainingOriginalDuration.inSeconds == 0) {
      return _applyPushBack(currentTimeline, delay, currentItemIndex);
    }

    final Duration totalAvailableTime = targetDepartureTime.difference(
      lastEndTime,
    );

    // 시간이 아예 없거나 부족하면 Push-back으로 전환
    if (totalAvailableTime <= Duration.zero) {
      return _applyPushBack(currentTimeline, delay, currentItemIndex);
    }

    // 항목당 평균 가용 시간이 30초 미만이면 압축 의미 없으므로 Push-back으로 전환
    final double averageAvailable =
        totalAvailableTime.inSeconds / compressionTargets.length;
    if (averageAvailable < 30) {
      return _applyPushBack(currentTimeline, delay, currentItemIndex);
    }

    // 4. 비율에 따른 시간 배분 (비율 그대로 유지, 최소 1초만 보장)
    for (var target in compressionTargets) {
      final double ratio =
          target.value.inSeconds / totalRemainingOriginalDuration.inSeconds;
      final int allocatedSeconds =
          (totalAvailableTime.inSeconds * ratio).floor();

      final int finalSeconds = allocatedSeconds < 1 ? 1 : allocatedSeconds;
      final Duration finalDuration = Duration(seconds: finalSeconds);

      newTimeline[target.key] = TimelineBlock(
        start: lastEndTime,
        end: lastEndTime.add(finalDuration),
        originalDuration: target.value,
        compressionRatio: target.value.inSeconds > 0
            ? finalSeconds / target.value.inSeconds
            : 1.0,
      );
      lastEndTime = newTimeline[target.key]!.end;
    }

    // 현재 타임라인에 있었지만 아직 포함 안 된 항목들 (예: 이전 항목들) 복사
    currentTimeline.forEach((key, value) {
      if (!newTimeline.containsKey(key)) {
        newTimeline[key] = value;
      }
    });

    return newTimeline;
  }
}
