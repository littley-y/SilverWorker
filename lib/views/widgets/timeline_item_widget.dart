import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../core/l10n_utils.dart';
import '../../core/app_colors.dart';
import '../../core/app_spacing.dart';
import '../../core/app_radius.dart';
import '../../core/app_shadows.dart';
import '../../core/app_typography.dart';
import 'glass_container.dart';

class TimelineItemWidget extends StatelessWidget {
  final RoutineItem item;
  final bool isCurrent;
  final bool isCompleted;
  final Duration elapsedTime;
  final VoidCallback onComplete;

  const TimelineItemWidget({
    super.key,
    required this.item,
    required this.isCurrent,
    required this.isCompleted,
    required this.elapsedTime,
    required this.onComplete,
  });

  Color _getUrgencyColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    if (!isCurrent)
      return surfaceColor.withValues(alpha: isDarkMode ? 0.3 : 0.5);

    final total = item.estimatedDuration.inSeconds;
    if (total == 0)
      return surfaceColor.withValues(alpha: isDarkMode ? 0.3 : 0.5);

    final ratio = elapsedTime.inSeconds / total;

    if (ratio < 0.8) {
      return surfaceColor.withValues(alpha: isDarkMode ? 0.4 : 0.6);
    } else if (ratio < 0.9) {
      return Color.lerp(
        surfaceColor.withValues(alpha: isDarkMode ? 0.4 : 0.6),
        AppColors.warningYellow.withValues(alpha: 0.7),
        (ratio - 0.8) / 0.1,
      )!;
    } else {
      return Color.lerp(
        AppColors.warningYellow.withValues(alpha: 0.7),
        AppColors.dangerRed.withValues(alpha: 0.8),
        (ratio - 0.9) / 0.1,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final remaining = item.estimatedDuration - elapsedTime;
    final remainingSeconds =
        remaining.inSeconds.isNegative ? 0 : remaining.inSeconds;
    final displayTime =
        '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';

    final urgencyRatio = item.estimatedDuration.inSeconds > 0
        ? elapsedTime.inSeconds / item.estimatedDuration.inSeconds
        : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xs),
      child: GlassContainer(
        sigmaX: 12,
        sigmaY: 12,
        borderRadius: BorderRadius.circular(AppRadius.md),
        backgroundColor: _getUrgencyColor(context),
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md + AppSpacing.xs,
            vertical: AppSpacing.md + 2),
        border: Border.all(
          color: isCurrent
              ? (urgencyRatio > 0.9
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0x33007AFF))
              : (isDarkMode
                  ? Colors.white12
                  : Colors.white.withValues(alpha: 0.2)),
          width: 1.0,
        ),
        boxShadow: isCurrent ? AppShadows.normal(context) : null,
        child: Opacity(
          opacity: isCompleted ? 0.4 : (isCurrent ? 1.0 : 0.7),
          child: Row(
            children: [
              GestureDetector(
                onTap: isCurrent ? onComplete : null,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.successGreen
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.successGreen
                          : (isCurrent
                              ? AppColors.primaryBlue
                              : (isDarkMode
                                  ? Colors.white38
                                  : AppColors.borderLight)),
                      width: 2.0,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  L10nUtils.translate(context, item.name),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: (isCurrent && urgencyRatio > 0.9)
                        ? Colors.white
                        : (isDarkMode ? Colors.white : AppColors.textDark),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (isCurrent)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTime,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: (urgencyRatio > 0.9)
                            ? Colors.white
                            : (isDarkMode ? Colors.white : AppColors.textDark),
                      ),
                    ),
                    if (urgencyRatio > 0.8)
                      Text(
                        l10n.hurryUp,
                        style: TextStyle(
                          fontSize: 10,
                          color: (urgencyRatio > 0.9)
                              ? Colors.white70
                              : AppColors.dangerRed,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                )
              else
                Text(
                  '${item.estimatedDuration.inMinutes}${l10n.minutes}',
                  style: AppTypography.bodyMedium.copyWith(
                    color:
                        isDarkMode ? Colors.white38 : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
