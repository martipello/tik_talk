import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:segment_display/segment_display.dart';

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
      width: 280,
      height: 280,
      child: switch (dialTheme) {
        DialTheme.classicStopwatch => _ClassicStopwatchFace(timerState: timerState),
        DialTheme.liquidGlass => _LiquidGlassFace(timerState: timerState),
      },
    );
  }
}

class _ClassicStopwatchFace extends StatelessWidget {
  const _ClassicStopwatchFace({required this.timerState});

  final TimerState timerState;

  static const _digitalReadoutOffsetFraction = 0.46;

  @override
  Widget build(BuildContext context) {
    final accentColor = DialTheme.classicStopwatch.accentColor;
    final isCountingDown = timerState.status == TimerStatus.countingDown;

    return CustomPaint(
      painter: _StopwatchFacePainter(timerState: timerState, accentColor: accentColor),
      child: isCountingDown
          ? Center(
              child: _CountdownDigit(
                value: timerState.countdownSecondsRemaining,
                accentColor: accentColor,
              ),
            )
          : Align(
              alignment: const Alignment(0, _digitalReadoutOffsetFraction),
              child: _DigitalReadout(
                value: timerState.elapsed.formattedClockWithTenths,
                accentColor: accentColor,
              ),
            ),
    );
  }
}

class _DigitalReadout extends StatelessWidget {
  const _DigitalReadout({required this.value, required this.accentColor});

  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SevenSegmentDisplay(
          value: value,
          size: 4.6,
          characterSpacing: 3,
          backgroundColor: Colors.transparent,
          segmentStyle: DefaultSegmentStyle(
            enabledColor: accentColor,
            disabledColor: accentColor.withValues(alpha: 0.14),
          ),
        ),
      ),
    );
  }
}

class _CountdownDigit extends StatelessWidget {
  const _CountdownDigit({required this.value, required this.accentColor});

  final int value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) {
        final isOutgoing = animation.status == AnimationStatus.reverse;
        final scale = isOutgoing
            ? Tween<double>(begin: 1.2, end: 1.0).animate(animation)
            : Tween<double>(begin: 0.8, end: 1.0).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      child: Text(
        '$value',
        key: ValueKey(value),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _StopwatchFacePainter extends CustomPainter {
  _StopwatchFacePainter({required this.timerState, required this.accentColor});

  static const _subDialRadiusFactor = 0.13;
  static const _subDialDistanceFactor = 0.58;
  static const _minutesDialClockAngleDegrees = 45.0;
  static const _runningDialClockAngleDegrees = 75.0;
  static const _outerNotchCount = 48;

  final TimerState timerState;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    _paintShadow(canvas, center, radius);
    _paintFaceBackground(canvas, center, radius);
    _paintOuterNotches(canvas, center, radius);
    _paintBezel(canvas, center, radius);

    _paintDial(canvas, center: center, radius: radius - 18, tickCount: 60, majorEvery: 5);
    _paintHand(
      canvas,
      center: center,
      length: radius - 40,
      angle: _mainHandAngle(),
      strokeWidth: 2.5,
      color: accentColor,
    );

    final subDialRadius = radius * _subDialRadiusFactor;
    final subDialDistance = radius * _subDialDistanceFactor;

    final minutesCenter =
        center + _offsetForClockAngle(_minutesDialClockAngleDegrees, subDialDistance);
    final wholeMinutes = (timerState.elapsed.inMinutes) % 60;
    final minutesAngle = _angleForFraction(wholeMinutes / 60);
    _paintSubDialWell(canvas, minutesCenter, subDialRadius);
    _paintDial(canvas, center: minutesCenter, radius: subDialRadius, tickCount: 12, majorEvery: 3);
    _paintHand(
      canvas,
      center: minutesCenter,
      length: subDialRadius - 6,
      angle: minutesAngle,
      strokeWidth: 1.5,
      color: accentColor.withValues(alpha: 0.85),
    );

    final runningCenter =
        center + _offsetForClockAngle(_runningDialClockAngleDegrees, subDialDistance);
    final runningAngle = _angleForFraction((timerState.elapsed.inMilliseconds % 1000) / 1000);
    _paintSubDialWell(canvas, runningCenter, subDialRadius);
    _paintDial(canvas, center: runningCenter, radius: subDialRadius, tickCount: 10, majorEvery: 5);
    _paintHand(
      canvas,
      center: runningCenter,
      length: subDialRadius - 6,
      angle: runningAngle,
      strokeWidth: 1.5,
      color: accentColor.withValues(alpha: 0.85),
    );

    _paintHub(canvas, center, accentColor);
  }

  double _mainHandAngle() {
    if (timerState.status == TimerStatus.countingDown) {
      return _angleForFraction(timerState.countdownDialValue % 1.0);
    }
    return _angleForFraction((timerState.elapsed.inMilliseconds % 60000) / 60000);
  }

  double _angleForFraction(double fraction) => fraction * 2 * math.pi - (math.pi / 2);

  Offset _offsetForClockAngle(double clockAngleDegrees, double distance) {
    final radians = clockAngleDegrees * math.pi / 180;
    return Offset(math.sin(radians), -math.cos(radians)) * distance;
  }

  void _paintShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center + const Offset(0, 6), radius - 2, shadowPaint);
  }

  void _paintFaceBackground(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius - 6);
    final facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.95,
        colors: [
          Colors.white,
          accentColor.withValues(alpha: 0.05),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius - 6, facePaint);
  }

  void _paintOuterNotches(Canvas canvas, Offset center, double radius) {
    final notchPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..strokeWidth = 2.5;
    for (var i = 0; i < _outerNotchCount; i++) {
      final angle = (i / _outerNotchCount) * 2 * math.pi;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final outer = center + direction * radius;
      final inner = center + direction * (radius - 5);
      canvas.drawLine(inner, outer, notchPaint);
    }
  }

  void _paintBezel(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius - 8);
    final bezelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = SweepGradient(
        colors: [
          accentColor.withValues(alpha: 0.9),
          accentColor.withValues(alpha: 0.3),
          accentColor.withValues(alpha: 0.9),
          accentColor.withValues(alpha: 0.3),
          accentColor.withValues(alpha: 0.9),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius - 8, bezelPaint);
  }

  void _paintSubDialWell(Canvas canvas, Offset dialCenter, double radius) {
    final wellPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.12),
          accentColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromCircle(center: dialCenter, radius: radius));
    canvas.drawCircle(dialCenter, radius, wellPaint);
  }

  void _paintDial(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required int tickCount,
    required int majorEvery,
  }) {
    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius > 60 ? 3 : 1.2;
    canvas.drawCircle(center, radius, ringPaint);

    for (var i = 0; i < tickCount; i++) {
      final angle = (i / tickCount) * 2 * math.pi;
      final isMajorTick = i % majorEvery == 0;
      final tickLength = radius * (isMajorTick ? 0.14 : 0.06);
      final direction = Offset(math.cos(angle), math.sin(angle));
      final tickInset = radius * 0.1;
      final outer = center + direction * (radius - tickInset);
      final inner = center + direction * (radius - tickInset - tickLength);
      final tickPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.6)
        ..strokeWidth = isMajorTick ? 1.8 : 1;
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  void _paintHand(
    Canvas canvas, {
    required Offset center,
    required double length,
    required double angle,
    required double strokeWidth,
    required Color color,
  }) {
    final direction = Offset(math.cos(angle), math.sin(angle));
    final tip = center + direction * length;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center + const Offset(0.8, 0.8), tip + const Offset(0.8, 0.8), shadowPaint);

    final handPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, handPaint);
  }

  void _paintHub(Canvas canvas, Offset center, Color color) {
    final hubPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [Colors.white, color],
      ).createShader(Rect.fromCircle(center: center, radius: 5));
    canvas.drawCircle(center, 5, hubPaint);
  }

  @override
  bool shouldRepaint(covariant _StopwatchFacePainter oldDelegate) =>
      oldDelegate.timerState != timerState;
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
        timerState.status == TimerStatus.countingDown
            ? timerState.countdownSecondsRemaining.toString()
            : timerState.elapsed.formattedClockWithTenths,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}
