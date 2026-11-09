import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/shared_preferences_provider.dart';
import '../../../core/theme/dial_accent_color.dart';
import '../../../core/theme/dial_face_style.dart';
import 'settings_repository.dart';
import 'settings_state.dart';
import 'voice_announce_interval.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  SettingsRepository get _repository => SettingsRepository(ref.read(sharedPreferencesProvider));

  @override
  SettingsState build() => _repository.load();

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _repository.save(state);
  }

  Future<void> updateDialFaceStyle(DialFaceStyle dialFaceStyle) async {
    state = state.copyWith(dialFaceStyle: dialFaceStyle);
    await _repository.save(state);
  }

  Future<void> updateDialAccentColor(DialAccentColor dialAccentColor) async {
    state = state.copyWith(dialAccentColor: dialAccentColor);
    await _repository.save(state);
  }

  Future<void> updateVoiceAnnounceInterval(VoiceAnnounceInterval interval) async {
    state = state.copyWith(voiceAnnounceInterval: interval);
    await _repository.save(state);
  }

  Future<void> updateCountdownSeconds(int seconds) async {
    state = state.copyWith(countdownSeconds: seconds);
    await _repository.save(state);
  }

  Future<void> updateTtsMuted(bool muted) async {
    state = state.copyWith(ttsMuted: muted);
    await _repository.save(state);
  }
}
