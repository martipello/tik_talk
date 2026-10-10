extension DurationFormatting on Duration {
  String get formattedClock {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedClockWithTenths {
    final tenths = (inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$formattedClock.$tenths';
  }
}
