import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  Future<void> addSession({required Duration duration, required List<Duration> laps}) async {
    await ref
        .read(historySessionStoreProvider)
        .insert(TimerSession(id: null, completedAt: DateTime.now(), duration: duration, laps: laps));
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
