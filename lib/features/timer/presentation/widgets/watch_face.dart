import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:segment_display/segment_display.dart';

import '../../../../core/config/build_flavor.dart';
import '../../../../core/extensions/duration_extension.dart';
import '../../../../core/theme/dial_face_style.dart';
import '../../providers/timer_state.dart';
import '../../providers/timer_status.dart';
import 'fluid_glass2_face.dart';
import 'tik_talk_face.dart';

// Backlight glow is a brightened tint of the dial's own accent color, so it
// always harmonizes with whatever theme is picked, rather than a fixed hue
// that can clash with the chosen accent (e.g. a fixed green against a blue
// theme).
Color _glowColorFor(Color accentColor) =>
    HSLColor.fromColor(accentColor).withSaturation(1).withLightness(0.62).toColor();

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
    // AspectRatio (not a self-measuring LayoutBuilder) so sizing stays
    // correct when the parent only bounds width and leaves height unbounded
    // (e.g. inside a scrollable column) - this is exactly the case
    // AspectRatio is designed to resolve.
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRect(
        child: switch (dialFaceStyle) {
          DialFaceStyle.tikTalk => TikTalkFace(
              timerState: timerState,
              accentColor: accentColor,
              isGlowing: isGlowing,
            ),
          DialFaceStyle.classicStopwatch => _ClassicStopwatchFace(
              timerState: timerState,
              accentColor: accentColor,
              isGlowing: isGlowing,
            ),
          DialFaceStyle.fluidGlass2 => FluidGlass2Face(
              timerState: timerState,
              accentColor: accentColor,
              isGlowing: isGlowing,
            ),
        },
      ),
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

  static const _digitalReadoutOffsetFraction = 0.36;

  // The readout widths below used to be flat pixel values (168/150) - fine
  // at whatever canvas size they were tuned against (a typical phone-sized
  // face), but wrong anywhere smaller: this face's own circle fills nearly
  // the whole canvas (radius = shortestSide/2 - a small fixed margin, unlike
  // TikTalkFace's deliberately small sub-fraction of its canvas), so on a
  // much smaller canvas - the watch's own dial, barely 150-200px - a flat
  // 168px readout is wider than the entire face, overflowing past the case
  // into whatever sits next to it. Expressing both as a fraction of the
  // actual face diameter (mirroring TikTalkFace's own fix for the same
  // class of bug) keeps the readout's size relative to the case constant
  // across every screen instead of only the one it was tuned against.
  static const _clockWidthFraction = 0.5;
  static const _clockHeightFraction = 0.2;
  static const _countdownWidthFraction = 0.45;
  // _CountdownDigit wraps its content in AnimatedSwitcher (for the scale/
  // fade between consecutive numbers) - unlike TikTalkFace's countdown
  // digit, which swaps widgets directly with no such wrapper. That extra
  // layer leaves FittedBox's incoming height constraint merely loose
  // rather than tight, so on a small enough canvas (the watch's) it can
  // size itself to the SevenSegmentDisplay's own large natural/unscaled
  // size instead of actually shrinking to fit - BoxFit.scaleDown only
  // shrinks relative to a box it's actually been given, and a loose
  // constraint lets FittedBox claim however much height is available
  // rather than a value tied to our intended width. An explicit height
  // (not just width) forces that box to be tight on both axes, so the fit
  // calculation is well-defined regardless of what AnimatedSwitcher does
  // above it.
  static const _countdownHeightFraction = 0.55;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCountingDown = timerState.status == TimerStatus.countingDown;
    final faceColor = isDark ? const Color(0xFF3A3A3D) : const Color(0xFFF7F4EC);
    final tickColor = isDark ? Colors.white : Colors.black;
    final readoutColor = isGlowing ? _glowColorFor(accentColor) : accentColor;

    // Wear-only: no main hand, and the running readout centred right where
    // that hand's pivot would have been - the watch's much smaller face
    // doesn't have room to keep a swept hand and a legible digital readout
    // comfortably apart the way the phone/web's bigger canvas does, so
    // rather than fight over the same space, the hand is dropped entirely
    // and the readout takes the dial's centre instead.
    final isWear = AppConfig.isWear;

    return LayoutBuilder(
      builder: (context, constraints) {
        final faceDiameter = constraints.biggest.shortestSide - _classicFaceMargin * 2;

        return CustomPaint(
          painter: _StopwatchFacePainter(
            timerState: timerState,
            accentColor: accentColor,
            faceColor: faceColor,
            tickColor: tickColor,
            isGlowing: isGlowing,
            isWear: isWear,
          ),
          child: isCountingDown
              ? Center(
                  child: _CountdownDigit(
                    value: timerState.countdownSecondsRemaining,
                    accentColor: readoutColor,
                    width: faceDiameter * _countdownWidthFraction,
                    height: faceDiameter * _countdownHeightFraction,
                  ),
                )
              : Align(
                  alignment: Alignment(0, isWear ? 0 : _digitalReadoutOffsetFraction),
                  child: _DigitalReadout(
                    value: timerState.elapsed.formattedClockWithTenths,
                    accentColor: readoutColor,
                    isDark: isDark,
                    width: faceDiameter * _clockWidthFraction,
                    height: faceDiameter * _clockHeightFraction,
                  ),
                ),
        );
      },
    );
  }
}

class _DigitalReadout extends StatelessWidget {
  const _DigitalReadout({
    required this.value,
    required this.accentColor,
    required this.isDark,
    required this.width,
    required this.height,
  });

  final String value;
  final Color accentColor;
  final bool isDark;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final panelColor = isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.08);

    return DecoratedBox(
      decoration: BoxDecoration(color: panelColor, borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SizedBox(
          width: width,
          height: height,
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
  const _CountdownDigit({
    required this.value,
    required this.accentColor,
    required this.width,
    required this.height,
  });

  final int value;
  final Color accentColor;
  final double width;
  final double height;

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
      child: SizedBox(
        key: ValueKey(value),
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SevenSegmentDisplay(
            value: '$value',
            size: 9,
            characterSpacing: 4,
            backgroundColor: Colors.transparent,
            segmentStyle: DefaultSegmentStyle(
              enabledColor: accentColor,
              disabledColor: accentColor.withValues(alpha: 0.14),
            ),
          ),
        ),
      ),
    );
  }
}

// Needs to be wide enough for the drop shadow's blur (sigma 4, so it fades
// over ~3x that) to trail off naturally before hitting the ClipRect edge in
// WatchFace - too tight and the blur gets cut off with a visible hard edge
// instead of fading out. Hoisted out of _StopwatchFacePainter (file-level,
// not just that class's own constant) so _ClassicStopwatchFace can size its
// digital readout against the same face diameter the painter itself draws,
// rather than guessing at a separate margin.
const _classicFaceMargin = 13.0;

class _StopwatchFacePainter extends CustomPainter {
  _StopwatchFacePainter({
    required this.timerState,
    required this.accentColor,
    required this.faceColor,
    required this.tickColor,
    required this.isGlowing,
    this.isWear = false,
  });

  static const _subDialRadiusFactor = 0.10;
  static const _subDialDistanceFactor = 0.5;
  static const _minutesDialClockAngleDegrees = 30.0;
  static const _runningDialClockAngleDegrees = 75.0;
  // Wear-only: both sub-dials sit together near the top (symmetric either
  // side of 12 o'clock) instead of the phone/web's 30°/75° pair - the
  // centred digital readout that replaces the main hand on Wear (see
  // _ClassicStopwatchFace.build) is a wide box reaching past where the
  // 75°-positioned running dial normally sits, overlapping it. ±25° keeps
  // the two sub-dials clear of each other (their horizontal separation at
  // this angle and _subDialDistanceFactor comfortably exceeds twice their
  // own radius) and well clear of the centred readout below them.
  static const _wearMinutesDialClockAngleDegrees = -25.0;
  static const _wearRunningDialClockAngleDegrees = 25.0;
  static const _outerNotchCount = 48;
  static const _caseColor = Color(0xFF2B2B2E);

  final TimerState timerState;
  final Color accentColor;
  final Color faceColor;
  final Color tickColor;
  final bool isGlowing;
  // Wear OS drops the main hand and its pivot hub entirely, and moves both
  // sub-dials up to the top - see _ClassicStopwatchFace.build.
  final bool isWear;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2 - _classicFaceMargin;
    final center = size.center(Offset.zero);

    if (isGlowing) _paintGlow(canvas, center, radius);
    _paintCaseBody(canvas, center, radius);
    _paintShadow(canvas, center, radius);
    _paintFaceBackground(canvas, center, radius);
    _paintOuterNotches(canvas, center, radius);
    _paintBezel(canvas, center, radius);

    final handColor = isGlowing ? _glowColorFor(accentColor) : accentColor;

    _paintDial(canvas, center: center, radius: radius - 18, tickCount: 60, majorEvery: 5);
    if (!isWear) {
      _paintHand(
        canvas,
        center: center,
        length: radius - 40,
        angle: _mainHandAngle(),
        strokeWidth: 2.5,
        color: handColor,
      );
    }

    final subDialRadius = radius * _subDialRadiusFactor;
    final subDialDistance = radius * _subDialDistanceFactor;

    final minutesCenter = center +
        _offsetForClockAngle(
          isWear ? _wearMinutesDialClockAngleDegrees : _minutesDialClockAngleDegrees,
          subDialDistance,
        );
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

    final runningCenter = center +
        _offsetForClockAngle(
          isWear ? _wearRunningDialClockAngleDegrees : _runningDialClockAngleDegrees,
          subDialDistance,
        );
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

    // The hub is the main hand's own pivot cap - with no hand to pin down
    // on Wear, it's just a stray dot sitting on top of the centred readout
    // now in its place, not a part of the face that stands on its own.
    if (!isWear) _paintHub(canvas, center, handColor);
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
      ..color = _glowColorFor(accentColor).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius + 2, glowPaint);
  }

  void _paintCaseBody(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius + 6, Paint()..color = _caseColor);
  }

  void _paintShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 4), radius, shadowPaint);
  }

  void _paintFaceBackground(Canvas canvas, Offset center, double radius) {
    final faceRadius = radius - 6;
    canvas.drawCircle(center, faceRadius, Paint()..color = faceColor);

    if (isGlowing) {
      canvas.drawCircle(
        center,
        faceRadius,
        Paint()..color = _glowColorFor(accentColor).withValues(alpha: 0.32),
      );
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
      oldDelegate.isGlowing != isGlowing ||
      oldDelegate.isWear != isWear;
}
