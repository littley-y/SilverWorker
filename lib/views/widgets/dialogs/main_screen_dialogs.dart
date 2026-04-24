import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/alarm_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/app_colors.dart';
import '../../../models/models.dart';
import '../../../core/l10n_utils.dart';
import '../../../l10n/app_localizations.dart';

void showEditStepDialog(BuildContext context, WidgetRef ref, RoutineItem item,
    AppLocalizations l10n) {
  final notifier = ref.read(alarmProvider.notifier);
  final textController =
      TextEditingController(text: L10nUtils.translate(context, item.name));
  int selectedMinutes = item.estimatedDuration.inMinutes;

  showCupertinoDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return CupertinoAlertDialog(
          title: Text(l10n.edit_step),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: textController,
                placeholder: l10n.stepName,
                autofocus: true,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(minutes: selectedMinutes),
                  onTimerDurationChanged: (duration) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      selectedMinutes = duration.inMinutes;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                if (textController.text.isNotEmpty && selectedMinutes > 0) {
                  notifier.updateRoutineItem(item.copyWith(
                    name: textController.text,
                    estimatedDuration: Duration(minutes: selectedMinutes),
                  ));
                }
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    ),
  );
}

/// 단계 이름만 수정하는 다이얼로그
void showEditStepNameDialog(BuildContext context, WidgetRef ref,
    RoutineItem item, AppLocalizations l10n) {
  final notifier = ref.read(alarmProvider.notifier);
  final textController =
      TextEditingController(text: L10nUtils.translate(context, item.name));

  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(l10n.stepName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: textController,
            placeholder: l10n.stepName,
            autofocus: true,
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            if (textController.text.isNotEmpty) {
              notifier.updateRoutineItem(item.copyWith(
                name: textController.text,
              ));
            }
            Navigator.pop(context);
          },
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );
}

/// 단계 시간만 수정하는 다이얼로그
void showEditStepDurationDialog(BuildContext context, WidgetRef ref,
    RoutineItem item, AppLocalizations l10n) {
  final notifier = ref.read(alarmProvider.notifier);
  int selectedMinutes = item.estimatedDuration.inMinutes;

  showCupertinoDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return CupertinoAlertDialog(
          title: Text(l10n.edit_step),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(minutes: selectedMinutes),
                  onTimerDurationChanged: (duration) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      selectedMinutes = duration.inMinutes;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                if (selectedMinutes > 0) {
                  notifier.updateRoutineItem(item.copyWith(
                    estimatedDuration: Duration(minutes: selectedMinutes),
                  ));
                }
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    ),
  );
}

void showSettingsPopup(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(alarmProvider);
        final notifier = ref.read(alarmProvider.notifier);
        final themeMode = ref.watch(themeModeProvider);
        final themeNotifier = ref.read(themeModeProvider.notifier);
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settings,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // 언어 설정
              Text(l10n.language,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(height: 12),
              _buildLanguageOption(context, notifier, 'auto',
                  l10n.systemDefault, state.userConfig?.languageCode == 'auto'),
              _buildLanguageOption(context, notifier, 'ko', '한국어',
                  state.userConfig?.languageCode == 'ko'),
              _buildLanguageOption(context, notifier, 'en', 'English',
                  state.userConfig?.languageCode == 'en'),
              _buildLanguageOption(context, notifier, 'ja', '日本語',
                  state.userConfig?.languageCode == 'ja'),
              _buildLanguageOption(context, notifier, 'zh', '中文(简体)',
                  state.userConfig?.languageCode == 'zh'),
              _buildLanguageOption(context, notifier, 'es', 'Español',
                  state.userConfig?.languageCode == 'es'),
              _buildLanguageOption(context, notifier, 'fr', 'Français',
                  state.userConfig?.languageCode == 'fr'),
              const SizedBox(height: 24),
              // 테마 설정
              Text(l10n.themeMode,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.themeLight),
                    icon: const Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.dark_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.phone_android),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selected) {
                  themeNotifier.setThemeMode(selected.first);
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.all(
                    const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildLanguageOption(BuildContext context, AlarmNotifier notifier,
    String code, String title, bool isSelected) {
  return ListTile(
    title: Text(title,
        style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    trailing: isSelected
        ? const Icon(Icons.check, color: AppColors.primaryBlue)
        : null,
    contentPadding: EdgeInsets.zero,
    onTap: () {
      notifier.updateLanguage(code);
      Navigator.pop(context);
    },
  );
}

void showTimePickerPopup(BuildContext context, AlarmState state,
    AlarmNotifier notifier, AppLocalizations l10n) {
  final initialTime =
      state.activeRoutine?.mustLeaveTime.split(':') ?? ['08', '00'];
  int selectedHour = int.parse(initialTime[0]);
  int selectedMinute = int.parse(initialTime[1]);
  final now = DateTime.now();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(l10n.setDepartureTime,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime(
                  now.year, now.month, now.day, selectedHour, selectedMinute),
              onDateTimeChanged: (dateTime) {
                HapticFeedback.selectionClick();
                selectedHour = dateTime.hour;
                selectedMinute = dateTime.minute;
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                notifier.updateMustLeaveTime(
                    '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}');
                Navigator.pop(context);
              },
              child: Text(l10n.confirm),
            ),
          ),
        ],
      ),
    ),
  );
}

void showRoutineManagementPopup(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  final outerContext = context;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => Consumer(
      builder: (consumerContext, ref, _) {
        final state = ref.watch(alarmProvider);
        final notifier = ref.read(alarmProvider.notifier);
        return Container(
          height: MediaQuery.of(consumerContext).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.routineManagement,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.primaryBlue, size: 32),
                    onPressed: () async {
                      final success = await notifier.addRoutine(
                          '${l10n.newRoutine} ${state.allRoutines.length + 1}');
                      if (!success && consumerContext.mounted) {
                        Navigator.pop(sheetContext);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (outerContext.mounted) {
                            ScaffoldMessenger.of(outerContext).showSnackBar(
                              SnackBar(
                                content: Text(l10n.freeLimitMessage,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: state.allRoutines.length,
                  itemBuilder: (listContext, index) {
                    final routine = state.allRoutines[index];
                    final isSelected = routine.id == state.activeRoutine?.id;
                    return Card(
                      elevation: isSelected ? 2 : 0,
                      color: isSelected
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.borderLight),
                      ),
                      child: ListTile(
                        title: Text(
                            L10nUtils.translate(consumerContext, routine.name),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${l10n.leaveAt(L10nUtils.formatTimeString(consumerContext, routine.mustLeaveTime))} / ${_getActiveDaysTextShort(consumerContext, routine.activeDays)}'),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primaryBlue)
                            : null,
                        onTap: () {
                          if (routine.id != null) {
                            notifier.switchRoutine(routine.id!);
                          }
                          Navigator.pop(sheetContext);
                        },
                        onLongPress: () {
                          if (routine.id != null) {
                            showCupertinoDialog(
                              context: consumerContext,
                              builder: (ctx) => CupertinoAlertDialog(
                                title: Text(l10n.routineManagement),
                                content: Text(l10n.deleteRoutineConfirm),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.cancel),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      notifier.deleteRoutine(routine.id!);
                                    },
                                    child: Text(l10n.confirm),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

String _getActiveDaysTextShort(BuildContext context, List<bool> activeDays) {
  final l10n = AppLocalizations.of(context)!;
  final dayNames = [
    l10n.monday,
    l10n.tuesday,
    l10n.wednesday,
    l10n.thursday,
    l10n.friday,
    l10n.saturday,
    l10n.sunday
  ];
  List<String> selected = [];
  for (int i = 0; i < 7; i++) {
    if (activeDays[i]) selected.add(dayNames[i]);
  }
  if (selected.length == 7) return l10n.everyday;
  if (selected.isEmpty) return l10n.none;
  return selected.join(',');
}
