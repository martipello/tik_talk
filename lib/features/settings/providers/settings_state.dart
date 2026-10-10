import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/dial_theme.dart';
import 'voice_announce_interval.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required ThemeMode themeMode,
    required DialTheme dialTheme,
    required VoiceAnnounceInterval voiceAnnounceInterval,
    required int countdownSeconds,
  }) = _SettingsState;

  factory SettingsState.initial() => const SettingsState(
        themeMode: ThemeMode.system,
        dialTheme: DialTheme.classicStopwatch,
        voiceAnnounceInterval: VoiceAnnounceInterval.everyMinute,
        countdownSeconds: 0,
      );
}
