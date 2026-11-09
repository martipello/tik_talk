import '../models/lap.dart';

class LapRecord {
  const LapRecord({
    required this.lapNumber,
    required this.split,
    required this.total,
    this.label,
  });

  final int lapNumber;
  final Duration split;
  final Duration total;
  final String? label;
}

// Splits are derived from each lap's *whole-second-rounded* total, rather
// than subtracting the raw (sub-second-precision) Durations directly.
// Otherwise the split and total columns are each rounded independently when
// formatted, and can visibly fail to add up (e.g. totals of 0:10 and 0:16
// next to a split that rounds to 0:05, instead of the 0:06 that would
// actually make 10 + 6 = 16).
List<LapRecord> buildLapRecords(List<Lap> laps) {
  final records = <LapRecord>[];
  var previousTotal = Duration.zero;
  for (var i = 0; i < laps.length; i++) {
    final total = Duration(seconds: (laps[i].elapsed.inMilliseconds / 1000).round());
    records.add(
      LapRecord(
        lapNumber: i + 1,
        split: total - previousTotal,
        total: total,
        label: laps[i].label,
      ),
    );
    previousTotal = total;
  }
  return records;
}
