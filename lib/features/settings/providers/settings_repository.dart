import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/dial_accent_color.dart';
import '../../../core/theme/dial_face_style.dart';
import 'settings_state.dart';
import 'voice_announce_interval.dart';

class SettingsRepository {
  SettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  static const _themeModeKey = 'theme_mode';
  static const _dialFaceStyleKey = 'dial_face_style';
  static const _dialAccentColorKey = 'dial_accent_color';
  static const _voiceAnnounceIntervalKey = 'voice_announce_interval';
  static const _countdownSecondsKey = 'countdown_seconds';

  SettingsState load() {
    final initial = SettingsState.initial();
    final themeModeName = _preferences.getString(_themeModeKey);
    final dialFaceStyleName = _preferences.getString(_dialFaceStyleKey);
    final dialAccentColorName = _preferences.getString(_dialAccentColorKey);
    final voiceIntervalName = _preferences.getString(_voiceAnnounceIntervalKey);
    final countdownSeconds = _preferences.getInt(_countdownSecondsKey);

    return initial.copyWith(
      themeMode: ThemeMode.values.firstWhere(
        (value) => value.name == themeModeName,
        orElse: () => initial.themeMode,
      ),
      dialFaceStyle: DialFaceStyle.values.firstWhere(
        (value) => value.name == dialFaceStyleName,
        orElse: () => initial.dialFaceStyle,
      ),
      dialAccentColor: DialAccentColor.values.firstWhere(
        (value) => value.name == dialAccentColorName,
        orElse: () => initial.dialAccentColor,
      ),
      voiceAnnounceInterval: VoiceAnnounceInterval.values.firstWhere(
        (value) => value.name == voiceIntervalName,
        orElse: () => initial.voiceAnnounceInterval,
      ),
      countdownSeconds: countdownSeconds ?? initial.countdownSeconds,
    );
  }

  Future<void> save(SettingsState state) async {
    await _preferences.setString(_themeModeKey, state.themeMode.name);
    await _preferences.setString(_dialFaceStyleKey, state.dialFaceStyle.name);
    await _preferences.setString(_dialAccentColorKey, state.dialAccentColor.name);
    await _preferences.setString(_voiceAnnounceIntervalKey, state.voiceAnnounceInterval.name);
    await _preferences.setInt(_countdownSecondsKey, state.countdownSeconds);
  }
}
