import '../models/models.dart';
import 'database_helper.dart';
import 'database_interface.dart';

class DatabaseServiceImpl implements DatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<UserConfig> getUserConfig() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_config',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserConfig.fromMap(maps.first);
    }

    // 기본값 (Seeding에서 생성되지만 방어 코드)
    return UserConfig(
      id: 1,
      isPremium: false,
      delayPolicy: 'NONE',
      languageCode: 'auto',
    );
  }

  @override
  Future<void> saveUserConfig(UserConfig config) async {
    final db = await _dbHelper.database;
    await db.update(
      'user_config',
      config.toMap(),
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  @override
  Future<List<Routine>> getRoutines() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('routines');
    return List.generate(maps.length, (i) => Routine.fromMap(maps[i]));
  }

  @override
  Future<Routine?> getActiveRoutine() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routines',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Routine.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> setActiveRoutine(int id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // 모든 루틴의 비활성화
      await txn.update('routines', {'is_active': 0});
      // 지정 루틴의 활성화
      await txn.update(
        'routines',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> saveRoutine(Routine routine) async {
    final db = await _dbHelper.database;
    if (routine.id != null) {
      await db.update(
        'routines',
        routine.toMap(),
        where: 'id = ?',
        whereArgs: [routine.id],
      );
    } else {
      await db.insert('routines', routine.toMap());
    }
  }

  @override
  Future<void> deleteRoutine(int id) async {
    final db = await _dbHelper.database;
    await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<RoutineItem>> getRoutineItems(int routineId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routine_items',
      where: 'routine_id = ?',
      whereArgs: [routineId],
      orderBy: 'order_index ASC',
    );
    return List.generate(maps.length, (i) => RoutineItem.fromMap(maps[i]));
  }

  @override
  Future<void> saveRoutineItem(RoutineItem item) async {
    final db = await _dbHelper.database;
    if (item.id != null) {
      await db.update(
        'routine_items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } else {
      await db.insert('routine_items', item.toMap());
    }
  }

  @override
  Future<void> deleteRoutineItem(int itemId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'routine_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  @override
  Future<void> logExecution({
    required String itemName,
    required Duration planned,
    required Duration actual,
  }) async {
    final db = await _dbHelper.database;
    await db.insert('history', {
      'date': DateTime.now().toIso8601String(),
      'item_name': itemName,
      'planned_min': planned.inMinutes,
      'actual_min': actual.inMinutes,
      'is_success': actual <= planned ? 1 : 0,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await _dbHelper.database;
    return await db.query('history', orderBy: 'date DESC');
  }
}
