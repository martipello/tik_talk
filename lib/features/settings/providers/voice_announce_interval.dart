enum VoiceAnnounceInterval {
  off,
  everySecond,
  everyMinute,
  everyTenMinutes;

  String get label => switch (this) {
        VoiceAnnounceInterval.off => 'Off',
        VoiceAnnounceInterval.everySecond => 'Every second',
        VoiceAnnounceInterval.everyMinute => 'Every minute',
        VoiceAnnounceInterval.everyTenMinutes => 'Every 10 minutes',
      };

  Duration? get duration => switch (this) {
        VoiceAnnounceInterval.off => null,
        VoiceAnnounceInterval.everySecond => const Duration(seconds: 1),
        VoiceAnnounceInterval.everyMinute => const Duration(minutes: 1),
        VoiceAnnounceInterval.everyTenMinutes => const Duration(minutes: 10),
      };
}
