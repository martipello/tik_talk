import 'package:flutter/material.dart';

enum DialAccentColor {
  red,
  blue,
  green,
  orange,
  black,
  white;

  Color get value => switch (this) {
        DialAccentColor.red => const Color(0xFFD7342A),
        DialAccentColor.blue => const Color(0xFF2563EB),
        DialAccentColor.green => const Color(0xFF2E9E4F),
        DialAccentColor.orange => const Color(0xFFE2B33C),
        DialAccentColor.black => const Color(0xFF1A1A1A),
        DialAccentColor.white => const Color(0xFFF2F2F2),
      };

  String get displayName => switch (this) {
        DialAccentColor.red => 'Red',
        DialAccentColor.blue => 'Blue',
        DialAccentColor.green => 'Green',
        DialAccentColor.orange => 'Orange',
        DialAccentColor.black => 'Black',
        DialAccentColor.white => 'White',
      };
}
