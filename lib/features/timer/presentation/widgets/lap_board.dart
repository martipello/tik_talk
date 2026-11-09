import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:segment_display/segment_display.dart';

import '../../../../core/extensions/duration_extension.dart';
import '../../../../core/models/lap.dart';
import '../../../../core/theme/dial_face_style.dart';
import '../../../../core/utils/lap_records.dart';

class LapBoard extends StatelessWidget {
  const LapBoard({
    required this.laps,
    required this.accentColor,
    required this.dialFaceStyle,
    this.onLapTap,
    super.key,
  });

  final List<Lap> laps;
  final Color accentColor;
  final DialFaceStyle dialFaceStyle;
  final ValueChanged<int>? onLapTap;

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final records = buildLapRecords(laps);
    final splits = records.map((record) => record.split).toList();
    final fastestSplit = splits.reduce((a, b) => a < b ? a : b);
    final slowestSplit = splits.reduce((a, b) => a > b ? a : b);
    final hasVariation = fastestSplit != slowestSplit;

    return Container(
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
          for (var index = records.length - 1; index >= 0; index--)
            _LapRow(
              record: records[index],
              accentColor: accentColor,
              numberColor: colorScheme.onSurface,
              totalColor: colorScheme.onSurfaceVariant,
              isFastest: hasVariation && records[index].split == fastestSplit,
              isSlowest: hasVariation && records[index].split == slowestSplit,
              dialFaceStyle: dialFaceStyle,
              onTap: onLapTap == null
                  ? null
                  : () => onLapTap!(records[index].lapNumber - 1),
            ),
        ],
      ),
    );
  }
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
          SizedBox(width: 28, child: Text('LAP', style: style)),
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
    required this.dialFaceStyle,
    this.onTap,
  });

  final LapRecord record;
  final Color accentColor;
  final Color numberColor;
  final Color totalColor;
  final bool isFastest;
  final bool isSlowest;
  final DialFaceStyle dialFaceStyle;
  final VoidCallback? onTap;

  static const _fastestColor = Color(0xFF34D97B);
  static const _slowestColor = Color(0xFFE5484D);

  @override
  Widget build(BuildContext context) {
    final splitColor = switch ((isFastest, isSlowest)) {
      (true, _) => _fastestColor,
      (_, true) => _slowestColor,
      _ => accentColor,
    };

    final row = Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '${record.lapNumber}',
            style: TextStyle(color: numberColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _TimeDisplay(
              value: record.split.formattedClock,
              color: splitColor,
              dialFaceStyle: dialFaceStyle,
            ),
          ),
        ),
        _TimeDisplay(
          value: record.total.formattedClock,
          color: totalColor,
          dialFaceStyle: dialFaceStyle,
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: record.label == null
            ? row
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 44, bottom: 2),
                    child: Text(
                      record.label!,
                      style: TextStyle(color: totalColor, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  row,
                ],
              ),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay({required this.value, required this.color, required this.dialFaceStyle});

  final String value;
  final Color color;
  final DialFaceStyle dialFaceStyle;

  @override
  Widget build(BuildContext context) {
    return switch (dialFaceStyle) {
      DialFaceStyle.tikTalk || DialFaceStyle.classicStopwatch => SevenSegmentDisplay(
          value: value,
          size: 2,
          characterSpacing: 2.5,
          backgroundColor: Colors.transparent,
          segmentStyle: DefaultSegmentStyle(
            enabledColor: color,
            disabledColor: color.withValues(alpha: 0.14),
          ),
        ),
      DialFaceStyle.fluidGlass2 => Text(
          value,
          style: GoogleFonts.jost(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
    };
  }
}
