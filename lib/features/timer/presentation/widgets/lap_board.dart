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

  List<_LapRecord> _buildRecords() {
    final records = <_LapRecord>[];
    for (var i = 0; i < laps.length; i++) {
      final previousTotal = i > 0 ? laps[i - 1] : Duration.zero;
      records.add(_LapRecord(lapNumber: i + 1, split: laps[i] - previousTotal, total: laps[i]));
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
          SizedBox(width: 32, child: Text('LAP', style: style)),
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
    required this.totalColor,
    required this.isFastest,
    required this.isSlowest,
  });

  final _LapRecord record;
  final Color accentColor;
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
    final onAccentColor =
        ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: accentColor,
              child: Text(
                '${record.lapNumber}',
                style: TextStyle(color: onAccentColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: SevenSegmentDisplay(
              value: record.split.formattedClock,
              size: 1.6,
              characterSpacing: 2,
              backgroundColor: Colors.transparent,
              segmentStyle: DefaultSegmentStyle(
                enabledColor: splitColor,
                disabledColor: splitColor.withValues(alpha: 0.14),
              ),
            ),
          ),
          Text(
            record.total.formattedClock,
            style: TextStyle(color: totalColor, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}
