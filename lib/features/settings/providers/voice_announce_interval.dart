enum VoiceAnnounceInterval {
  off,
  every5Seconds,
  every10Seconds,
  every30Seconds,
  everyMinute,
  everyFiveMinutes,
  everyTenMinutes;

  String get label => switch (this) {
        VoiceAnnounceInterval.off => 'Off',
        VoiceAnnounceInterval.every5Seconds => 'Every 5 seconds',
        VoiceAnnounceInterval.every10Seconds => 'Every 10 seconds',
        VoiceAnnounceInterval.every30Seconds => 'Every 30 seconds',
        VoiceAnnounceInterval.everyMinute => 'Every minute',
        VoiceAnnounceInterval.everyFiveMinutes => 'Every 5 minutes',
        VoiceAnnounceInterval.everyTenMinutes => 'Every 10 minutes',
      };

  Duration? get duration => switch (this) {
        VoiceAnnounceInterval.off => null,
        VoiceAnnounceInterval.every5Seconds => const Duration(seconds: 5),
        VoiceAnnounceInterval.every10Seconds => const Duration(seconds: 10),
        VoiceAnnounceInterval.every30Seconds => const Duration(seconds: 30),
        VoiceAnnounceInterval.everyMinute => const Duration(minutes: 1),
        VoiceAnnounceInterval.everyFiveMinutes => const Duration(minutes: 5),
        VoiceAnnounceInterval.everyTenMinutes => const Duration(minutes: 10),
      };

  // There used to be an "every second" option, which read out the full
  // "1 second" / "2 seconds" / ... phrase every single second - the TTS
  // engine can't finish speaking one of those before the next one is due,
  // so it permanently falls behind. The two fast intervals speak just the
  // bare elapsed-seconds count ("10") instead, short enough to actually
  // finish before the next announcement. 30 seconds is a slow enough
  // cadence that the full phrase has time to complete, and it reads better
  // than a bare number once it crosses a minute ("30 seconds, 1 minute, 1
  // minute 30 seconds, ...") - so it keeps the full phrasing.
  bool get speaksBareNumber => switch (this) {
        VoiceAnnounceInterval.every5Seconds || VoiceAnnounceInterval.every10Seconds => true,
        _ => false,
      };
}
