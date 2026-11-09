import 'package:flutter/material.dart';

// TikTok's own brand pair (cyan + red/fuchsia). Exposed as top-level
// constants, not just DialAccentColor.tiktok.value, so the Tik Talk face's
// glitch effect (lib/features/timer/presentation/widgets/tik_talk_face.dart)
// can recognise this exact selection and use the authentic pair directly -
// its usual "derive two ghost hues from whatever accent is picked" approach
// (a +/-35 degree hue shift) can't reproduce this specific pairing, since
// TikTok's red sits roughly 145 degrees around the wheel from its cyan, not
// 35.
const tikTokCyan = Color(0xFF25F4EE);
const tikTokRed = Color(0xFFFE2C55);

enum DialAccentColor {
  red,
  blue,
  green,
  orange,
  black,
  white,
  tiktok;

  Color get value => switch (this) {
        DialAccentColor.red => Colors.red,
        DialAccentColor.blue => Colors.blue,
        DialAccentColor.green => Colors.lightGreen,
        DialAccentColor.orange => Colors.orange,
        DialAccentColor.black => Colors.black,
        DialAccentColor.white => Colors.white,
        DialAccentColor.tiktok => tikTokCyan,
      };

  String get displayName => switch (this) {
        DialAccentColor.red => 'Red',
        DialAccentColor.blue => 'Blue',
        DialAccentColor.green => 'Green',
        DialAccentColor.orange => 'Orange',
        DialAccentColor.black => 'Black',
        DialAccentColor.white => 'White',
        DialAccentColor.tiktok => 'TikTok',
      };
}
