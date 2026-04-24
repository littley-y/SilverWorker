import '../models/models.dart';
import 'database_interface.dart';

class MockDatabaseService implements DatabaseService {
  UserConfig _config = UserConfig(
    id: 1,
    isPremium: false,
    delayPolicy: 'NONE',
    languageCode: 'auto',
  );

  final List<Routine> _routines = [
    Routine(
      id: 1,
      name: 'l10n:routine_1',
      isActive: true,
      isPreset: true,
    ),
    Routine(
      id: 2,
      name: 'l10n:routine_2',
      isActive: false,
      isPreset: true,
    ),
  ];

  final Map<int, List<RoutineItem>> _routineItems = {
    1: [
      RoutineItem(
          id: 1,
          routineId: 1,
          name: 'l10n:item_step 1',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 0),
      RoutineItem(
          id: 2,
          routineId: 1,
          name: 'l10n:item_step 2',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 1),
    ],
    2: [
      RoutineItem(
          id: 3,
          routineId: 2,
          name: 'l10n:item_step 1',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 0),
      RoutineItem(
          id: 4,
          routineId: 2,
          name: 'l10n:item_step 2',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 1),
      RoutineItem(
          id: 5,
          routineId: 2,
          name: 'l10n:item_step 3',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 2),
      RoutineItem(
          id: 6,
          routineId: 2,
          name: 'l10n:item_step 4',
          estimatedDuration: const Duration(minutes: 10),
          orderIndex: 3),
    ]
  };

  int _nextItemId = 7;

  final List<Map<String, dynamic>> _history = [];

  @override
  Future<UserConfig> getUserConfig() async => _config;

  @override
  Future<void> saveUserConfig(UserConfig config) async {
    _config = config;
  }

  @override
  Future<List<Routine>> getRoutines() async => _routines;

  @override
  Future<Routine?> getActiveRoutine() async {
    try {
      return _routines.firstWhere((r) => r.isActive);
    } catch (e) {
      return _routines.first;
    }
  }

  @override
  Future<void> setActiveRoutine(int id) async {
    for (int i = 0; i < _routines.length; i++) {
      final r = _routines[i];
      _routines[i] = r.copyWith(isActive: r.id == id);
    }
  }

  @override
  Future<void> saveRoutine(Routine routine) async {
    if (routine.id != null) {
      final index = _routines.indexWhere((r) => r.id == routine.id);
      if (index >= 0) {
        _routines[index] = routine;
      } else {
        _routines.add(routine);
      }
    } else {
      _routines.add(routine.copyWith(id: _routines.length + 1));
    }
  }

  @override
  Future<void> deleteRoutine(int id) async {
    _routines.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<RoutineItem>> getRoutineItems(int routineId) async {
    return List.from(_routineItems[routineId] ?? []);
  }

  @override
  Future<void> saveRoutineItem(RoutineItem item) async {
    final items = _routineItems[item.routineId] ?? [];
    if (item.id != null) {
      final index = items.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        items[index] = item;
      } else {
        items.add(item);
      }
    } else {
      items.add(item.copyWith(id: _nextItemId++));
    }
    _routineItems[item.routineId] = items;
  }

  @override
  Future<void> deleteRoutineItem(int itemId) async {
    for (final key in _routineItems.keys) {
      _routineItems[key]?.removeWhere((item) => item.id == itemId);
    }
  }

  @override
  Future<void> logExecution({
    required String itemName,
    required Duration planned,
    required Duration actual,
  }) async {
    _history.add({
      'item_name': itemName,
      'planned_min': planned.inMinutes,
      'actual_min': actual.inMinutes,
      'is_success': actual <= planned ? 1 : 0,
      'date': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory() async =>
      List.unmodifiable(_history.reversed);
}
