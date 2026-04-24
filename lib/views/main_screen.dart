import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alarm_provider.dart';
import '../core/app_colors.dart';
import '../core/ad_utils.dart';
import '../core/l10n_utils.dart';
import '../l10n/app_localizations.dart';
import 'widgets/banner_ad_widget.dart';
import 'widgets/native_ad_card.dart';
import 'widgets/time_and_day_card.dart';
import 'widgets/summary_banner.dart';
import 'widgets/alarm_status_card.dart';
import 'widgets/slidable_routine_item.dart';
import 'active_preparation_screen.dart';
import 'widgets/dialogs/main_screen_dialogs.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alarmProvider);
    final notifier = ref.read(alarmProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isPremium = state.userConfig?.isPremium ?? false;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, ref, isPremium, l10n, isDarkMode),
      bottomNavigationBar: BannerAdWidget(isPremium: isPremium),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TimeAndDayCard(
                        state: state,
                        onTimeTap: () =>
                            showTimePickerPopup(context, state, notifier, l10n),
                      ),
                      const SizedBox(height: 24),
                      SummaryBanner(state: state),
                      const SizedBox(height: 12),
                      AlarmStatusCard(currentAlarm: state.currentAlarm),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          L10nUtils.translate(context,
                              state.activeRoutine?.name ?? l10n.noRoutine),
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                              letterSpacing: -1.0),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 루틴 리스트
                      for (int i = 0; i < state.routineItems.length; i++) ...[
                        SlidableRoutineItem(
                          item: state.routineItems[i],
                          onLongPress: () => showEditStepDialog(
                              context, ref, state.routineItems[i], l10n),
                        ),
                        if (!isPremium && i == 0)
                          NativeAdCard(
                              keyword:
                                  extractKeyword(state.routineItems[i].name)),
                      ],

                      _buildAddStepButton(context, notifier, l10n),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomSheet:
          _buildStartButton(context, state, notifier, l10n, isDarkMode),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref,
      bool isPremium, AppLocalizations l10n, bool isDarkMode) {
    final notifier = ref.read(alarmProvider.notifier);
    return AppBar(
      backgroundColor:
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      elevation: 0,
      leadingWidth: 70,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          if (kDebugMode)
            IconButton(
              icon: Icon(
                isPremium ? Icons.stars_rounded : Icons.star_outline_rounded,
                color: isPremium
                    ? const Color(0xFFFFCC00)
                    : (isDarkMode ? Colors.white38 : Colors.grey),
                size: 28,
              ),
              onPressed: () async {
                await notifier.togglePremium();
                final updatedIsPremium =
                    ref.read(alarmProvider).userConfig?.isPremium ?? false;

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Text(updatedIsPremium
                          ? l10n.proModeSwitched
                          : l10n.freeModeSwitched),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      centerTitle: true,
      title: Text(
        l10n.appTitle,
        style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_rounded,
              color: isDarkMode ? Colors.white : const Color(0xFF1C1C1E)),
          onPressed: () => showSettingsPopup(context, ref),
          tooltip: l10n.settings,
        ),
        IconButton(
          icon: Icon(Icons.layers_rounded,
              color: isDarkMode ? Colors.white : const Color(0xFF1C1C1E)),
          onPressed: () => showRoutineManagementPopup(context, ref),
          tooltip: l10n.routineManagement,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAddStepButton(
      BuildContext context, AlarmNotifier notifier, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: () async {
          final success = await notifier.addRoutineItem();
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.maxStepLimitMessage,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text(l10n.add_step,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          foregroundColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, AlarmState state,
      AlarmNotifier notifier, AppLocalizations l10n, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
        border: Border(
            top: BorderSide(
                color: isDarkMode
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: () {
            notifier.startPreparation();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ActivePreparationScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Text(
            l10n.startPreparation,
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ),
      ),
    );
  }
}
