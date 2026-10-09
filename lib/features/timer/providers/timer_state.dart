import 'package:freezed_annotation/freezed_annotation.dart';

import 'timer_mode.dart';
import 'timer_status.dart';

part 'timer_state.freezed.dart';

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerStatus status,
    required TimerMode mode,
    required Duration elapsed,
    required List<Duration> laps,
    required Duration countdownFrom,
  }) = _TimerState;

  factory TimerState.initial() => const TimerState(
        status: TimerStatus.idle,
        mode: TimerMode.stopwatch,
        elapsed: Duration.zero,
        laps: [],
        countdownFrom: Duration.zero,
      );
}

extension TimerStateX on TimerState {
  Duration get displayDuration => switch (mode) {
        TimerMode.stopwatch => elapsed,
        TimerMode.countdown =>
          countdownFrom - elapsed < Duration.zero ? Duration.zero : countdownFrom - elapsed,
      };
}
