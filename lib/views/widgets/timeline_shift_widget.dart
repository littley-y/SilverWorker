import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/timeline_engine.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../core/l10n_utils.dart';
import '../../core/app_colors.dart';
import '../../core/app_spacing.dart';
import '../../core/app_radius.dart';
import '../../core/app_animations.dart';

class TimelineShiftWidget extends StatelessWidget {
  final Map<int, TimelineBlock> timeline;
  final List<RoutineItem> routines;
  final int currentStepIndex;
  final Duration stepElapsedTime;

  const TimelineShiftWidget({
    super.key,
    required this.timeline,
    required this.routines,
    required this.currentStepIndex,
    required this.stepElapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty || routines.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    // 전체 남은 시간 계산 (현재 루틴 시작점부터 최종 외출 시각까지)
    final firstBlock = timeline[routines.first.orderIndex];
    final lastBlock = timeline[routines.last.orderIndex];
    if (firstBlock == null || lastBlock == null) return const SizedBox.shrink();

    final totalDuration = lastBlock.end.difference(firstBlock.start);
    if (totalDuration.inSeconds <= 0) return const SizedBox.shrink();

    return Container(
      height: 140,
      margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md + AppSpacing.xs,
          vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(l10n),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: _buildTimelineBlocks(
                      context, totalDuration, constraints.maxWidth),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    if (currentStepIndex >= routines.length) return const SizedBox.shrink();
    final currentRoutine = routines[currentStepIndex];
    final block = timeline[currentRoutine.orderIndex];
    if (block == null) return const SizedBox.shrink();
    final isDelayed = stepElapsedTime > block.duration;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.preparationTimeline,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        if (isDelayed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 12, color: AppColors.dangerRed),
                const SizedBox(width: 4),
                Text(
                  l10n.delayOccurred,
                  style: const TextStyle(
                    color: AppColors.dangerRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildTimelineBlocks(
      BuildContext context, Duration totalDuration, double maxWidth) {
    final List<Widget> blocks = [];

    // 현재 남은 활성 블록들(current와 future)의 시간 비중을 기반으로 너비를 분배합니다.
    int remainingSeconds = 0;
    int visibleCount = 0;
    for (int i = 0; i < routines.length; i++) {
      if (i >= currentStepIndex) {
        final block = timeline[routines[i].orderIndex];
        if (block != null) {
          remainingSeconds += block.duration.inSeconds;
          visibleCount++;
        }
      }
    }
    if (remainingSeconds == 0) return blocks;

    double totalSpacing = (visibleCount > 1 ? visibleCount - 1 : 0) * 4.0;
    double availableWidth = maxWidth - totalSpacing;

    for (int i = 0; i < routines.length; i++) {
      final routine = routines[i];
      final block = timeline[routine.orderIndex];
      if (block == null) continue;

      final isCurrent = i == currentStepIndex;
      final isPast = i < currentStepIndex;
      final blockDuration = block.duration;

      double width = 0;
      if (!isPast) {
        width = availableWidth * (blockDuration.inSeconds / remainingSeconds);
      }

      blocks.add(
        AnimatedContainer(
          duration: AppAnimations.normal,
          curve: Curves.easeInOut,
          width: width,
          margin: EdgeInsets.only(
              right: (!isPast && i < routines.length - 1) ? 4.0 : 0),
          child: ClipRect(
            child: _TimelineBlockItem(
              name: L10nUtils.translate(context, routine.name),
              isCurrent: isCurrent,
              isPast: isPast,
              isDelayed: isCurrent && stepElapsedTime > blockDuration,
              compressionRatio: block.compressionRatio,
            ),
          ),
        ),
      );
    }

    return blocks;
  }
}

class _TimelineBlockItem extends StatefulWidget {
  final String name;
  final bool isCurrent;
  final bool isPast;
  final bool isDelayed;
  final double compressionRatio;

  const _TimelineBlockItem({
    required this.name,
    required this.isCurrent,
    required this.isPast,
    required this.isDelayed,
    required this.compressionRatio,
  });

  @override
  State<_TimelineBlockItem> createState() => _TimelineBlockItemState();
}

class _TimelineBlockItemState extends State<_TimelineBlockItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
  }

  @override
  void didUpdateWidget(_TimelineBlockItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isPast && !widget.isCurrent) {
      if (widget.compressionRatio < oldWidget.compressionRatio) {
        _shakeController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    if (widget.isPast) {
      color = AppColors.successGreen; // Green (Success)
    } else if (widget.isCurrent) {
      if (widget.isDelayed) {
        color = AppColors.dangerRed; // Red (Late)
      } else if (widget.compressionRatio < 1.0) {
        color = AppColors.warningYellow; // Yellow (Compressed/Hurry up)
      } else {
        color = AppColors.primaryBlue; // Blue (Normal/Active)
      }
    } else {
      // Future blocks
      color = widget.compressionRatio < 1.0
          ? AppColors.warningYellow.withValues(alpha: 0.5)
          : const Color(0xFFD1D1D6);
    }

    BoxDecoration decoration = BoxDecoration(
      color: widget.isPast ? null : color,
      gradient: widget.isPast
          ? const LinearGradient(
              colors: [AppColors.successGreen, Color(0xFF28A745)])
          : null,
      borderRadius: BorderRadius.circular(10),
      border:
          (!widget.isPast && !widget.isCurrent && widget.compressionRatio < 1.0)
              ? Border.all(color: AppColors.warningYellow, width: 1.0)
              : null,
      boxShadow: widget.isCurrent
          ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          : null,
    );

    Widget block = Stack(
      children: [
        // Background 'Ghost' indicator for compression
        if (widget.compressionRatio < 1.0 && !widget.isPast)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        Container(
          decoration: decoration,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isCurrent &&
                        widget.compressionRatio < 1.0 &&
                        !widget.isDelayed)
                      const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Icon(Icons.bolt, size: 10, color: Colors.white),
                      ),
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: (widget.isPast || widget.isCurrent)
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 11,
                        letterSpacing:
                            widget.compressionRatio < 0.8 ? -0.8 : -0.2,
                        fontWeight: widget.isCurrent
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return ListenableBuilder(
      listenable: _shakeController,
      builder: (context, child) {
        final offset = math.sin(_shakeController.value * math.pi * 6) * 3;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: block,
    );
  }
}
