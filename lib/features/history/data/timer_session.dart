import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/lap.dart';

part 'timer_session.freezed.dart';

@freezed
class TimerSession with _$TimerSession {
  const factory TimerSession({
    required int? id,
    required DateTime completedAt,
    required Duration duration,
    required String? label,
    required List<Lap> laps,
  }) = _TimerSession;
}

extension TimerSessionMapper on TimerSession {
  Map<String, Object?> toMap() => {
        'id': id,
        'completed_at': completedAt.toIso8601String(),
        'duration_ms': duration.inMilliseconds,
        'label': label,
        // Kept alongside laps_json (labels are dropped) purely so the
        // sqflite backend's legacy NOT NULL laps_ms column stays satisfied
        // without a migration that rebuilds the table.
        'laps_ms': laps.map((lap) => lap.elapsed.inMilliseconds).join(','),
        'laps_json': jsonEncode(
          laps.map((lap) => {'ms': lap.elapsed.inMilliseconds, 'label': lap.label}).toList(),
        ),
      };

  static TimerSession fromMap(Map<String, Object?> map) => TimerSession(
        id: map['id'] as int?,
        completedAt: DateTime.parse(map['completed_at'] as String),
        duration: Duration(milliseconds: map['duration_ms'] as int),
        label: map['label'] as String?,
        laps: _decodeLaps(map),
      );

  static List<Lap> _decodeLaps(Map<String, Object?> map) {
    final lapsJson = map['laps_json'] as String?;
    if (lapsJson != null) {
      final decoded = jsonDecode(lapsJson) as List<dynamic>;
      return decoded
          .map((entry) => entry as Map<String, dynamic>)
          .map(
            (entry) => Lap(
              elapsed: Duration(milliseconds: entry['ms'] as int),
              label: entry['label'] as String?,
            ),
          )
          .toList();
    }

    // Rows written before per-lap labels existed only have laps_ms.
    final legacy = map['laps_ms'] as String?;
    if (legacy == null || legacy.isEmpty) return [];
    return legacy
        .split(',')
        .where((value) => value.isNotEmpty)
        .map((value) => Lap(elapsed: Duration(milliseconds: int.parse(value))))
        .toList();
  }
}
