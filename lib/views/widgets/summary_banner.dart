import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/alarm_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_spacing.dart';
import '../../core/app_radius.dart';
import '../../core/app_shadows.dart';
import '../../core/app_typography.dart';

class SummaryBanner extends StatelessWidget {
  final AlarmState state;

  const SummaryBanner({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    DateTime? firstStartTime;
    if (state.currentTimeline.isNotEmpty) {
      try {
        firstStartTime = state.currentTimeline.values
            .map((v) => v.start)
            .reduce((a, b) => a.isBefore(b) ? a : b);
      } catch (_) {}
    }
    final startTimeStr = firstStartTime != null
        ? DateFormat(
            'aa hh:mm',
            Localizations.localeOf(context).toString(),
          ).format(firstStartTime)
        : '--:--';

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md + AppSpacing.xs),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // 고대비 블랙 카드 유지
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isDarkMode ? Border.all(color: Colors.white10) : null,
        boxShadow: AppShadows.normal(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.preparationStartTime,
                style: AppTypography.labelLarge.copyWith(color: Colors.white60),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                startTimeStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(height: 30, width: 1, color: Colors.white24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.totalPreparationTime,
                style: AppTypography.labelLarge.copyWith(color: Colors.white60),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                '${state.routineItems.fold(0, (sum, item) => sum + item.estimatedDuration.inMinutes)}${l10n.minutes}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
