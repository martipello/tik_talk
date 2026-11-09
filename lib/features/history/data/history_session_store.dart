import 'timer_session.dart';

abstract class HistorySessionStore {
  Future<List<TimerSession>> fetchAll();

  Future<void> insert(TimerSession session);

  Future<void> update(TimerSession session);

  Future<void> delete(int id);

  Future<void> deleteAll();
}
