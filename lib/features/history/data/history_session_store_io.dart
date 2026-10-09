import 'package:path/path.dart' as path_helper;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'history_session_store.dart';
import 'timer_session.dart';

HistorySessionStore createHistorySessionStore(SharedPreferences preferences) =>
    SqfliteHistorySessionStore();

class SqfliteHistorySessionStore implements HistorySessionStore {
  Database? _database;

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) return existing;

    final databasesPath = await getDatabasesPath();
    final databasePath = path_helper.join(databasesPath, 'tik_talk_history.db');

    final opened = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) => database.execute('''
        CREATE TABLE sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mode TEXT NOT NULL,
          completed_at TEXT NOT NULL,
          duration_ms INTEGER NOT NULL,
          laps_ms TEXT NOT NULL
        )
      '''),
    );
    _database = opened;
    return opened;
  }

  @override
  Future<List<TimerSession>> fetchAll() async {
    final database = await _open();
    final rows = await database.query('sessions', orderBy: 'completed_at DESC');
    return rows.map(TimerSessionMapper.fromMap).toList();
  }

  @override
  Future<void> insert(TimerSession session) async {
    final database = await _open();
    await database.insert('sessions', session.toMap()..remove('id'));
  }

  @override
  Future<void> delete(int id) async {
    final database = await _open();
    await database.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAll() async {
    final database = await _open();
    await database.delete('sessions');
  }
}
