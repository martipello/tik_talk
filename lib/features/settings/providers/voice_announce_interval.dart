enum VoiceAnnounceInterval {
  off,
  everySecond,
  everyMinute,
  everyFiveMinutes,
  everyTenMinutes;

  String get label => switch (this) {
        VoiceAnnounceInterval.off => 'Off',
        VoiceAnnounceInterval.everySecond => 'Every second',
        VoiceAnnounceInterval.everyMinute => 'Every minute',
        VoiceAnnounceInterval.everyFiveMinutes => 'Every 5 minutes',
        VoiceAnnounceInterval.everyTenMinutes => 'Every 10 minutes',
      };

  Duration? get duration => switch (this) {
        VoiceAnnounceInterval.off => null,
        VoiceAnnounceInterval.everySecond => const Duration(seconds: 1),
        VoiceAnnounceInterval.everyMinute => const Duration(minutes: 1),
        VoiceAnnounceInterval.everyFiveMinutes => const Duration(minutes: 5),
        VoiceAnnounceInterval.everyTenMinutes => const Duration(minutes: 10),
      };
}
