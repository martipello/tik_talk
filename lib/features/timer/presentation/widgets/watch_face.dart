import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '../../../../core/extensions/duration_extension.dart';
import '../../../../core/theme/dial_theme.dart';
import '../../providers/timer_state.dart';
import '../../providers/timer_status.dart';

class WatchFace extends StatelessWidget {
  const WatchFace({required this.timerState, required this.dialTheme, super.key});

  final TimerState timerState;
  final DialTheme dialTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: switch (dialTheme) {
        DialTheme.classicStopwatch => _ClassicStopwatchFace(timerState: timerState),
        DialTheme.liquidGlass => _LiquidGlassFace(timerState: timerState),
      },
    );
  }
}

String _centerText(TimerState timerState) => switch (timerState.status) {
      TimerStatus.countingIn => timerState.countInSecondsRemaining.toString(),
      _ => timerState.elapsed.formattedClockWithTenths,
    };

class _ClassicStopwatchFace extends StatelessWidget {
  const _ClassicStopwatchFace({required this.timerState});

  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StopwatchFacePainter(
        duration: timerState.elapsed,
        accentColor: DialTheme.classicStopwatch.accentColor,
      ),
      child: Center(
        child: Text(
          _centerText(timerState),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ),
    );
  }
}

class _StopwatchFacePainter extends CustomPainter {
  _StopwatchFacePainter({required this.duration, required this.accentColor});

  final Duration duration;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 4, ringPaint);

    for (var i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi;
      final isMajorTick = i % 5 == 0;
      final tickLength = isMajorTick ? 10.0 : 4.0;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final outer = center + direction * (radius - 8);
      final inner = center + direction * (radius - 8 - tickLength);
      final tickPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.6)
        ..strokeWidth = isMajorTick ? 2.5 : 1.5;
      canvas.drawLine(inner, outer, tickPaint);
    }

    final secondsAngle = ((duration.inMilliseconds % 60000) / 60000) * 2 * math.pi - (math.pi / 2);
    final secondHandPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final secondHandDirection = Offset(math.cos(secondsAngle), math.sin(secondsAngle));
    canvas.drawLine(center, center + secondHandDirection * (radius - 24), secondHandPaint);

    final minutesAngle = ((duration.inMilliseconds % 3600000) / 3600000) * 2 * math.pi - (math.pi / 2);
    final minuteHandPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.85)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final minuteHandDirection = Offset(math.cos(minutesAngle), math.sin(minutesAngle));
    canvas.drawLine(center, center + minuteHandDirection * (radius - 50), minuteHandPaint);

    canvas.drawCircle(center, 4, Paint()..color = accentColor);
  }

  @override
  bool shouldRepaint(covariant _StopwatchFacePainter oldDelegate) => oldDelegate.duration != duration;
}

class _LiquidGlassFace extends StatelessWidget {
  const _LiquidGlassFace({required this.timerState});

  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    final accentColor = DialTheme.liquidGlass.accentColor;
    final secondsIntoMinute = timerState.elapsed.inMilliseconds % 60000;
    final fillLevel = secondsIntoMinute / 60000;

    return LiquidCircularProgressIndicator(
      value: fillLevel,
      valueColor: AlwaysStoppedAnimation(accentColor),
      backgroundColor: accentColor.withValues(alpha: 0.12),
      borderColor: accentColor,
      borderWidth: 3,
      center: Text(
        _centerText(timerState),
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}
