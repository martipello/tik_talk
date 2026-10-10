import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/service_providers.dart';
import '../../history/providers/history_notifier.dart';
import '../../settings/providers/settings_notifier.dart';
import 'timer_state.dart';
import 'timer_status.dart';

part 'timer_notifier.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;
  Timer? _countInTicker;
  Duration _lastAnnounced = Duration.zero;

  @override
  TimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _countInTicker?.cancel();
    });
    return TimerState.initial();
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    if (state.status == TimerStatus.idle) {
      final countInSeconds = ref.read(settingsNotifierProvider).countInSeconds;
      if (countInSeconds > 0) {
        _beginCountIn(countInSeconds);
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
    _countInTicker?.cancel();
    if (state.elapsed > Duration.zero) {
      await ref
          .read(historyNotifierProvider.notifier)
          .addSession(duration: state.elapsed, laps: state.laps);
    }
    state = TimerState.initial();
  }

  void _beginCountIn(int countInSeconds) {
    state = state.copyWith(status: TimerStatus.countingIn, countInSecondsRemaining: countInSeconds);
    unawaited(ref.read(ttsServiceProvider).speak('$countInSeconds'));
    _countInTicker?.cancel();
    _countInTicker = Timer.periodic(const Duration(seconds: 1), (_) => _countInTick());
  }

  void _countInTick() {
    final remaining = state.countInSecondsRemaining - 1;
    if (remaining <= 0) {
      _countInTicker?.cancel();
      unawaited(ref.read(ttsServiceProvider).speak('Go'));
      _beginRunning();
      return;
    }

    state = state.copyWith(countInSecondsRemaining: remaining);
    unawaited(ref.read(ttsServiceProvider).speak('$remaining'));
  }

  void _beginRunning() {
    state = state.copyWith(status: TimerStatus.running, countInSecondsRemaining: 0);
    _lastAnnounced = state.elapsed;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _tick() {
    state = state.copyWith(elapsed: state.elapsed + const Duration(milliseconds: 100));
    _announceIfNeeded();
  }

  void _announceIfNeeded() {
    final interval = ref.read(settingsNotifierProvider).voiceAnnounceInterval.duration;
    if (interval == null) return;

    final sinceLastAnnounced = (state.elapsed - _lastAnnounced).abs();
    if (sinceLastAnnounced < interval) return;

    _lastAnnounced = state.elapsed;
    unawaited(ref.read(ttsServiceProvider).speak(_announceText(state.elapsed)));
  }

  String _announceText(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) return '$seconds seconds';
    if (seconds == 0) return '$minutes minutes';
    return '$minutes minutes $seconds seconds';
  }
}
