import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alarm_provider.dart';
import '../models/models.dart';
import '../l10n/app_localizations.dart';

/// 프리셋 목록을 가져오는 FutureProvider
final routineListProvider = FutureProvider<List<Routine>>((ref) async {
  final dbService = ref.read(databaseServiceProvider);
  return await dbService.getRoutines();
});

class PresetSelectionScreen extends ConsumerWidget {
  const PresetSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routineListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.routinePresetSelection,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      body: routinesAsync.when(
        data: (routines) => ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final routine = routines[index];
            final isActive = routine.isActive;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isActive ? const Color(0xFF007AFF) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                title: Text(
                  _getLocalizedRoutineName(routine.name, l10n),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    letterSpacing: -0.5,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    routine.isPreset ? l10n.systemPreset : l10n.userRoutine,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing: isActive
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF007AFF), size: 28)
                    : const Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: Color(0xFFC7C7CC)),
                onTap: () async {
                  if (routine.id != null) {
                    await ref
                        .read(alarmProvider.notifier)
                        .switchRoutine(routine.id!);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            );
          },
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF007AFF))),
        error: (err, stack) => Center(child: Text(l10n.errorOccurred(err))),
      ),
    );
  }

  String _getLocalizedRoutineName(String name, AppLocalizations l10n) {
    if (name == 'l10n:routine_1') return l10n.routine_1;
    if (name == 'l10n:routine_2') return l10n.routine_2;
    if (name == 'l10n:routine_ui_test') return l10n.routine_ui_test;
    return name;
  }
}
