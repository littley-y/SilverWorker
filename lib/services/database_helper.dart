import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'silver_worker_now.db');
    return await openDatabase(
      path,
      version: 4,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. user_config Table
    await db.execute('''
      CREATE TABLE user_config(
        id INTEGER PRIMARY KEY,
        is_premium INTEGER DEFAULT 0,
        delay_policy TEXT DEFAULT 'NONE',
        language_code TEXT DEFAULT 'auto',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // ... (routines, routine_items, history 테이블 생성 코드는 동일)
    await db.execute('''
      CREATE TABLE routines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_active INTEGER DEFAULT 0,
        is_preset INTEGER DEFAULT 0,
        active_days TEXT,
        must_leave_time TEXT DEFAULT '08:00'
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        estimated_minutes INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (routine_id) REFERENCES routines (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        item_name TEXT NOT NULL,
        planned_min INTEGER NOT NULL,
        actual_min INTEGER NOT NULL,
        is_success INTEGER NOT NULL
      )
    ''');

    // 초기 데이터 삽입 (Seeding)
    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // language_code 컬럼 추가
      await db.execute(
        'ALTER TABLE user_config ADD COLUMN language_code TEXT DEFAULT "auto"',
      );

      // routines 테이블에 누락된 필드가 있다면 추가 (필요 시)
      try {
        await db.execute('ALTER TABLE routines ADD COLUMN active_days TEXT');
        await db.execute(
          'ALTER TABLE routines ADD COLUMN must_leave_time TEXT DEFAULT "08:00"',
        );
      } catch (e) {
        // 이미 존재하면 무시
      }
    }
    if (oldVersion < 3) {
      // buffer_minutes는 v3에서 추가되었으나 v4부터 미사용.
      // SQLite 3.35+ 에서는 DROP COLUMN 가능하지만 호환성을 위해 남겨둠.
      try {
        await db.execute(
          'ALTER TABLE user_config ADD COLUMN buffer_minutes INTEGER DEFAULT 5',
        );
      } catch (_) {}
    }
    // v4: buffer_minutes 사용 중단. 데이터 변경 없음 — 신규 설치만 컬럼 없음.
  }

  Future<void> _seedInitialData(Database db) async {
    // 1. 기본 사용자 설정
    await db.insert('user_config', {
      'id': 1,
      'is_premium': 0,
      'delay_policy': 'NONE',
      'language_code': 'auto',
    });

    // 2. 프리셋 루틴 삽입
    final minimalistId = await db.insert('routines', {
      'name': 'l10n:routine_1',
      'is_preset': 1,
      'is_active': 1,
    });
    final maleStandardId = await db.insert('routines', {
      'name': 'l10n:routine_2',
      'is_preset': 1,
      'is_active': 0,
    });

    // 3. 프리셋 상세 항목 삽입

    // 루틴 1
    await db.insert('routine_items', {
      'routine_id': minimalistId,
      'name': 'l10n:item_step 1',
      'estimated_minutes': 10,
      'order_index': 0,
    });
    await db.insert('routine_items', {
      'routine_id': minimalistId,
      'name': 'l10n:item_step 2',
      'estimated_minutes': 10,
      'order_index': 1,
    });

    // 루틴 2
    await db.insert('routine_items', {
      'routine_id': maleStandardId,
      'name': 'l10n:item_step 1',
      'estimated_minutes': 10,
      'order_index': 0,
    });
    await db.insert('routine_items', {
      'routine_id': maleStandardId,
      'name': 'l10n:item_step 2',
      'estimated_minutes': 10,
      'order_index': 1,
    });
    await db.insert('routine_items', {
      'routine_id': maleStandardId,
      'name': 'l10n:item_step 3',
      'estimated_minutes': 10,
      'order_index': 2,
    });
    await db.insert('routine_items', {
      'routine_id': maleStandardId,
      'name': 'l10n:item_step 4',
      'estimated_minutes': 10,
      'order_index': 3,
    });
  }
}
