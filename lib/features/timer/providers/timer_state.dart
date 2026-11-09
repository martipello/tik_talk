import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/lap.dart';
import 'timer_status.dart';

part 'timer_state.freezed.dart';

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerStatus status,
    required Duration elapsed,
    required List<Lap> laps,
    required int countdownSecondsRemaining,
    required double countdownDialValue,
    String? label,
    // Set when this state originated from resuming a saved history entry, so
    // stop() can update that entry in place instead of inserting a second
    // one for the same session.
    int? resumedSessionId,
  }) = _TimerState;

  factory TimerState.initial() => const TimerState(
        status: TimerStatus.idle,
        elapsed: Duration.zero,
        laps: [],
        countdownSecondsRemaining: 0,
        countdownDialValue: 0,
        label: null,
        resumedSessionId: null,
      );
}
