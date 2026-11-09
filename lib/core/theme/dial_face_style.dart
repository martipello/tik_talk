enum DialFaceStyle {
  tikTalk,
  classicStopwatch,
  fluidGlass2;

  String get displayName => switch (this) {
        DialFaceStyle.tikTalk => 'Tik Talk',
        DialFaceStyle.classicStopwatch => 'Classic Stopwatch',
        // Just "Fluid Glass" - the original (non-2) face was removed, so
        // there's nothing left for the "2" to disambiguate from.
        DialFaceStyle.fluidGlass2 => 'Fluid Glass',
      };

  // Fluid Glass 2 paints OCLiquidGlass orbs, which need an ancestor
  // OCLiquidGlassGroup to refract into - see _TimerStage in timer_page.dart.
  bool get usesGlassBackdrop => this == fluidGlass2;
}
