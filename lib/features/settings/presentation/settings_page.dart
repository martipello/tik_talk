import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dial_accent_color.dart';
import '../../../core/theme/dial_face_style.dart';
import '../../../core/widgets/view_constraint.dart';
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
      body: ViewConstraint(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            SwitchListTile(
              title: const Text('Dark mode'),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (isDark) =>
                  notifier.updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light),
            ),
            const SizedBox(height: 16),
            _SettingDropdown<DialFaceStyle>(
              label: 'Watch face',
              value: settings.dialFaceStyle,
              entries: DialFaceStyle.values,
              labelOf: (style) => style.displayName,
              onSelected: notifier.updateDialFaceStyle,
            ),
            const SizedBox(height: 16),
            _SettingDropdown<DialAccentColor>(
              label: 'Color',
              value: settings.dialAccentColor,
              entries: DialAccentColor.values,
              labelOf: (color) => color.displayName,
              onSelected: notifier.updateDialAccentColor,
            ),
            const SizedBox(height: 16),
            _SettingDropdown<VoiceAnnounceInterval>(
              label: 'Voice announcements',
              value: settings.voiceAnnounceInterval,
              entries: VoiceAnnounceInterval.values,
              labelOf: (interval) => interval.label,
              onSelected: notifier.updateVoiceAnnounceInterval,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingDropdown<T> extends StatelessWidget {
  const _SettingDropdown({
    required this.label,
    required this.value,
    required this.entries,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final T value;
  final List<T> entries;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      label: Text(label),
      initialSelection: value,
      expandedInsets: EdgeInsets.zero,
      onSelected: (selected) {
        if (selected != null) onSelected(selected);
      },
      dropdownMenuEntries: entries
          .map((entry) => DropdownMenuEntry(value: entry, label: labelOf(entry)))
          .toList(),
    );
  }
}
