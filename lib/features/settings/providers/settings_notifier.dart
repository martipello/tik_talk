import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/shared_preferences_provider.dart';
import '../../../core/theme/dial_theme.dart';
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

  Future<void> updateDialTheme(DialTheme dialTheme) async {
    state = state.copyWith(dialTheme: dialTheme);
    await _repository.save(state);
  }

  Future<void> updateVoiceAnnounceInterval(VoiceAnnounceInterval interval) async {
    state = state.copyWith(voiceAnnounceInterval: interval);
    await _repository.save(state);
  }

  Future<void> updateCountdownFromSeconds(int seconds) async {
    state = state.copyWith(countdownFromSeconds: seconds);
    await _repository.save(state);
  }
}
