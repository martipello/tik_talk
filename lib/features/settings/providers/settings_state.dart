import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/dial_accent_color.dart';
import '../../../core/theme/dial_face_style.dart';
import 'voice_announce_interval.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required ThemeMode themeMode,
    required DialFaceStyle dialFaceStyle,
    required DialAccentColor dialAccentColor,
    required VoiceAnnounceInterval voiceAnnounceInterval,
    required int countdownSeconds,
    required bool ttsMuted,
  }) = _SettingsState;

  factory SettingsState.initial() => const SettingsState(
        themeMode: ThemeMode.system,
        dialFaceStyle: DialFaceStyle.tikTalk,
        dialAccentColor: DialAccentColor.tiktok,
        voiceAnnounceInterval: VoiceAnnounceInterval.everyMinute,
        countdownSeconds: 0,
        ttsMuted: false,
      );
}
