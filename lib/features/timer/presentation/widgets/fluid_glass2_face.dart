import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';

import '../../../../core/extensions/duration_extension.dart';
import '../../providers/timer_state.dart';
import '../../providers/timer_status.dart';

const String _shaderAssetKey = 'shaders/liquid_slosh.frag';

// Mirrors _glowColorFor in watch_face.dart - duplicated rather than shared
// since everything else _FluidGlassFace owns is private to that file, and
// this is the only piece this face actually needs from it.
Color _glowColorFor(Color accentColor) =>
    HSLColor.fromColor(accentColor).withSaturation(1).withLightness(0.62).toColor();

/// "Fluid Glass 2" - a ground-up rebuild of the liquid itself. Where Fluid
/// Glass fakes its surface with three sin() layers and a hand-tuned
/// turbulence curve, this face drives the surface from a small
/// damped-oscillator physics simulation (_SloshSimulation) rendered by a
/// fragment shader (shaders/liquid_slosh.frag), so momentum genuinely
/// carries over between frames - the water keeps ebbing and flowing on its
/// own, and timer events (start/lap/reset/rollover) land as real pokes that
/// ripple out and decay rather than scripted animation beats.
class FluidGlass2Face extends StatefulWidget {
  const FluidGlass2Face({
    required this.timerState,
    required this.accentColor,
    required this.isGlowing,
    super.key,
  });

  final TimerState timerState;
  final Color accentColor;
  final bool isGlowing;

  @override
  State<FluidGlass2Face> createState() => _FluidGlass2FaceState();
}

class _FluidGlass2FaceState extends State<FluidGlass2Face> with TickerProviderStateMixin {
  static const _orbMargin = 4.0;

  late final Ticker _ticker;
  Duration _lastTicked = Duration.zero;
  final _SloshRepaintSignal _repaint = _SloshRepaintSignal();

  late final _SloshSimulation _mainSim;

  late final AnimationController _bubbleController;
  late final List<_Bubble> _mainBubbles;

  TimerState? _previousState;

  @override
  void initState() {
    super.initState();
    _mainSim = _SloshSimulation(seed: 11);

    _bubbleController = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..repeat();
    _mainBubbles = _generateBubbles(seed: 7, count: 9, maxRadius: 4.5, maxDrift: 5);

    _previousState = widget.timerState;
    _ticker = createTicker(_onTick)..start();
  }

  List<_Bubble> _generateBubbles({
    required int seed,
    required int count,
    required double maxRadius,
    required double maxDrift,
  }) {
    final random = math.Random(seed);
    return List.generate(
      count,
      (index) => _Bubble(
        dxFraction: (index + 0.5) / count + (random.nextDouble() - 0.5) * 0.08,
        radius: 1 + random.nextDouble() * (maxRadius - 1),
        speed: (1 + random.nextInt(2)).toDouble(),
        phaseOffset: random.nextDouble(),
        driftAmplitude: 1 + random.nextDouble() * (maxDrift - 1),
      ),
    );
  }

  // Scales the wall-clock dt fed to every simulation, so the whole slosh -
  // oscillation, ambient drift, ripple decay, poke decay - runs uniformly
  // faster without retuning each sim's individual stiffness/damping
  // constants.
  static const _simSpeedMultiplier = 1.1;

  // Decoupled from the 100ms-cadence timerState rebuild on purpose - the
  // physics needs real wall-clock dt, and only the CustomPainters (via
  // _repaint) need to redraw every frame, not the whole orb/glass subtree.
  void _onTick(Duration elapsed) {
    var dt = elapsed - _lastTicked;
    _lastTicked = elapsed;
    if (dt <= Duration.zero) return;
    const maxDt = Duration(milliseconds: 33);
    if (dt > maxDt) dt = maxDt;

    final seconds = dt.inMicroseconds / Duration.microsecondsPerSecond * _simSpeedMultiplier;
    _mainSim.step(seconds);
    _repaint.tick();
  }

  @override
  void didUpdateWidget(FluidGlass2Face oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pokeForEvents(widget.timerState);
  }

  // Pokes land once per transition (not every frame) - same "once per cycle"
  // spirit as the old painter's swirlSeed reseed, just driving a physics
  // kick instead of a palette pick.
  void _pokeForEvents(TimerState state) {
    final previous = _previousState;
    _previousState = state;
    if (previous == null) return;

    if (previous.status != TimerStatus.running && state.status == TimerStatus.running) {
      _mainSim.poke(1.0);
    }
    if (state.laps.length > previous.laps.length) {
      _mainSim.poke(0.8);
    }
    if (previous.elapsed > Duration.zero && state.elapsed == Duration.zero) {
      _mainSim.poke(1.2);
    }
    if (state.elapsed.inMinutes != previous.elapsed.inMinutes) {
      _mainSim.poke(0.5);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bubbleController.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsedMs = widget.timerState.elapsed.inMilliseconds;
    final mainFill = (elapsedMs % 60000) / 60000;

    final glowColor = _glowColorFor(widget.accentColor);
    final baseColor = widget.isGlowing ? glowColor : widget.accentColor;
    final isCountingDown = widget.timerState.status == TimerStatus.countingDown;
    // Text sits at a fixed position (orb centre) but what's behind it
    // doesn't: as fillLevel cycles, that point is sometimes inside the
    // water body, sometimes in the air above it over the page background -
    // and those two need opposite contrast colours in e.g. dark mode with a
    // white accent (black text reads over the white water, but vanishes
    // over the dark page background before the water has risen that far).
    // No single fill colour covers both, so the text gets outlined too:
    // fillColor contrasts the water, outlineColor contrasts the page
    // background (onSurface already does that correctly by Material
    // convention), and whichever region the text is actually over, one of
    // the two reads clearly.
    final outlineColor = Theme.of(context).colorScheme.onSurface;

    return DecoratedBox(
      decoration: widget.isGlowing
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: glowColor.withValues(alpha: 0.6), blurRadius: 6)],
            )
          : const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(_orbMargin),
        child: _LiquidOrb2(
          fillLevel: mainFill,
          baseColor: baseColor,
          simulation: _mainSim,
          repaint: _repaint,
          bubbles: _mainBubbles,
          bubblePhase: _bubbleController,
          rimWidth: 3,
          centerText: isCountingDown
              ? widget.timerState.countdownSecondsRemaining.toString()
              : widget.timerState.elapsed.formattedClockWithTenths,
          centerTextSize: isCountingDown ? 56 : 34,
          // Contrasts against the water itself, not the app's ambient
          // theme text color - onSurface is picked for the page
          // background, not for whatever accent colour (e.g. white)
          // happens to be filling the orb right now, and those can land on
          // the same side (white text over the white-accent orb's bright
          // froth) with no contrast at all.
          textColor: baseColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          textOutlineColor: outlineColor,
        ),
      ),
    );
  }
}

class _SloshRepaintSignal extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _LiquidOrb2 extends StatelessWidget {
  const _LiquidOrb2({
    required this.fillLevel,
    required this.baseColor,
    required this.simulation,
    required this.repaint,
    required this.bubbles,
    required this.bubblePhase,
    required this.rimWidth,
    this.centerText,
    this.centerTextSize = 20,
    this.textColor = Colors.white,
    this.textOutlineColor = Colors.black,
  });

  final double fillLevel;
  final Color baseColor;
  final _SloshSimulation simulation;
  final Listenable repaint;
  final List<_Bubble> bubbles;
  final Animation<double> bubblePhase;
  final double rimWidth;
  final String? centerText;
  final double centerTextSize;
  final Color textColor;
  final Color textOutlineColor;

  @override
  Widget build(BuildContext context) {
    // The glass shell (refraction, specular, light band) comes from
    // oc_liquid_glass's OCLiquidGlass, same as the original Fluid Glass face
    // - only what's painted inside the ClipOval below is being rebuilt.
    return LayoutBuilder(
      builder: (context, constraints) => OCLiquidGlass(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        borderRadius: constraints.maxWidth,
        color: baseColor.withValues(alpha: 0.18),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ShaderBuilder(
                  (context, shader, child) => CustomPaint(
                    painter: _SloshShaderPainter(
                      shader: shader,
                      simulation: simulation,
                      fillLevel: fillLevel,
                      baseColor: baseColor,
                      repaint: repaint,
                    ),
                  ),
                  assetKey: _shaderAssetKey,
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _SloshDecorationPainter(
                    simulation: simulation,
                    bubblePhase: bubblePhase,
                    bubbles: bubbles,
                    fillLevel: fillLevel,
                    baseColor: baseColor,
                    rimWidth: rimWidth,
                    repaint: Listenable.merge([repaint, bubblePhase]),
                  ),
                ),
              ),
              if (centerText != null) ...[
                // Outline drawn first (stroke-only, no fill) and the solid
                // fill text on top of it, so the digits stay readable
                // whichever of the two colours actually contrasts with
                // what's behind them at this exact point - see
                // outlineColor's definition in FluidGlass2Face for why one
                // colour alone can't cover it.
                Text(
                  centerText!,
                  style: GoogleFonts.jost(
                    fontSize: centerTextSize,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = centerTextSize * 0.06
                      ..color = textOutlineColor.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  centerText!,
                  style: GoogleFonts.jost(
                    color: textColor,
                    fontSize: centerTextSize,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble {
  const _Bubble({
    required this.dxFraction,
    required this.radius,
    required this.speed,
    required this.phaseOffset,
    required this.driftAmplitude,
  });

  final double dxFraction;
  final double radius;
  final double speed;
  final double phaseOffset;
  final double driftAmplitude;
}

// Writes the current simulation state into the shader's uniforms and draws
// it over the orb's bounding box. Purely a function of _SloshSimulation's
// state - no animation clock of its own - so the surface only moves because
// the physics (ticked once per frame in _FluidGlass2FaceState) moved it.
class _SloshShaderPainter extends CustomPainter {
  _SloshShaderPainter({
    required this.shader,
    required this.simulation,
    required this.fillLevel,
    required this.baseColor,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final ui.FragmentShader shader;
  final _SloshSimulation simulation;
  final double fillLevel;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    void setFloat(double value) => shader.setFloat(i++, value);

    setFloat(size.width);
    setFloat(size.height);
    setFloat(fillLevel.clamp(0.0, 1.0));
    setFloat(simulation.mode1X);
    setFloat(simulation.mode1Y);
    setFloat(simulation.mode2X);
    setFloat(simulation.mode2Y);
    setFloat(simulation.rippleAmplitude);
    setFloat(simulation.ripplePhase);
    setFloat(baseColor.r);
    setFloat(baseColor.g);
    setFloat(baseColor.b);
    setFloat(baseColor.a);
    setFloat(simulation.time);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _SloshShaderPainter oldDelegate) => true;
}

// Bubbles + rim stay plain Dart-drawn on top of the shader output - they
// don't need to be physically coupled to the slosh surface to read
// correctly, and keeping them here de-risked authoring the shader itself.
class _SloshDecorationPainter extends CustomPainter {
  _SloshDecorationPainter({
    required this.simulation,
    required this.bubblePhase,
    required this.bubbles,
    required this.fillLevel,
    required this.baseColor,
    required this.rimWidth,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _SloshSimulation simulation;
  final Animation<double> bubblePhase;
  final List<_Bubble> bubbles;
  final double fillLevel;
  final Color baseColor;
  final double rimWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height * (1 - fillLevel.clamp(0.0, 1.0));
    if (fillLevel > 0.015) {
      _paintBubbles(canvas, size, baseY);
    }
    _paintRim(canvas, size);
  }

  // Bubbles pick up extra jitter while the surface is actively sloshing
  // (high tiltEnergy/rippleAmplitude), same idea as the old painter's
  // turbulence-linked drift, now driven by the real physics state instead
  // of a scripted edge-of-cycle curve.
  void _paintBubbles(Canvas canvas, Size size, double baseY) {
    final bottomY = size.height + 6;
    final agitation = (simulation.tiltEnergy * 6 + simulation.rippleAmplitude.abs() * 10)
        .clamp(0.0, 3.0);
    for (final bubble in bubbles) {
      final t = (bubblePhase.value * bubble.speed + bubble.phaseOffset) % 1.0;
      final y = bottomY - t * (bottomY - baseY);
      if (y < baseY) continue;
      // A straight sin(t*2pi) - one full cycle smeared evenly across the
      // whole rise - reads as a bubble floating up nearly straight with a
      // faint wobble. Two tweaks make it snake: more cycles (t*4pi) so
      // there's visible back-and-forth along the way rather than one lazy
      // S, and growing the amplitude with t^2 so the wiggle is subtle low
      // down and pronounced right at the top - a hook curling into the
      // crest, like the curve at the top of a lowercase "r", instead of
      // uniform wobble top to bottom.
      final drift = math.sin(t * 4 * math.pi + bubble.phaseOffset * 10) *
          bubble.driftAmplitude *
          (1 + agitation) *
          (0.3 + 0.7 * t * t);
      final x = bubble.dxFraction * size.width + drift;
      final fadeOut = (1 - t).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        bubble.radius,
        Paint()..color = Colors.white.withValues(alpha: 0.35 * fadeOut),
      );
    }
  }

  void _paintRim(Canvas canvas, Size size) {
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = rimWidth
      ..color = baseColor.withValues(alpha: 0.8);
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2 - rimWidth / 2,
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SloshDecorationPainter oldDelegate) => true;
}

// Real momentum physics for the liquid surface: two detuned 2D damped
// oscillators ("tilt modes") driven by a continuous, never-quite-repeating
// ambient force, plus a scalar radial-ripple mode that fires on poke() and
// decays. The shader only ever reads this state - all the "water" behavior
// lives here.
class _SloshSimulation {
  _SloshSimulation({required int seed}) : _random = math.Random(seed) {
    final jitter = _random.nextDouble();
    _stiffness1 = 2.2 + jitter * 0.6;
    _damping1 = 1.1 + jitter * 0.3;
    _stiffness2 = 3.1 + (1 - jitter) * 0.7;
    _damping2 = 1.4 + (1 - jitter) * 0.3;
    _forcingPhase1 = _random.nextDouble() * 2 * math.pi;
    _forcingPhase2 = _random.nextDouble() * 2 * math.pi;
    _forcingPhase3 = _random.nextDouble() * 2 * math.pi;
  }

  final math.Random _random;

  late final double _stiffness1;
  late final double _damping1;
  late final double _stiffness2;
  late final double _damping2;
  late final double _forcingPhase1;
  late final double _forcingPhase2;
  late final double _forcingPhase3;

  double time = 0;

  double mode1X = 0;
  double mode1Y = 0;
  double _v1X = 0;
  double _v1Y = 0;

  double mode2X = 0;
  double mode2Y = 0;
  double _v2X = 0;
  double _v2Y = 0;

  double rippleAmplitude = 0;
  double ripplePhase = 0;

  double get tiltEnergy => mode1X.abs() + mode1Y.abs() + mode2X.abs() + mode2Y.abs();

  // 3 slow sine terms at incommensurate rates - idle motion never lands on
  // an obvious repeat, and because they're incommensurate with the modes'
  // own natural frequencies, the forced response beats rather than settling
  // into a fixed-amplitude wobble.
  Offset _ambientForce() {
    final f1 = math.sin(time * 0.42 + _forcingPhase1);
    final f2 = math.sin(time * 0.71 + _forcingPhase2);
    final f3 = math.sin(time * 1.13 + _forcingPhase3);
    const strength = 0.045;
    return Offset((f1 + f2 * 0.6) * strength, (f2 - f3 * 0.7) * strength);
  }

  void step(double dt) {
    if (dt <= 0) return;
    time += dt;
    final force = _ambientForce();

    _v1X += (-_stiffness1 * mode1X - _damping1 * _v1X + force.dx) * dt;
    _v1Y += (-_stiffness1 * mode1Y - _damping1 * _v1Y + force.dy) * dt;
    mode1X += _v1X * dt;
    mode1Y += _v1Y * dt;

    _v2X += (-_stiffness2 * mode2X - _damping2 * _v2X + force.dx * 0.8) * dt;
    _v2Y += (-_stiffness2 * mode2Y - _damping2 * _v2Y + force.dy * 0.8) * dt;
    mode2X += _v2X * dt;
    mode2Y += _v2Y * dt;

    ripplePhase += dt * 9.0;
    rippleAmplitude -= rippleAmplitude * math.min(1.0, 1.4 * dt);
  }

  // A sharp velocity kick plus a fresh expanding ripple - the "water being
  // poured in" moment. Uses the simulation's own persistent Random (not
  // reseeded per call) so repeated pokes don't all kick the same direction.
  void poke(double strength) {
    final angle = _random.nextDouble() * 2 * math.pi;
    final kick = strength * 0.18;
    _v1X += math.cos(angle) * kick;
    _v1Y += math.sin(angle) * kick;
    _v2X += math.cos(angle + 1.3) * kick * 0.7;
    _v2Y += math.sin(angle + 1.3) * kick * 0.7;
    rippleAmplitude = math.max(rippleAmplitude, strength * 0.09);
    ripplePhase = 0;
  }
}
