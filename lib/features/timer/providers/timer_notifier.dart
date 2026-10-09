import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/service_providers.dart';
import '../../history/providers/history_notifier.dart';
import '../../settings/providers/settings_notifier.dart';
import 'timer_mode.dart';
import 'timer_state.dart';
import 'timer_status.dart';

part 'timer_notifier.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;
  Duration _lastAnnounced = Duration.zero;

  @override
  TimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return TimerState.initial();
  }

  void setMode(TimerMode mode) {
    if (state.status != TimerStatus.idle) return;
    state = state.copyWith(mode: mode);
  }

  void startCountdownTimer() {
    final countdownFromSeconds = ref.read(settingsNotifierProvider).countdownFromSeconds;
    state = state.copyWith(
      mode: TimerMode.countdown,
      countdownFrom: Duration(seconds: countdownFromSeconds),
    );
    start();
  }

  void start() {
    if (state.status == TimerStatus.running) return;
    state = state.copyWith(status: TimerStatus.running);
    _lastAnnounced = state.elapsed;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void pause() {
    if (state.status != TimerStatus.running) return;
    _ticker?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void lap() {
    if (state.status != TimerStatus.running) return;
    state = state.copyWith(laps: [...state.laps, state.elapsed]);
  }

  Future<void> stop() async {
    _ticker?.cancel();
    if (state.elapsed > Duration.zero) {
      await ref.read(historyNotifierProvider.notifier).addSession(
            mode: state.mode,
            duration: state.mode == TimerMode.countdown ? state.countdownFrom : state.elapsed,
            laps: state.laps,
          );
    }
    state = TimerState.initial();
  }

  void _tick() {
    final elapsed = state.elapsed + const Duration(milliseconds: 100);

    if (state.mode == TimerMode.countdown && elapsed >= state.countdownFrom) {
      _ticker?.cancel();
      state = state.copyWith(elapsed: state.countdownFrom, status: TimerStatus.finished);
      unawaited(ref.read(ttsServiceProvider).speak('Time'));
      return;
    }

    state = state.copyWith(elapsed: elapsed);
    _announceIfNeeded();
  }

  void _announceIfNeeded() {
    final interval = ref.read(settingsNotifierProvider).voiceAnnounceInterval.duration;
    if (interval == null) return;

    final sinceLastAnnounced = (state.elapsed - _lastAnnounced).abs();
    if (sinceLastAnnounced < interval) return;

    _lastAnnounced = state.elapsed;
    unawaited(ref.read(ttsServiceProvider).speak(_announceText(state.displayDuration)));
  }

  String _announceText(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) return '$seconds seconds';
    if (seconds == 0) return '$minutes minutes';
    return '$minutes minutes $seconds seconds';
  }
}
