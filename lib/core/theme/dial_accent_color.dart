import 'package:flutter/material.dart';

enum DialAccentColor {
  red,
  blue,
  green,
  orange,
  black,
  white;

  Color get value => switch (this) {
        DialAccentColor.red => Colors.red,
        DialAccentColor.blue => Colors.blue,
        DialAccentColor.green => Colors.lightGreen,
        DialAccentColor.orange => Colors.orange,
        DialAccentColor.black => Colors.black,
        DialAccentColor.white => Colors.white,
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
