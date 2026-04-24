import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../core/app_colors.dart';
import '../../core/app_spacing.dart';
import '../../core/app_radius.dart';
import '../../core/app_typography.dart';
import '../../l10n/app_localizations.dart';

class AlarmStatusCard extends StatelessWidget {
  final AlarmConfig? currentAlarm;

  const AlarmStatusCard({
    super.key,
    required this.currentAlarm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();

    if (currentAlarm == null) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDarkMode ? Colors.white12 : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.alarm_off_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              l10n.alarmNotSet,
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final timeFormat = DateFormat('aa hh:mm', locale);
    final wakeUpStr = timeFormat.format(currentAlarm!.wakeUpTime);
    final departureStr = timeFormat.format(currentAlarm!.targetDepartureTime);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color:
            AppColors.primaryBlue.withValues(alpha: isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.alarm_rounded,
            size: 16,
            color: AppColors.primaryBlue,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            l10n.alarmSet,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          _TimeChip(
              label: l10n.wakeUpAt, time: wakeUpStr, isDarkMode: isDarkMode),
          SizedBox(width: AppSpacing.sm),
          _TimeChip(
              label: l10n.departureAt,
              time: departureStr,
              isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final bool isDarkMode;

  const _TimeChip({
    required this.label,
    required this.time,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: AppTypography.labelLarge.copyWith(
            color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        Text(
          time,
          style: AppTypography.labelLarge.copyWith(
            color: isDarkMode ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
