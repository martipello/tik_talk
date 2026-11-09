import 'package:flutter/material.dart';

// Lives behind the whole Timer page (not just the orb) so the glass orb has
// something ambient to refract via BackdropFilter - painting this gradient
// and soft light circles inside the orb itself gave it nothing to refract
// and just looked like a flat tinted circle.
class FluidGlassBackground extends StatelessWidget {
  const FluidGlassBackground({required this.accentColor, super.key});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FluidGlassBackgroundPainter(
        surfaceColor: Theme.of(context).colorScheme.surface,
        accentColor: accentColor,
      ),
      size: Size.infinite,
    );
  }
}

class _FluidGlassBackgroundPainter extends CustomPainter {
  _FluidGlassBackgroundPainter({required this.surfaceColor, required this.accentColor});

  final Color surfaceColor;
  final Color accentColor;

  static const _softCircles = [
    (alignment: Alignment(-0.75, -0.85), radiusFactor: 0.5, hueShift: 0.0, alpha: 0.22),
    (alignment: Alignment(0.85, -0.3), radiusFactor: 0.38, hueShift: -28.0, alpha: 0.18),
    (alignment: Alignment(-0.3, 0.85), radiusFactor: 0.44, hueShift: 30.0, alpha: 0.16),
    (alignment: Alignment(0.6, 0.75), radiusFactor: 0.32, hueShift: -14.0, alpha: 0.14),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Anchoring the tint's lightness to the surface's own lightness (rather
    // than the accent color's raw lightness) keeps dark mode reading as dark
    // with a subtle glow, and light mode reading as light with a subtle
    // tint - using the accent color as-is could push either mode's overall
    // brightness in the wrong direction depending on how light/dark that
    // particular accent happens to be.
    final isDark = ThemeData.estimateBrightnessForColor(surfaceColor) == Brightness.dark;
    final baseLightness = HSLColor.fromColor(surfaceColor).lightness;
    final lightnessDelta = isDark ? 0.14 : -0.08;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceColor,
            _ambientColor(0, baseLightness, lightnessDelta).withValues(alpha: 0.12),
          ],
        ).createShader(rect),
    );

    for (final circle in _softCircles) {
      final center = circle.alignment.alongSize(size);
      final radius = size.shortestSide * circle.radiusFactor;
      final paint = Paint()
        ..color = _ambientColor(
          circle.hueShift,
          baseLightness,
          lightnessDelta,
        ).withValues(alpha: circle.alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);
      canvas.drawCircle(center, radius, paint);
    }
  }

  Color _ambientColor(double hueShift, double baseLightness, double lightnessDelta) {
    final hsl = HSLColor.fromColor(accentColor);
    final hue = (hsl.hue + hueShift) % 360;
    final lightness = (baseLightness + lightnessDelta).clamp(0.0, 1.0);
    return hsl
        .withHue(hue < 0 ? hue + 360 : hue)
        .withSaturation((hsl.saturation * 0.85).clamp(0.0, 1.0))
        .withLightness(lightness)
        .toColor();
  }

  @override
  bool shouldRepaint(covariant _FluidGlassBackgroundPainter oldDelegate) =>
      oldDelegate.surfaceColor != surfaceColor || oldDelegate.accentColor != accentColor;
}
