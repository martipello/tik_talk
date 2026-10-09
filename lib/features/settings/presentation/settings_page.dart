import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dial_theme.dart';
import '../providers/settings_notifier.dart';
import '../providers/voice_announce_interval.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (isDark) =>
                notifier.updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light),
          ),
          ListTile(
            title: const Text('Watch face'),
            trailing: DropdownButton<DialTheme>(
              value: settings.dialTheme,
              items: DialTheme.values
                  .map((theme) => DropdownMenuItem(value: theme, child: Text(theme.displayName)))
                  .toList(),
              onChanged: (theme) {
                if (theme != null) notifier.updateDialTheme(theme);
              },
            ),
          ),
          ListTile(
            title: const Text('Voice announcements'),
            trailing: DropdownButton<VoiceAnnounceInterval>(
              value: settings.voiceAnnounceInterval,
              items: VoiceAnnounceInterval.values
                  .map(
                    (interval) => DropdownMenuItem(value: interval, child: Text(interval.label)),
                  )
                  .toList(),
              onChanged: (interval) {
                if (interval != null) notifier.updateVoiceAnnounceInterval(interval);
              },
            ),
          ),
          ListTile(
            title: const Text('Countdown from'),
            trailing: DropdownButton<int>(
              value: settings.countdownFromSeconds,
              items: const [10, 20, 30, 60]
                  .map((seconds) => DropdownMenuItem(value: seconds, child: Text('${seconds}s')))
                  .toList(),
              onChanged: (seconds) {
                if (seconds != null) notifier.updateCountdownFromSeconds(seconds);
              },
            ),
          ),
        ],
      ),
    );
  }
}
