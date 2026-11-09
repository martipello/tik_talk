import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'history_session_store.dart';
import 'timer_session.dart';

HistorySessionStore createHistorySessionStore(SharedPreferences preferences) =>
    WebHistorySessionStore(preferences);

class WebHistorySessionStore implements HistorySessionStore {
  WebHistorySessionStore(this._preferences);

  static const _sessionsKey = 'history_sessions';

  final SharedPreferences _preferences;

  @override
  Future<List<TimerSession>> fetchAll() async {
    final sessions = _readAll();
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  @override
  Future<void> insert(TimerSession session) async {
    final sessions = _readAll();
    sessions.add(session.copyWith(id: DateTime.now().microsecondsSinceEpoch));
    await _writeAll(sessions);
  }

  @override
  Future<void> update(TimerSession session) async {
    final sessions = _readAll();
    final index = sessions.indexWhere((existing) => existing.id == session.id);
    if (index == -1) return;
    sessions[index] = session;
    await _writeAll(sessions);
  }

  @override
  Future<void> delete(int id) async {
    final sessions = _readAll()..removeWhere((session) => session.id == id);
    await _writeAll(sessions);
  }

  @override
  Future<void> deleteAll() async {
    await _preferences.remove(_sessionsKey);
  }

  List<TimerSession> _readAll() {
    final raw = _preferences.getString(_sessionsKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => TimerSessionMapper.fromMap(entry as Map<String, Object?>))
        .toList();
  }

  Future<void> _writeAll(List<TimerSession> sessions) async {
    final encoded = jsonEncode(sessions.map((session) => session.toMap()).toList());
    await _preferences.setString(_sessionsKey, encoded);
  }
}
