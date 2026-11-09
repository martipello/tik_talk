import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:segment_display/segment_display.dart';

import '../../../../core/extensions/duration_extension.dart';
import '../../../../core/theme/dial_accent_color.dart' show tikTokCyan, tikTokRed;
import '../../providers/timer_state.dart';
import '../../providers/timer_status.dart';

// Mirrors _glowColorFor in watch_face.dart - duplicated rather than shared
// for the same reason fluid_glass2_face.dart duplicates it: everything else
// this face owns is private to this file.
Color _glowColorFor(Color accentColor) =>
    HSLColor.fromColor(accentColor).withSaturation(1).withLightness(0.62).toColor();

// Pulls a colour's hue out at a given, deliberately low lightness/
// saturation - used for zone fills that need to relate to a hue (the ghost
// or accent colour) without reading anywhere near as bright as that colour
// itself, which is reserved for thin edge accents.
Color _muted(Color color, {required double lightness, required double saturation}) =>
    HSLColor.fromColor(color).withSaturation(saturation).withLightness(lightness).toColor();

// Rounds every corner of an arbitrary polygon by the same radius: for each
// vertex, pull back along both adjacent edges and join with a quadratic
// curve through the original corner. General-purpose (not tied to rects),
// since the crown and buttons are now built as rounded trapezoids rather
// than rounded rects.
Path _roundedPolygon(List<Offset> points, double radius) {
  final path = Path();
  final n = points.length;
  for (var i = 0; i < n; i++) {
    final prev = points[(i - 1) % n];
    final curr = points[i];
    final next = points[(i + 1) % n];
    final toPrev = prev - curr;
    final toNext = next - curr;
    final r = math.min(radius, math.min(toPrev.distance, toNext.distance) / 2);
    final start = curr + toPrev * (r / toPrev.distance);
    final end = curr + toNext * (r / toNext.distance);
    if (i == 0) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }
    path.quadraticBezierTo(curr.dx, curr.dy, end.dx, end.dy);
  }
  path.close();
  return path;
}

// One width stop along a _Pipe's base->tip axis: how far along (0=base,
// 1=tip) and how wide the shape is there. The segment between any two
// consecutive stops is one independently paintable zone - the crown's
// stem/funnel/main/un-funnel are four stops' worth of zones, not special
// cases.
class _PipeStop {
  const _PipeStop(this.t, this.width);
  final double t;
  final double width;
}

// The one shape behind the crown and both side buttons: a profile built
// from a list of (position, width) stops along the base->tip axis, each
// consecutive pair joined by straight edges. Built once and reused by
// position/size/rotation (the axis direction itself carries the rotation,
// no separate angle parameter needed) rather than three different
// hand-built shapes, since they're meant to read as the same kind of piece -
// and because each stop-to-stop segment is independently colourable, this
// is also how the crown gets its four zones (see _paintCrownZones).
class _Pipe {
  const _Pipe({required this.base, required this.tip, required this.stops, this.cornerRadius = 0});

  final Offset base;
  final Offset tip;
  // Must start with t=0 and end with t=1, ascending.
  final List<_PipeStop> stops;
  final double cornerRadius;

  Offset along(double t) => Offset.lerp(base, tip, t)!;

  Offset get _perp {
    final axis = tip - base;
    final unit = axis / axis.distance;
    return Offset(-unit.dy, unit.dx);
  }

  Path toPath() {
    final perp = _perp;
    final left = <Offset>[];
    final right = <Offset>[];
    for (final stop in stops) {
      final c = along(stop.t);
      left.add(c - perp * (stop.width / 2));
      right.add(c + perp * (stop.width / 2));
    }
    return _roundedPolygon([...left, ...right.reversed], cornerRadius);
  }

  // The quad between stops[index] and stops[index + 1] - one zone's own
  // fillable region. Callers that want it to share the overall shape's
  // corner rounding (rather than sharp corners at the true base/tip ends)
  // should intersect this with toPath().
  Path zonePath(int index) {
    final a = stops[index];
    final b = stops[index + 1];
    final perp = _perp;
    final ca = along(a.t);
    final cb = along(b.t);
    return Path()
      ..addPolygon([
        ca - perp * (a.width / 2),
        cb - perp * (b.width / 2),
        cb + perp * (b.width / 2),
        ca + perp * (a.width / 2),
      ], true);
  }
}

/// "Tik Talk" - the app's primary default face. A stopwatch silhouette
/// rendered with a chromatic-aberration "glitch" outline (two hue-shifted
/// ghost copies offset behind the real body, the sticker-art look TikTok's
/// own logo uses) and a speech-bubble tail standing in for the usual flat
/// case edge, since this app is about timing talks. Deliberately no
/// sweeping hands - a static tick ring plus a glowing digital readout, so
/// the glitch silhouette (the one thing distinguishing this face) stays the
/// focal point instead of competing with moving hands for attention.
class TikTalkFace extends StatelessWidget {
  const TikTalkFace({
    required this.timerState,
    required this.accentColor,
    required this.isGlowing,
    super.key,
  });

  final TimerState timerState;
  final Color accentColor;
  final bool isGlowing;

  // The readout's SizedBox width (which FittedBox then scales digits down
  // to fit) used to be a flat pixel value - fine at whatever canvas size it
  // was tuned against, but wrong everywhere else: the face circle itself is
  // only _TikTalkFacePainter._radiusFraction (0.32) of the canvas's
  // shortest side, so a flat width eats a much bigger share of a small
  // (mobile) face than a large (tablet/web) one, reading as oversized text
  // on phones. Expressing it as a fraction of the actual face diameter -
  // same radius fraction the painter itself uses - keeps the readout's size
  // relative to the case constant across every screen.
  static const _faceRadiusFraction = 0.32;
  static const _clockWidthFraction = 0.705;
  static const _countdownWidthFraction = 0.58;

  @override
  Widget build(BuildContext context) {
    final isCountingDown = timerState.status == TimerStatus.countingDown;
    final ghosts = _GhostColors.fromAccent(accentColor);
    final readoutColor = isGlowing ? _glowColorFor(accentColor) : ghosts.a;

    return LayoutBuilder(
      builder: (context, constraints) {
        final faceDiameter = constraints.biggest.shortestSide * _faceRadiusFraction * 2;

        return CustomPaint(
          painter:
              _TikTalkFacePainter(ghosts: ghosts, isGlowing: isGlowing, accentColor: accentColor),
          child: Align(
            // Nudged up from dead-centre: the speech-bubble tail weights the
            // silhouette toward the bottom-right, so a literally-centred
            // readout reads as slightly low against the case.
            alignment: const Alignment(0, -0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: isCountingDown
                  ? _GlowingDigits(
                      value: timerState.countdownSecondsRemaining.toString(),
                      color: readoutColor,
                      size: 9.5,
                      characterSpacing: 4,
                      width: faceDiameter * _countdownWidthFraction,
                    )
                  : _GlowingDigits(
                      value: timerState.elapsed.formattedClockWithTenths,
                      color: readoutColor,
                      size: 5.6,
                      characterSpacing: 3,
                      width: faceDiameter * _clockWidthFraction,
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Two hue-shifted ghosts of the accent colour (+/- 35 degrees), so every
// accent choice - not just a fixed brand pair - gets its own glitch that
// still visibly relates to it. Grayscale accents (black/white, where hue is
// meaningless at zero saturation) fall back to a lightness split instead,
// since a hue shift alone would be invisible on them.
class _GhostColors {
  const _GhostColors(this.a, this.b);

  factory _GhostColors.fromAccent(Color accent) {
    // The one exception to "derive the pair from the accent": picking the
    // TikTok accent specifically means the user wants the actual brand
    // colours, not a hue-shifted approximation - and a +/-35 degree shift
    // off TikTok's own cyan couldn't reach its red anyway (that's roughly
    // 145 degrees away on the wheel), so this has to be a fixed pair, not
    // a formula.
    if (accent == tikTokCyan) {
      return const _GhostColors(tikTokCyan, tikTokRed);
    }
    final hsl = HSLColor.fromColor(accent);
    if (hsl.saturation < 0.05) {
      return _GhostColors(
        hsl.withLightness((hsl.lightness + 0.45).clamp(0.0, 1.0)).toColor(),
        hsl.withLightness((hsl.lightness - 0.45).clamp(0.0, 1.0)).toColor(),
      );
    }
    final hueA = (hsl.hue + 35) % 360;
    final hueB = (hsl.hue - 35 + 360) % 360;
    return _GhostColors(
      hsl.withHue(hueA).withSaturation(1).withLightness(0.55).toColor(),
      hsl.withHue(hueB).withSaturation(1).withLightness(0.55).toColor(),
    );
  }

  final Color a;
  final Color b;
}

// A blurred duplicate behind the crisp digits - the same "glow via a second
// blurred layer" trick used for the liquid orbs' center text, here giving
// the LCD readout the neon look from the reference art.
class _GlowingDigits extends StatelessWidget {
  const _GlowingDigits({
    required this.value,
    required this.color,
    required this.size,
    required this.characterSpacing,
    required this.width,
  });

  final String value;
  final Color color;
  final double size;
  final double characterSpacing;
  final double width;

  @override
  Widget build(BuildContext context) {
    Widget digits({required bool blurred}) => SevenSegmentDisplay(
          value: value,
          size: size,
          characterSpacing: characterSpacing,
          backgroundColor: Colors.transparent,
          segmentStyle: DefaultSegmentStyle(
            enabledColor: blurred ? color.withValues(alpha: 0.9) : color,
            disabledColor: blurred ? Colors.transparent : color.withValues(alpha: 0.14),
          ),
        );

    return SizedBox(
      width: width,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: digits(blurred: true),
            ),
            digits(blurred: false),
          ],
        ),
      ),
    );
  }
}

class _TikTalkFacePainter extends CustomPainter {
  _TikTalkFacePainter({required this.ghosts, required this.isGlowing, required this.accentColor});

  final _GhostColors ghosts;
  final bool isGlowing;
  final Color accentColor;

  static const _tickCount = 60;
  static const _majorEvery = 5;
  static const _caseColor = Color(0xFF15171A);
  static const _faceColor = Color(0xFF0A0C10);
  // Fraction of the circle's own radius given over to the bezel ring
  // between the outer case edge and the inner face the ticks/digits sit
  // on - without this the case was one flat disc, where the reference has
  // a clearly separate rim and face.
  static const _bezelFraction = 0.13;

  // Unlike _StopwatchFacePainter, this face has pieces that reach well past
  // the circle itself - the crown's knob peaks at ~1.36x the circle radius
  // above centre, and the speech-bubble tail's tip reaches ~1.45x. A flat
  // pixel margin (fine when the tallest thing is a small hub) left both
  // getting silently clipped by WatchFace's ClipRect, since the circle
  // alone fit but the protruding pieces didn't - this scales the radius
  // down as a fraction of the available size instead, leaving enough room
  // for the tail (the furthest-reaching piece) with a small safety buffer.
  static const _radiusFraction = 0.32;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide * _radiusFraction;
    final center = size.center(Offset.zero);
    final crown = _crownPipe(center, radius);
    final buttons = [_buttonPipe(center, radius, -1), _buttonPipe(center, radius, 1)];
    final body = _bodyPath(center, radius, crown, buttons);

    if (isGlowing) {
      final glowColor = _glowColorFor(accentColor);
      // Two-layer bloom - a wide soft halo plus a tighter brighter one right
      // at the silhouette edge - reads as a noticeably lit backlight rather
      // than the single soft pass, which was too easily lost against the
      // dark background.
      canvas.drawPath(
        body,
        Paint()
          ..color = glowColor.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      canvas.drawPath(
        body,
        Paint()
          ..color = glowColor.withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // The glitch: the same silhouette traced twice more, offset diagonally
    // in the two ghost colours, behind the real (dark) body - only their
    // edges peek out, which is what reads as chromatic aberration rather
    // than three solid overlapping shapes. Proportional to radius (not a
    // flat pixel value), but small - the crown and buttons are themselves
    // only ~0.15x radius wide, so the 0.07x offset from the first pass was
    // roughly HALF a button's own width, overwhelming it rather than
    // peeking at its edge the way it reads on the big circle.
    final glitchOffset = radius * 0.03;
    canvas.drawPath(
      body.shift(Offset(-glitchOffset, -glitchOffset)),
      Paint()..color = ghosts.a,
    );
    canvas.drawPath(
      body.shift(Offset(glitchOffset, glitchOffset)),
      Paint()..color = ghosts.b,
    );
    // Buttons painted before the case's own opaque fill below (not after,
    // and not moved - geometry is unchanged) - that fill is a full circle
    // at the case's own radius, which covers all of each button except the
    // tip that pokes out past it, so they read as tucked in behind the
    // case/face rather than sitting in front of it. Crown is NOT included
    // here; it's still meant to sit in front, joined at the outer edge.
    for (final button in buttons) {
      _paintButtonShading(canvas, button);
    }

    // The crown gets its own zone-coloured fill below rather than the flat
    // _caseColor everything else uses, so only the circle and tail are
    // part of the single-colour `body` fill here.
    final bodyWithoutPipes = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    bodyWithoutPipes.addPath(_tailPath(center, radius), Offset.zero);
    canvas.drawPath(bodyWithoutPipes, Paint()..color = _caseColor);

    // Inner face: a second, smaller circle in a darker tone sitting inside
    // the case, so there's a visible bezel ring between the case edge and
    // the face the ticks/digits sit on, rather than one flat disc. Gets the
    // same offset-silhouette glitch treatment as the outer case edge - two
    // ghost-coloured copies shifted behind the real circle - just at a
    // smaller offset: the reference has a second, subtler crescent right at
    // this inner boundary too, not only around the case's outer edge.
    // Drawn before the crown's own zone fill (not after) - its base sits
    // close to the case's own outer edge, and painting the face on top of
    // it regardless would risk wiping out its base colouring right where
    // it meets the case. Buttons are already behind both this and the case
    // fill above (painted first), so there's nothing further to order here
    // for them.
    final faceRadius = radius * (1 - _bezelFraction);
    final faceGlitchOffset = radius * 0.024;
    // Opposite assignment from the outer case edge (ghosts.b to the
    // upper-left, ghosts.a to the lower-right, not the other way round) -
    // the reference has this inner edge's colours flipped relative to the
    // outer one, not matching it.
    canvas.drawCircle(
      center + Offset(-faceGlitchOffset, -faceGlitchOffset),
      faceRadius,
      Paint()..color = ghosts.b,
    );
    canvas.drawCircle(
      center + Offset(faceGlitchOffset, faceGlitchOffset),
      faceRadius,
      Paint()..color = ghosts.a,
    );
    canvas.drawCircle(center, faceRadius, Paint()..color = _faceColor);

    if (isGlowing) {
      canvas.drawCircle(
        center,
        faceRadius,
        Paint()..color = _glowColorFor(accentColor).withValues(alpha: 0.22),
      );
    }

    _paintPipeZones(canvas, crown, ribCount: 14);

    // Tied to faceRadius (not a flat pixel inset off the case radius, which
    // could land past the face boundary depending on size) with a bigger
    // margin than before - ticks were sitting close enough to the inner
    // glitch edge above to crowd it, especially now that edge is wider.
    _paintTicks(canvas, center, faceRadius - radius * 0.05, ghosts.a);
  }

  // Zone indices shared by the crown and both buttons (all three are now
  // built with the same four stops - see _paintPipeZones), named so magic
  // numbers don't show up at the call sites.
  static const _zoneStem = 0;
  static const _zoneFunnel = 1;
  static const _zoneMain = 2;
  static const _zoneUnfunnel = 3;

  // Crown: four zones built from one shared pipe shape (see _Pipe) rather
  // than its own one-off pieces, per "they all share the same shape" -
  // stem (narrow), funnel (a short widening - the fork of the Y pulled as
  // low/short as possible), main (the bulk of the T's top bar - taller
  // than before, and wider, so there's real room for the knurled ribbing),
  // and un-funnel (a short narrowing right at the very top cap, mirroring
  // the funnel). Base sits right at the case's own outer edge (0.97x
  // radius) - the reference joins at the very outside, where the bright
  // glitch-outline border actually is, not partway into the plain dark
  // bezel fill between that border and the inner face.
  _Pipe _crownPipe(Offset center, double radius) {
    final base = center - Offset(0, radius * 0.97);
    final tip = center - Offset(0, radius * 1.32);
    const stemWidth = 0.14;
    const mainWidth = 0.36;
    const capWidth = 0.27;
    return _Pipe(
      base: base,
      tip: tip,
      cornerRadius: radius * 0.025,
      stops: [
        _PipeStop(0.0, radius * stemWidth),
        _PipeStop(0.42, radius * stemWidth), // end of stem
        _PipeStop(0.47, radius * mainWidth), // end of funnel (short - "the V is very low")
        _PipeStop(0.88, radius * mainWidth), // end of main
        _PipeStop(1.0, radius * capWidth), // end of un-funnel, at the tip
      ],
    );
  }

  // Side buttons: the same pipe shape, angled outward from the case along
  // its own radial direction (the axis direction does the rotating - no
  // separate angle/matrix needed), and now the same four zones as the
  // crown (stem/funnel/main/un-funnel), not just a plain gradient overlay -
  // they're meant to read as the same kind of piece, colouring included.
  // Base at 0.97x radius, same as the crown's - geometry unchanged; "behind
  // the face" is purely a paint-order thing (see paint()), not a position
  // change.
  _Pipe _buttonPipe(Offset center, double radius, double side) {
    final angle = side * 0.62;
    final direction = Offset(math.sin(angle), -math.cos(angle));
    final base = center + direction * (radius * 0.97);
    final tip = center + direction * (radius * 1.24);
    const stemWidth = 0.15;
    const mainWidth = 0.25;
    const capWidth = 0.19;
    return _Pipe(
      base: base,
      tip: tip,
      cornerRadius: radius * 0.02,
      stops: [
        _PipeStop(0.0, radius * stemWidth),
        _PipeStop(0.68, radius * stemWidth), // end of stem
        _PipeStop(0.73, radius * mainWidth), // end of funnel
        _PipeStop(0.92, radius * mainWidth), // end of main
        _PipeStop(1.0, radius * capWidth), // end of un-funnel, at the tip
      ],
    );
  }

  // Case silhouette: body circle, crown, two side buttons, and the
  // speech-bubble tail, all unioned into one path so the glitch offset/
  // colour treatment above applies to the whole case as a single shape
  // rather than each piece needing its own three-layer paint.
  Path _bodyPath(Offset center, double radius, _Pipe crown, List<_Pipe> buttons) {
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    path.addPath(crown.toPath(), Offset.zero);
    for (final button in buttons) {
      path.addPath(button.toPath(), Offset.zero);
    }
    path.addPath(_tailPath(center, radius), Offset.zero);
    return path;
  }

  // Four independently-coloured zones, stem to tip - each is literally one
  // stop-to-stop segment of the crown's own _Pipe (see _crownPipe), clipped
  // to the overall shape so internal zone boundaries don't get their own
  // sharp corners. The reference knob stays dark throughout - only the thin
  // glitch-offset edges (painted separately, behind this) read as vivid -
  // so these fills are desaturated and darkened well below the ghost
  // tones' own brightness, just enough hue shift to read as distinct
  // zones, not a neon wash (the first colour pass's mistake).
  void _paintPipeZones(Canvas canvas, _Pipe pipe, {required int ribCount}) {
    final stemColor = _caseColor;
    // Sampled directly from the reference: the neck/funnel area is just
    // part of the dark case shadow (#163D4E against a #15171A case - close
    // to it, with a faint hue, not a lit or saturated band), so this sits
    // much closer to stemColor/_caseColor than the earlier pass (lightness
    // 0.2) did.
    final funnelColor = _muted(ghosts.a, lightness: 0.14, saturation: 0.28);
    final mainColor = _muted(accentColor, lightness: 0.24, saturation: 0.35);
    final unfunnelColor = _muted(ghosts.a, lightness: 0.3, saturation: 0.4);

    void fillZone(int index, Color color) {
      final zone = Path.combine(PathOperation.intersect, pipe.toPath(), pipe.zonePath(index));
      canvas.drawPath(zone, Paint()..color = color);
    }

    fillZone(_zoneStem, stemColor);
    fillZone(_zoneFunnel, funnelColor);
    fillZone(_zoneMain, mainColor);
    fillZone(_zoneUnfunnel, unfunnelColor);

    // Knurled ribbing, confined to the main zone only (not the funnel or
    // cap) - many thin parallel flutes along the pipe's own axis, not
    // across it, to actually read as texture rather than a couple of bars.
    // Looking at the reference again: the ribs aren't a flat light/dark
    // alternation - each one is cyan or magenta (the two ghost hues), and
    // which one shifts gradually left-to-right across the knob, same
    // direction as the ghost-offset edges either side of it, rather than a
    // simple even/odd flip.
    canvas.save();
    final mainZone = Path.combine(
      PathOperation.intersect,
      pipe.toPath(),
      pipe.zonePath(_zoneMain),
    );
    canvas.clipPath(mainZone);
    final mainStart = pipe.stops[_zoneMain].t;
    final mainEnd = pipe.stops[_zoneMain + 1].t;
    final ribHueA = _muted(ghosts.a, lightness: 0.4, saturation: 0.55);
    final ribHueB = _muted(ghosts.b, lightness: 0.32, saturation: 0.5);
    final mainWidth = pipe.stops[_zoneMain].width;
    final stripeWidth = mainWidth / ribCount * 0.6;
    final top = pipe.along(mainStart);
    final bottom = pipe.along(mainEnd);
    final perp = pipe._perp;
    for (var i = 0; i < ribCount; i++) {
      final widthT = (i + 0.5) / ribCount;
      final offset = perp * (mainWidth * (widthT - 0.5) * 0.9);
      canvas.drawLine(
        top + offset,
        bottom + offset,
        Paint()
          ..color = Color.lerp(ribHueA, ribHueB, widthT)!
          ..strokeWidth = stripeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  // Side buttons don't use the crown's ribbing, and - looking again - they
  // don't use one uniform banded pattern stretched across the whole piece
  // either; each zone reads differently: the un-funnel cap is one flat
  // colour, the main body is a simple grey base with a single white
  // highlight strip, the stem has a similar grey/white band but inset (a
  // plain margin at both edges before the pattern starts, rather than
  // running edge to edge), and the funnel itself is NOT part of the main
  // body's bright band - sampled from the reference, that transition reads
  // as part of the dark case shadow, same as the crown's funnel.
  void _paintButtonShading(Canvas canvas, _Pipe button) {
    final grey = _muted(accentColor, lightness: 0.3, saturation: 0.25);
    final white = Color.lerp(grey, Colors.white, 0.85)!;
    final edgeColor = _muted(accentColor, lightness: 0.18, saturation: 0.25);
    final capColor = _muted(accentColor, lightness: 0.24, saturation: 0.3);
    final funnelColor = _muted(ghosts.a, lightness: 0.14, saturation: 0.28);
    final perp = button._perp;

    ui.Shader bandShader(Offset center, double width, List<Color> colors, List<double> stops) {
      final from = center - perp * (width / 2);
      final to = center + perp * (width / 2);
      return ui.Gradient.linear(from, to, colors, stops);
    }

    void fillZone(int index, Paint paint) {
      final zone = Path.combine(PathOperation.intersect, button.toPath(), button.zonePath(index));
      canvas.drawPath(zone, paint);
    }

    final stemWidth = button.stops[_zoneStem].width;
    final stemCenter = button.along((button.stops[_zoneStem].t + button.stops[_zoneFunnel].t) / 2);
    fillZone(
      _zoneStem,
      Paint()
        ..shader = bandShader(
          stemCenter,
          stemWidth,
          [edgeColor, edgeColor, grey, grey, white, white, grey, grey, edgeColor, edgeColor],
          const [0.0, 0.15, 0.15, 0.45, 0.45, 0.55, 0.55, 0.85, 0.85, 1.0],
        ),
    );

    fillZone(_zoneFunnel, Paint()..color = funnelColor);

    final mainWidth = button.stops[_zoneMain].width;
    final mainCenter = button.along((button.stops[_zoneMain].t + button.stops[_zoneMain + 1].t) / 2);
    fillZone(
      _zoneMain,
      Paint()
        ..shader = bandShader(
          mainCenter,
          mainWidth,
          [grey, grey, white, white, grey, grey],
          const [0.0, 0.55, 0.55, 0.68, 0.68, 1.0],
        ),
    );

    fillZone(_zoneUnfunnel, Paint()..color = capColor);
  }

  // A proper speech-bubble tail: two points flush with the circle's own rim
  // (close together, so the base reads as part of the case edge) and a
  // single tip extending outward - not the other way round, which is what
  // made the first pass look inverted.
  Path _tailPath(Offset center, double radius) {
    const baseAngleA = 34 * math.pi / 180;
    const baseAngleB = 58 * math.pi / 180;
    const tipAngle = 45 * math.pi / 180;
    final baseA = center + Offset(math.cos(baseAngleA), math.sin(baseAngleA)) * radius;
    final baseB = center + Offset(math.cos(baseAngleB), math.sin(baseAngleB)) * radius;
    final tip = center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * radius * 1.45;
    return Path()
      ..moveTo(baseA.dx, baseA.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(baseB.dx, baseB.dy)
      ..close();
  }

  void _paintTicks(Canvas canvas, Offset center, double radius, Color tickColor) {
    final glowPaint = Paint()
      ..color = tickColor.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final tickPaint = Paint()
      ..color = tickColor.withValues(alpha: 0.9)
      ..strokeWidth = 1.4;

    for (var i = 0; i < _tickCount; i++) {
      final angle = (i / _tickCount) * 2 * math.pi - (math.pi / 2);
      final isMajor = i % _majorEvery == 0;
      final tickLength = radius * (isMajor ? 0.1 : 0.045);
      final direction = Offset(math.cos(angle), math.sin(angle));
      final outer = center + direction * radius;
      final inner = center + direction * (radius - tickLength);
      canvas.drawLine(inner, outer, glowPaint);
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TikTalkFacePainter oldDelegate) =>
      oldDelegate.ghosts.a != ghosts.a ||
      oldDelegate.ghosts.b != ghosts.b ||
      oldDelegate.isGlowing != isGlowing ||
      oldDelegate.accentColor != accentColor;
}
