import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/lap.dart';
import '../../../core/services/shared_preferences_provider.dart';
import '../data/history_session_store.dart';
import '../data/history_session_store_platform.dart';
import '../data/timer_session.dart';

part 'history_notifier.g.dart';

@riverpod
HistorySessionStore historySessionStore(Ref ref) =>
    createHistorySessionStore(ref.read(sharedPreferencesProvider));

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  @override
  Future<List<TimerSession>> build() => ref.read(historySessionStoreProvider).fetchAll();

  Future<void> addSession({required Duration duration, required List<Lap> laps}) async {
    await ref.read(historySessionStoreProvider).insert(
          TimerSession(
            id: null,
            completedAt: DateTime.now(),
            duration: duration,
            label: null,
            laps: laps,
          ),
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> relabelSession(int id, String? label) async {
    final sessions = await future;
    final session = sessions.firstWhere((session) => session.id == id);
    await ref.read(historySessionStoreProvider).update(session.copyWith(label: label));
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateSession(
    int id, {
    required Duration duration,
    required List<Lap> laps,
  }) async {
    final sessions = await future;
    final session = sessions.firstWhere((session) => session.id == id);
    await ref.read(historySessionStoreProvider).update(
          session.copyWith(duration: duration, laps: laps, completedAt: DateTime.now()),
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> relabelLap(int sessionId, int lapIndex, String? label) async {
    final sessions = await future;
    final session = sessions.firstWhere((session) => session.id == sessionId);
    final laps = [...session.laps];
    laps[lapIndex] = laps[lapIndex].copyWith(label: label);
    await ref.read(historySessionStoreProvider).update(session.copyWith(laps: laps));
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteSession(int id) async {
    await ref.read(historySessionStoreProvider).delete(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteAll() async {
    await ref.read(historySessionStoreProvider).deleteAll();
    ref.invalidateSelf();
    await future;
  }
}
