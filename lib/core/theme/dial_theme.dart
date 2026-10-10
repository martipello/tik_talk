import 'package:flutter/material.dart';

enum DialTheme {
  classicStopwatch,
  liquidGlass;

  Color get accentColor => switch (this) {
        DialTheme.classicStopwatch => const Color(0xFFE2B33C),
        DialTheme.liquidGlass => const Color(0xFF3CC8E2),
      };

  String get displayName => switch (this) {
        DialTheme.classicStopwatch => 'Classic Stopwatch',
        DialTheme.liquidGlass => 'Liquid Glass',
      };
}
