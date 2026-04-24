import '../models/models.dart';

/// DatabaseService Interface
/// v1.1 설계에 따라 최적화된 데이터 액세스 레이어
abstract class DatabaseService {
  // User Configuration
  Future<UserConfig> getUserConfig();
  Future<void> saveUserConfig(UserConfig config);

  // Routines (Presets & Custom)
  Future<List<Routine>> getRoutines();
  Future<Routine?> getActiveRoutine();
  Future<void> setActiveRoutine(int id);
  Future<void> saveRoutine(Routine routine);
  Future<void> deleteRoutine(int id);

  // Routine Items
  Future<List<RoutineItem>> getRoutineItems(int routineId);
  Future<void> saveRoutineItem(RoutineItem item);
  Future<void> deleteRoutineItem(int itemId);

  // History (Stats)
  Future<void> logExecution({
    required String itemName,
    required Duration planned,
    required Duration actual,
  });
  Future<List<Map<String, dynamic>>> getHistory();
}
