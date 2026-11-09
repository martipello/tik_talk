import 'package:flutter/material.dart';

import '../../../core/models/lap.dart';
import '../../../core/theme/dial_face_style.dart';
import 'widgets/lap_board.dart';

// A dedicated screen rather than inline below the dial - that worked fine
// on the phone/web's taller, scrollable layout, but on the watch it meant
// the dial and controls weren't the whole story any more, competing with
// a growing list for the same small circle. Reached from the Timer
// screen's badge-carrying Laps button instead.
class WearLapsScreen extends StatelessWidget {
  const WearLapsScreen({required this.laps, required this.accentColor, required this.dialFaceStyle, super.key});

  final List<Lap> laps;
  final Color accentColor;
  final DialFaceStyle dialFaceStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          // LapBoard already carries its own 24px horizontal margin (sized
          // for the phone's much wider screen) - stacking this screen's
          // own horizontal padding on top of that left too little width
          // for its "LAP / SPLIT / TOTAL" header, which wrapped into an
          // overlapping mess. Vertical padding still clears the round
          // bezel the same way every other wear screen's does; horizontal
          // is left to LapBoard's own margin instead of doubling up.
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 44),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 12),
            LapBoard(laps: laps, accentColor: accentColor, dialFaceStyle: dialFaceStyle),
          ],
        ),
      ),
    );
  }
}
