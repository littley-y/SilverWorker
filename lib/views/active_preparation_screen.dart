import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/alarm_provider.dart';
import '../l10n/app_localizations.dart';
import '../core/l10n_utils.dart';
import '../core/app_colors.dart';
import '../core/app_radius.dart';
import 'widgets/glass_container.dart';
import 'widgets/timeline_item_widget.dart';
import 'widgets/timeline_shift_widget.dart';
import 'result_briefing_screen.dart';

class ActivePreparationScreen extends ConsumerWidget {
  const ActivePreparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmProvider);
    final notifier = ref.read(alarmProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AlarmState>(alarmProvider, (previous, next) {
      if (previous?.isFinished != true && next.isFinished) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ResultBriefingScreen(),
            ),
          );
        }
      }
      if (previous?.isStarted == true && !next.isStarted && !next.isFinished) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GlassContainer(
          sigmaX: 10,
          sigmaY: 10,
          child: AppBar(
            backgroundColor:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            elevation: 0,
            centerTitle: true,
            title: Text(
              l10n.preparing,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            leading: TextButton(
              onPressed: () => notifier.stopPreparation(),
              child: Text(
                l10n.stop,
                style: const TextStyle(
                  color: AppColors.dangerRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Timeline Shift Widget (Interactive Track)
            TimelineShiftWidget(
              timeline: state.currentTimeline,
              routines: state.routineItems,
              currentStepIndex: state.currentStepIndex,
              stepElapsedTime: state.stepElapsedTime,
            ),

            // Timeline List
            Expanded(
              child: _buildTimelineList(context, state, notifier),
            ),

            // Bottom Action Area (Glassmorphism)
            GlassContainer(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              border: Border(
                top: BorderSide(
                    color: Colors.white
                        .withValues(alpha: isDarkMode ? 0.05 : 0.3)),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Extend Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => notifier.extendCurrentStep(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.textDark.withValues(alpha: 0.08),
                        foregroundColor:
                            isDarkMode ? Colors.white : AppColors.textDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        l10n.extendOneMinute,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Departure Info
                  _buildDepartureStatus(context, state, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineList(
      BuildContext context, AlarmState state, AlarmNotifier notifier) {
    final items = state.routineItems;

    // Single step: use original scrollable list
    if (items.length <= 1) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isCurrent =
              index == state.currentStepIndex && !state.isFinished;
          final isCompleted = index < state.currentStepIndex ||
              (index == state.currentStepIndex && state.isFinished);
          return TimelineItemWidget(
            item: item,
            isCurrent: isCurrent,
            isCompleted: isCompleted,
            elapsedTime: isCurrent ? state.stepElapsedTime : Duration.zero,
            onComplete: () => notifier.completeCurrentStep(),
          );
        },
      );
    }

    // Multiple steps: current step = 1/3, rest = 2/3 equally divided
    final int currentIndex = state.isFinished ? -1 : state.currentStepIndex;
    final List<Widget> columns = [];

    // Flex ratio: current = 1/3, each other = equal share of 2/3.
    // total flex = 3 * otherCount.
    // current flex = otherCount  => otherCount / (3 * otherCount) = 1/3.
    // each other flex = 2        => 2 / (3 * otherCount) per step, sum = 2/3.
    final int otherCount = items.length - 1;
    final int currentFlex = otherCount;
    const int eachOtherFlex = 2;

    for (int index = 0; index < items.length; index++) {
      final item = items[index];
      final isCurrent = index == currentIndex;
      final isCompleted = index < state.currentStepIndex ||
          (index == state.currentStepIndex && state.isFinished);

      if (isCurrent) {
        columns.add(
          Flexible(
            flex: currentFlex,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: TimelineItemWidget(
                item: item,
                isCurrent: true,
                isCompleted: isCompleted,
                elapsedTime: state.stepElapsedTime,
                onComplete: () => notifier.completeCurrentStep(),
              ),
            ),
          ),
        );
      } else {
        columns.add(
          Flexible(
            flex: eachOtherFlex,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
              child: _buildCompactStepBar(context, item, isCompleted),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columns,
    );
  }

  Widget _buildCompactStepBar(
      BuildContext context, RoutineItem item, bool isCompleted) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color barColor = isCompleted
        ? AppColors.successGreen.withValues(alpha: 0.4)
        : (isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.surfaceLight.withValues(alpha: 0.8));
    final Color borderColor = isCompleted
        ? AppColors.successGreen.withValues(alpha: 0.5)
        : (isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.borderLight.withValues(alpha: 0.5));

    return Container(
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: borderColor, width: 1.0),
      ),
    );
  }

  Widget _buildDepartureStatus(
      BuildContext context, AlarmState state, AppLocalizations l10n) {
    String departureTime = '';
    bool isLate = false;

    if (state.currentAlarm != null) {
      final target =
          state.currentTimeline[state.routineItems.last.orderIndex]?.end ??
              state.currentAlarm!.targetDepartureTime;
      departureTime = L10nUtils.formatTime(context, target);
      isLate = target.isAfter(state.currentAlarm!.targetDepartureTime);
    }

    if (departureTime.isEmpty) return const SizedBox.shrink();

    return Text(
      l10n.finalDepartureExpected(departureTime),
      style: TextStyle(
        color: isLate ? AppColors.dangerRed : AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }
}
