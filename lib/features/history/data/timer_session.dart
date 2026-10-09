import 'package:freezed_annotation/freezed_annotation.dart';

import '../../timer/providers/timer_mode.dart';

part 'timer_session.freezed.dart';

@freezed
class TimerSession with _$TimerSession {
  const factory TimerSession({
    required int? id,
    required TimerMode mode,
    required DateTime completedAt,
    required Duration duration,
    required List<Duration> laps,
  }) = _TimerSession;
}

extension TimerSessionMapper on TimerSession {
  Map<String, Object?> toMap() => {
        'id': id,
        'mode': mode.name,
        'completed_at': completedAt.toIso8601String(),
        'duration_ms': duration.inMilliseconds,
        'laps_ms': laps.map((lap) => lap.inMilliseconds).join(','),
      };

  static TimerSession fromMap(Map<String, Object?> map) => TimerSession(
        id: map['id'] as int?,
        mode: TimerMode.values.byName(map['mode'] as String),
        completedAt: DateTime.parse(map['completed_at'] as String),
        duration: Duration(milliseconds: map['duration_ms'] as int),
        laps: (map['laps_ms'] as String)
            .split(',')
            .where((value) => value.isNotEmpty)
            .map((value) => Duration(milliseconds: int.parse(value)))
            .toList(),
      );
}
