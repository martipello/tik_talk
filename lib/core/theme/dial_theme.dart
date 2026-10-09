import 'package:flutter/material.dart';

enum DialTheme {
  classicStopwatch,
  oceanBowl;

  Color get accentColor => switch (this) {
        DialTheme.classicStopwatch => const Color(0xFFE2B33C),
        DialTheme.oceanBowl => const Color(0xFF3CC8E2),
      };

  String get displayName => switch (this) {
        DialTheme.classicStopwatch => 'Classic Stopwatch',
        DialTheme.oceanBowl => 'Ocean Bowl',
      };
}
