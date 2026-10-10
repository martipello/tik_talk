import 'package:freezed_annotation/freezed_annotation.dart';

import 'timer_status.dart';

part 'timer_state.freezed.dart';

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerStatus status,
    required Duration elapsed,
    required List<Duration> laps,
    required int countInSecondsRemaining,
  }) = _TimerState;

  factory TimerState.initial() => const TimerState(
        status: TimerStatus.idle,
        elapsed: Duration.zero,
        laps: [],
        countInSecondsRemaining: 0,
      );
}
