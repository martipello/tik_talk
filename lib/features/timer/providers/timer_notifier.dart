import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/lap.dart';
import '../../../core/services/service_providers.dart';
import '../../history/data/timer_session.dart';
import '../../history/providers/history_notifier.dart';
import '../../settings/providers/settings_notifier.dart';
import 'timer_state.dart';
import 'timer_status.dart';

part 'timer_notifier.g.dart';

// keepAlive: HistoryPage resumes a session via a one-off ref.read, with no
// guarantee anything is watching this provider yet (e.g. the Timer tab's
// branch hasn't been built lazily if it's never been visited this session) -
// autoDispose could tear the state back down before TimerPage's own watch
// attaches, racily discarding the resumed session. The same persistence is
// also just correct for a running stopwatch, which must not reset itself
// just because nothing happens to be watching while the user is on another
// tab.
@Riverpod(keepAlive: true)
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
    state = state.copyWith(laps: [...state.laps, Lap(elapsed: state.elapsed)]);
  }

  void relabelLap(int index, String? label) {
    final laps = [...state.laps];
    laps[index] = laps[index].copyWith(label: label);
    state = state.copyWith(laps: laps);
  }

  Future<void> stop() async {
    _ticker?.cancel();
    _countdownTicker?.cancel();
    if (state.elapsed > Duration.zero) {
      final historyNotifier = ref.read(historyNotifierProvider.notifier);
      final resumedSessionId = state.resumedSessionId;
      if (resumedSessionId != null) {
        await historyNotifier.updateSession(
          resumedSessionId,
          duration: state.elapsed,
          laps: state.laps,
        );
      } else {
        await historyNotifier.addSession(duration: state.elapsed, laps: state.laps);
      }
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
      label: session.label,
      resumedSessionId: session.id,
    );
  }

  void _beginCountdown(int countdownSeconds) {
    final startDialValue = (state.elapsed.inMilliseconds % 1000) / 1000.0;
    state = state.copyWith(
      status: TimerStatus.countingDown,
      countdownSecondsRemaining: countdownSeconds,
      countdownDialValue: startDialValue,
    );
    _speak('$countdownSeconds');
    _countdownTicker?.cancel();
    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) => _countdownTick());
  }

  void _countdownTick() {
    final remaining = state.countdownSecondsRemaining - 1;
    if (remaining <= 0) {
      _countdownTicker?.cancel();
      _speak('Go');
      _beginRunning();
      return;
    }

    state = state.copyWith(
      countdownSecondsRemaining: remaining,
      countdownDialValue: state.countdownDialValue - 1,
    );
    _speak('$remaining');
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
    final interval = ref.read(settingsNotifierProvider).voiceAnnounceInterval;
    _speak(interval.speaksBareNumber ? '${state.elapsed.inSeconds}' : _announceText(state.elapsed));
  }

  void _speak(String text) {
    if (ref.read(settingsNotifierProvider).ttsMuted) return;
    unawaited(ref.read(ttsServiceProvider).speak(text));
  }

  int _currentIntervalCount() {
    final interval = ref.read(settingsNotifierProvider).voiceAnnounceInterval.duration;
    if (interval == null) return 0;
    return state.elapsed.inMilliseconds ~/ interval.inMilliseconds;
  }

  String _announceText(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final minutesText = '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    final secondsText = '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
    if (minutes == 0) return secondsText;
    if (seconds == 0) return minutesText;
    return '$minutesText $secondsText';
  }
}




