import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/service_providers.dart';
import '../../history/data/timer_session.dart';
import '../../history/providers/history_notifier.dart';
import '../../settings/providers/settings_notifier.dart';
import 'timer_state.dart';
import 'timer_status.dart';

part 'timer_notifier.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;
  Timer? _countdownTicker;
  int _lastAnnouncedIntervalCount = 0;

  @override
  TimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _countdownTicker?.cancel();
    });
    return TimerState.initial();
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    if (state.status == TimerStatus.idle) {
      final countdownSeconds = ref.read(settingsNotifierProvider).countdownSeconds;
      if (countdownSeconds > 0) {
        _beginCountdown(countdownSeconds);
        return;
      }
    }

    _beginRunning();
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
    _countdownTicker?.cancel();
    if (state.elapsed > Duration.zero) {
      await ref
          .read(historyNotifierProvider.notifier)
          .addSession(duration: state.elapsed, laps: state.laps);
    }
    state = TimerState.initial();
  }

  void resumeSession(TimerSession session) {
    _ticker?.cancel();
    _countdownTicker?.cancel();
    state = TimerState.initial().copyWith(
      status: TimerStatus.paused,
      elapsed: session.duration,
      laps: session.laps,
    );
  }

  void _beginCountdown(int countdownSeconds) {
    final startDialValue = (state.elapsed.inMilliseconds % 1000) / 1000.0;
    state = state.copyWith(
      status: TimerStatus.countingDown,
      countdownSecondsRemaining: countdownSeconds,
      countdownDialValue: startDialValue,
    );
    unawaited(ref.read(ttsServiceProvider).speak('$countdownSeconds'));
    _countdownTicker?.cancel();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) => _countdownTick());
  }

  void _countdownTick() {
    final remaining = state.countdownSecondsRemaining - 1;
    if (remaining <= 0) {
      _countdownTicker?.cancel();
      unawaited(ref.read(ttsServiceProvider).speak('Go'));
      _beginRunning();
      return;
    }

    state = state.copyWith(
      countdownSecondsRemaining: remaining,
      countdownDialValue: state.countdownDialValue - 1,
    );
    unawaited(ref.read(ttsServiceProvider).speak('$remaining'));
  }

  void _beginRunning() {
    state = state.copyWith(status: TimerStatus.running, countdownSecondsRemaining: 0);
    _lastAnnouncedIntervalCount = _currentIntervalCount();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _tick() {
    state = state.copyWith(elapsed: state.elapsed + const Duration(milliseconds: 100));
    _announceIfNeeded();
  }

  // Announcements land on absolute elapsed-time boundaries (1:00, 2:00, ...)
  // rather than "interval since last spoken" - otherwise resuming a session
  // partway into an interval (e.g. at 0:16) would permanently offset every
  // future announcement by that amount (1:16, 2:16, ...) instead of landing
  // on the minute.
  void _announceIfNeeded() {
    final currentIntervalCount = _currentIntervalCount();
    if (currentIntervalCount <= _lastAnnouncedIntervalCount) return;

    _lastAnnouncedIntervalCount = currentIntervalCount;
    unawaited(ref.read(ttsServiceProvider).speak(_announceText(state.elapsed)));
  }

  int _currentIntervalCount() {
    final interval = ref.read(settingsNotifierProvider).voiceAnnounceInterval.duration;
    if (interval == null) return 0;
    return state.elapsed.inMilliseconds ~/ interval.inMilliseconds;
  }

  String _announceText(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) return '$seconds seconds';
    if (seconds == 0) return '$minutes minutes';
    return '$minutes minutes $seconds seconds';
  }
}
