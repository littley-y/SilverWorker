import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE routines(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)
        ''');
        await db.execute('''
          CREATE TABLE routine_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            routine_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            FOREIGN KEY (routine_id) REFERENCES routines (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  });

  tearDown(() => db.close());

  test('deleting a routine cascades to its items when FK is ON', () async {
    final routineId = await db.insert('routines', {'name': 'R1'});
    await db
        .insert('routine_items', {'routine_id': routineId, 'name': 'Item1'});
    await db
        .insert('routine_items', {'routine_id': routineId, 'name': 'Item2'});

    expect(
      Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM routine_items'),
      ),
      2,
    );

    await db.delete('routines', where: 'id = ?', whereArgs: [routineId]);

    expect(
      Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM routine_items'),
      ),
      0,
      reason: 'CASCADE should have removed orphaned items',
    );
  });

  test('DatabaseHelper configures FK cascade for real db', () async {
    // DatabaseHelper는 path_provider 의존성이 있어 단위 테스트 어려움.
    // 여기서는 _onConfigure의 PRAGMA 적용이 스키마에 포함되는지 간접 확인.
    // DatabaseHelper의 실제 동작은 instrumentation test에서 검증 (별도 PR).
  }, skip: 'instrumentation test required');
}
