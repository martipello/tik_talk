import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:segment_display/segment_display.dart';

import '../../../../core/extensions/duration_extension.dart';
import '../../../../core/theme/dial_face_style.dart';
import '../../providers/timer_state.dart';
import '../../providers/timer_status.dart';

const _glowColor = Color(0xFF9FE870);

class WatchFace extends StatelessWidget {
  const WatchFace({
    required this.timerState,
    required this.dialFaceStyle,
    required this.accentColor,
    this.isGlowing = false,
    super.key,
  });

  final TimerState timerState;
  final DialFaceStyle dialFaceStyle;
  final Color accentColor;
  final bool isGlowing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return ClipRect(
          child: SizedBox(
            width: size,
            height: size,
            child: switch (dialFaceStyle) {
              DialFaceStyle.classicStopwatch => _ClassicStopwatchFace(
                  timerState: timerState,
                  accentColor: accentColor,
                  isGlowing: isGlowing,
                ),
              DialFaceStyle.fluidGlass => _FluidGlassFace(
                  timerState: timerState,
                  accentColor: accentColor,
                  isGlowing: isGlowing,
                ),
            },
          ),
        );
      },
    );
  }
}

class _ClassicStopwatchFace extends StatelessWidget {
  const _ClassicStopwatchFace({
    required this.timerState,
    required this.accentColor,
    required this.isGlowing,
  });

  final TimerState timerState;
  final Color accentColor;
  final bool isGlowing;

  static const _digitalReadoutOffsetFraction = 0.46;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCountingDown = timerState.status == TimerStatus.countingDown;
    final faceColor = isDark ? const Color(0xFF3A3A3D) : const Color(0xFFF7F4EC);
    final tickColor = isDark ? Colors.white : Colors.black;
    final readoutColor = isGlowing ? _glowColor : accentColor;

    return CustomPaint(
      painter: _StopwatchFacePainter(
        timerState: timerState,
        accentColor: accentColor,
        faceColor: faceColor,
        tickColor: tickColor,
        isGlowing: isGlowing,
      ),
      child: isCountingDown
          ? Center(
              child: _CountdownDigit(
                value: timerState.countdownSecondsRemaining,
                accentColor: readoutColor,
              ),
            )
          : Align(
              alignment: const Alignment(0, _digitalReadoutOffsetFraction),
              child: _DigitalReadout(
                value: timerState.elapsed.formattedClockWithTenths,
                accentColor: readoutColor,
                isDark: isDark,
              ),
            ),
    );
  }
}

class _DigitalReadout extends StatelessWidget {
  const _DigitalReadout({required this.value, required this.accentColor, required this.isDark});

  final String value;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final panelColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    return DecoratedBox(
      decoration: BoxDecoration(color: panelColor, borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SizedBox(
          width: 168,
          child: FittedBox(
            fit: BoxFit.scaleDown,
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
  _StopwatchFacePainter({
    required this.timerState,
    required this.accentColor,
    required this.faceColor,
    required this.tickColor,
    required this.isGlowing,
  });

  static const _margin = 10.0;
  static const _subDialRadiusFactor = 0.10;
  static const _subDialDistanceFactor = 0.5;
  static const _minutesDialClockAngleDegrees = 35.0;
  static const _runningDialClockAngleDegrees = 85.0;
  static const _outerNotchCount = 48;
  static const _caseColor = Color(0xFF2B2B2E);

  final TimerState timerState;
  final Color accentColor;
  final Color faceColor;
  final Color tickColor;
  final bool isGlowing;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2 - _margin;
    final center = size.center(Offset.zero);

    if (isGlowing) _paintGlow(canvas, center, radius);
    _paintCaseBody(canvas, center, radius);
    _paintShadow(canvas, center, radius);
    _paintFaceBackground(canvas, center, radius);
    _paintOuterNotches(canvas, center, radius);
    _paintBezel(canvas, center, radius);

    final handColor = isGlowing ? _glowColor : accentColor;

    _paintDial(canvas, center: center, radius: radius - 18, tickCount: 60, majorEvery: 5);
    _paintHand(
      canvas,
      center: center,
      length: radius - 40,
      angle: _mainHandAngle(),
      strokeWidth: 2.5,
      color: handColor,
    );

    final subDialRadius = radius * _subDialRadiusFactor;
    final subDialDistance = radius * _subDialDistanceFactor;

    final minutesCenter =
        center + _offsetForClockAngle(_minutesDialClockAngleDegrees, subDialDistance);
    final wholeMinutes = timerState.elapsed.inMinutes % 60;
    final minutesAngle = _angleForFraction(wholeMinutes / 60);
    _paintSubDialWell(canvas, minutesCenter, subDialRadius);
    _paintDial(canvas, center: minutesCenter, radius: subDialRadius, tickCount: 12, majorEvery: 3);
    _paintHand(
      canvas,
      center: minutesCenter,
      length: subDialRadius - 5,
      angle: minutesAngle,
      strokeWidth: 1.3,
      color: handColor.withValues(alpha: 0.85),
    );

    final runningCenter =
        center + _offsetForClockAngle(_runningDialClockAngleDegrees, subDialDistance);
    final runningAngle = _angleForFraction((timerState.elapsed.inMilliseconds % 1000) / 1000);
    _paintSubDialWell(canvas, runningCenter, subDialRadius);
    _paintDial(canvas, center: runningCenter, radius: subDialRadius, tickCount: 10, majorEvery: 5);
    _paintHand(
      canvas,
      center: runningCenter,
      length: subDialRadius - 5,
      angle: runningAngle,
      strokeWidth: 1.3,
      color: handColor.withValues(alpha: 0.85),
    );

    _paintHub(canvas, center, handColor);
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

  void _paintGlow(Canvas canvas, Offset center, double radius) {
    final glowPaint = Paint()
      ..color = _glowColor.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius + 2, glowPaint);
  }

  void _paintCaseBody(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius + 6, Paint()..color = _caseColor);
  }

  void _paintShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center + const Offset(0, 5), radius, shadowPaint);
  }

  void _paintFaceBackground(Canvas canvas, Offset center, double radius) {
    final faceRadius = radius - 6;
    canvas.drawCircle(center, faceRadius, Paint()..color = faceColor);

    if (isGlowing) {
      canvas.drawCircle(center, faceRadius, Paint()..color = _glowColor.withValues(alpha: 0.22));
    }

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [faceColor.withValues(alpha: 0), Colors.black.withValues(alpha: 0.08)],
        stops: const [0.72, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: faceRadius));
    canvas.drawCircle(center, faceRadius, vignettePaint);
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
        colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.02)],
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
      ..color = accentColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius > 60 ? 2 : 1.2;
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
        ..color = tickColor.withValues(alpha: isMajorTick ? 0.7 : 0.45)
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
      oldDelegate.timerState != timerState ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.faceColor != faceColor ||
      oldDelegate.isGlowing != isGlowing;
}

class _FluidGlassFace extends StatelessWidget {
  const _FluidGlassFace({required this.timerState, required this.accentColor, required this.isGlowing});

  final TimerState timerState;
  final Color accentColor;
  final bool isGlowing;

  @override
  Widget build(BuildContext context) {
    final secondsIntoMinute = timerState.elapsed.inMilliseconds % 60000;
    final fillLevel = secondsIntoMinute / 60000;
    final color = isGlowing ? _glowColor : accentColor;

    return DecoratedBox(
      decoration: isGlowing
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _glowColor.withValues(alpha: 0.6), blurRadius: 6)],
            )
          : const BoxDecoration(),
      child: LiquidCircularProgressIndicator(
        value: fillLevel,
        valueColor: AlwaysStoppedAnimation(color),
        backgroundColor: color.withValues(alpha: 0.12),
        borderColor: color,
        borderWidth: 3,
        center: Text(
          timerState.status == TimerStatus.countingDown
              ? timerState.countdownSecondsRemaining.toString()
              : timerState.elapsed.formattedClockWithTenths,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ),
    );
  }
}
