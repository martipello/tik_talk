enum DialFaceStyle {
  classicStopwatch,
  fluidGlass;

  String get displayName => switch (this) {
        DialFaceStyle.classicStopwatch => 'Classic Stopwatch',
        DialFaceStyle.fluidGlass => 'Fluid Glass',
      };
}
