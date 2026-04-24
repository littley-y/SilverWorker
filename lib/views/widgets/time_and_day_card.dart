import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alarm_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/l10n_utils.dart';
import '../../core/app_colors.dart';

class TimeAndDayCard extends ConsumerWidget {
  final AlarmState state;
  final VoidCallback onTimeTap;

  const TimeAndDayCard({
    super.key,
    required this.state,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(alarmProvider.notifier);

    final dayNames = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
    final activeDays = state.activeRoutine?.activeDays ?? List.filled(7, false);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: onTimeTap,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.mustLeaveTime,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        L10nUtils.formatTimeString(context,
                            state.activeRoutine?.mustLeaveTime ?? '08:00'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white : Colors.black,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isDarkMode ? Colors.white10 : const Color(0xFFF2F2F7),
              indent: 20,
              endIndent: 20,
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alarmRepeat,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 5,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(7, (index) {
                        final isActive = activeDays[index];
                        return GestureDetector(
                          onTap: () {
                            final newDays = List<bool>.from(activeDays);
                            newDays[index] = !newDays[index];
                            notifier.updateActiveDays(newDays);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryBlue
                                  : (isDarkMode
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFFF2F2F7)),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              dayNames[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.white38
                                        : const Color(0xFF8E8E93)),
                                fontWeight: isActive
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
