import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alarm_provider.dart';
import '../l10n/app_localizations.dart';
import '../core/l10n_utils.dart';
import '../core/app_colors.dart';
import 'widgets/banner_ad_widget.dart';
import 'widgets/glass_container.dart';

class ResultBriefingScreen extends ConsumerWidget {
  const ResultBriefingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmProvider);
    final l10n = AppLocalizations.of(context)!;

    // 계산 로직 고도화
    final totalPlannedSeconds = state.routineItems.fold(
      0,
      (sum, item) => sum + item.estimatedDuration.inSeconds,
    );
    final totalActualSeconds = state.actualDurations.fold(
      0,
      (sum, dur) => sum + dur.inSeconds,
    );

    final diffSeconds = totalActualSeconds - totalPlannedSeconds;
    final isLate = diffSeconds > 0;

    // 바 시각화를 위한 비율 계산
    final maxSeconds = totalPlannedSeconds > totalActualSeconds
        ? totalPlannedSeconds
        : (totalActualSeconds > 0 ? totalActualSeconds : 1);
    final plannedWidthFactor = totalPlannedSeconds / maxSeconds;
    final actualWidthFactor = totalActualSeconds / maxSeconds;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.preparationResult,
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w800),
        ),
        automaticallyImplyLeading: false, // 브리핑 후에는 메인으로만 이동
      ),
      bottomNavigationBar: BannerAdWidget(
        isPremium: state.userConfig?.isPremium ?? false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Header
            Text(
              l10n.preparationFinished,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : Colors.black,
                  letterSpacing: -1.0),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.resultDescription,
              style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 48),

            // Summary Card (Glassmorphism)
            GlassContainer(
              sigmaX: 10,
              sigmaY: 10,
              borderRadius: BorderRadius.circular(30),
              padding: const EdgeInsets.all(28),
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
              border: Border.all(
                  color:
                      Colors.white.withValues(alpha: isDarkMode ? 0.05 : 0.3)),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalScore,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: isDarkMode ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isLate
                              ? AppColors.dangerRed
                              : AppColors.successGreen,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (isLate
                                      ? AppColors.dangerRed
                                      : AppColors.successGreen)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          isLate
                              ? l10n.lateByMinutes(diffSeconds ~/ 60 +
                                  (diffSeconds % 60 > 0 ? 1 : 0))
                              : l10n.onTimeDeparture,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Timeline Overlay Visualization
                  Stack(
                    children: [
                      // Planned Bar (Background)
                      Container(
                        height: 64,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white12
                              : AppColors.textDark.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: plannedWidthFactor.clamp(0.1, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              l10n.planned,
                              style: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Actual Bar (Foreground)
                      Positioned(
                        top: 14,
                        left: 0,
                        right: 0,
                        child: FractionallySizedBox(
                          widthFactor: actualWidthFactor.clamp(0.1, 1.0),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLate
                                    ? [
                                        AppColors.successGreen,
                                        AppColors.warningYellow,
                                        AppColors.dangerRed,
                                      ]
                                    : [
                                        AppColors.successGreen,
                                        AppColors.successGreen
                                            .withValues(alpha: 0.8),
                                      ],
                                stops: isLate
                                    ? const [0.0, 0.6, 1.0]
                                    : const [0.0, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.actual,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isLate
                        ? l10n.delayedFeedback(
                            diffSeconds ~/ 60 + (diffSeconds % 60 > 0 ? 1 : 0))
                        : l10n.earlyFeedback,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Item Details
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.routineItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = state.routineItems[index];
                final actual = index < state.actualDurations.length
                    ? state.actualDurations[index]
                    : Duration.zero;
                final diff =
                    actual.inSeconds - item.estimatedDuration.inSeconds;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDarkMode ? 0.2 : 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10nUtils.translate(context, item.name),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: isDarkMode ? Colors.white : Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.plannedActualRatio(
                                item.estimatedDuration.inMinutes,
                                actual.inMinutes,
                                actual.inSeconds % 60),
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        diff == 0
                            ? '±0s'
                            : (diff > 0 ? '+${diff}s' : '${diff}s'),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: diff == 0
                              ? AppColors.textSecondary
                              : (diff > 0
                                  ? AppColors.dangerRed
                                  : AppColors.successGreen),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Back to Main Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(alarmProvider.notifier)
                      .stopPreparation(); // 상태 초기화 및 홈으로
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                ),
                child: Text(
                  l10n.returnToMain,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
