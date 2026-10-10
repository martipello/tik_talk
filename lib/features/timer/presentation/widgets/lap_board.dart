import 'package:flutter/material.dart';
import 'package:segment_display/segment_display.dart';

import '../../../../core/extensions/duration_extension.dart';

class LapBoard extends StatelessWidget {
  const LapBoard({required this.laps, required this.accentColor, super.key});

  final List<Duration> laps;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final records = _buildRecords();
    final splits = records.map((record) => record.split).toList();
    final fastestSplit = splits.reduce((a, b) => a < b ? a : b);
    final slowestSplit = splits.reduce((a, b) => a > b ? a : b);
    final hasVariation = fastestSplit != slowestSplit;

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          _LapBoardHeader(color: colorScheme.onSurfaceVariant),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[records.length - 1 - index];
                return _LapRow(
                  record: record,
                  accentColor: accentColor,
                  numberColor: colorScheme.onSurface,
                  totalColor: colorScheme.onSurfaceVariant,
                  isFastest: hasVariation && record.split == fastestSplit,
                  isSlowest: hasVariation && record.split == slowestSplit,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Splits are derived from each lap's *whole-second-rounded* total, rather
  // than subtracting the raw (sub-second-precision) Durations directly.
  // Otherwise the split and total columns are each rounded independently
  // when formatted, and can visibly fail to add up (e.g. totals of 0:10 and
  // 0:16 next to a split that rounds to 0:05, instead of the 0:06 that
  // would actually make 10 + 6 = 16).
  List<_LapRecord> _buildRecords() {
    final records = <_LapRecord>[];
    var previousTotal = Duration.zero;
    for (var i = 0; i < laps.length; i++) {
      final total = Duration(seconds: (laps[i].inMilliseconds / 1000).round());
      records.add(_LapRecord(lapNumber: i + 1, split: total - previousTotal, total: total));
      previousTotal = total;
    }
    return records;
  }
}

class _LapRecord {
  const _LapRecord({required this.lapNumber, required this.split, required this.total});

  final int lapNumber;
  final Duration split;
  final Duration total;
}

class _LapBoardHeader extends StatelessWidget {
  const _LapBoardHeader({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 20, child: Text('LAP', style: style)),
          const SizedBox(width: 16),
          Expanded(child: Text('SPLIT', style: style)),
          Text('TOTAL', style: style),
        ],
      ),
    );
  }
}

class _LapRow extends StatelessWidget {
  const _LapRow({
    required this.record,
    required this.accentColor,
    required this.numberColor,
    required this.totalColor,
    required this.isFastest,
    required this.isSlowest,
  });

  final _LapRecord record;
  final Color accentColor;
  final Color numberColor;
  final Color totalColor;
  final bool isFastest;
  final bool isSlowest;

  static const _fastestColor = Color(0xFF34D97B);
  static const _slowestColor = Color(0xFFE5484D);

  @override
  Widget build(BuildContext context) {
    final splitColor = switch ((isFastest, isSlowest)) {
      (true, _) => _fastestColor,
      (_, true) => _slowestColor,
      _ => accentColor,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '${record.lapNumber}',
              style: TextStyle(color: numberColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SevenSegmentDisplay(
                  value: record.split.formattedClock,
                  size: 3.2,
                  characterSpacing: 3,
                  backgroundColor: Colors.transparent,
                  segmentStyle: DefaultSegmentStyle(
                    enabledColor: splitColor,
                    disabledColor: splitColor.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
          ),
          Text(
            record.total.formattedClock,
            style: TextStyle(
              color: totalColor,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
