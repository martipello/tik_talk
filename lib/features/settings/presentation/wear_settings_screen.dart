import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/dial_accent_color.dart';
import '../../../core/theme/dial_face_style.dart';
import '../providers/settings_notifier.dart';

// Label-to-its-own-control gap vs gap-between-sections: previously these
// were backwards-feeling (14 before a label, 8 after it), which read as the
// label belonging to the section above rather than the control below it.
// Section gap is now clearly the bigger of the two everywhere.
const double _labelGap = 6;
const double _sectionGap = 26;

class WearSettingsScreen extends ConsumerWidget {
  const WearSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          // A round screen's chord narrows fast near the top/bottom - 16px
          // was measured clipping "Mute announcements" against the bezel on
          // a Pixel Watch 2 emulator even though it's not that close to the
          // very top. Generous, uniform padding rather than a
          // height-dependent inset - simplest fix that's safe everywhere
          // content can land, at the cost of some unused width mid-screen.
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 44),
          children: [
            // Scrolls away with everything else rather than sitting pinned
            // on top of it - Wear OS treats a fixed overlay that content
            // can't scroll clear of as broken UX, not just a style choice.
            // It used to be a Positioned overlay for exactly this reason
            // and read as "overlapping" no matter where it sat.
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: _sectionGap),
            const _SectionLabel('Countdown'),
            const SizedBox(height: _labelGap),
            _CountdownStepper(
              seconds: settings.countdownSeconds,
              onChanged: notifier.updateCountdownSeconds,
            ),
            const SizedBox(height: _sectionGap),
            const _SectionLabel('Face'),
            const SizedBox(height: _labelGap),
            // No embedded floating label on the dropdown itself (unlike
            // the phone's) - that put "Face" inside the box border,
            // visually a different treatment from every other section's
            // plain caption above it, which is what read as chaotic.
            DropdownMenu<DialFaceStyle>(
              initialSelection: settings.dialFaceStyle,
              expandedInsets: EdgeInsets.zero,
              onSelected: (value) {
                if (value != null) notifier.updateDialFaceStyle(value);
              },
              dropdownMenuEntries: [
                for (final style in DialFaceStyle.values)
                  DropdownMenuEntry(value: style, label: style.displayName),
              ],
            ),
            const SizedBox(height: _sectionGap),
            const _SectionLabel('Color'),
            const SizedBox(height: _labelGap),
            _AccentPicker(
              selected: settings.dialAccentColor,
              onSelected: notifier.updateDialAccentColor,
            ),
            const SizedBox(height: _sectionGap),
            const _SectionLabel('Announcements'),
            const SizedBox(height: _labelGap),
            Center(
              child: Switch(
                value: settings.ttsMuted,
                onChanged: notifier.updateTtsMuted,
              ),
            ),
            Center(
              child: Text(
                settings.ttsMuted ? 'Muted' : 'On',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

// Previously a bare Wrap of 7 raw circles with only a border to mark the
// selected one - a thin 2.5px border is easy to miss at a glance on a tiny
// screen, and Wrap's auto-flow split them 4-then-3 unpredictably. This is
// an explicit two-row grid (so the split is always the same), a check mark
// over the selected swatch instead of relying on the border alone, and the
// selected color's name spelled out below - the phone settings page shows
// names directly (via the dropdown), this didn't.
class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.selected, required this.onSelected});

  final DialAccentColor selected;
  final ValueChanged<DialAccentColor> onSelected;

  @override
  Widget build(BuildContext context) {
    const values = DialAccentColor.values;
    final firstRow = values.sublist(0, 4);
    final secondRow = values.sublist(4);

    Widget row(List<DialAccentColor> accents) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final accent in accents) ...[
          _AccentSwatch(
            color: accent.value,
            isSelected: selected == accent,
            onTap: () => onSelected(accent),
          ),
          if (accent != accents.last) const SizedBox(width: 10),
        ],
      ],
    );

    return Column(
      children: [
        row(firstRow),
        const SizedBox(height: 10),
        row(secondRow),
        const SizedBox(height: 10),
        Text(
          selected.displayName,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // White/black need a check mark that reads on either, rather than one
    // fixed color that'd disappear on a same-toned swatch.
    final checkColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, size: 16, color: checkColor)
            : null,
      ),
    );
  }
}

class _CountdownStepper extends StatelessWidget {
  const _CountdownStepper({required this.seconds, required this.onChanged});

  final int seconds;
  final ValueChanged<int> onChanged;

  static const _options = [0, 3, 5, 10, 20, 30];

  @override
  Widget build(BuildContext context) {
    final index = _options.indexOf(seconds).clamp(0, _options.length - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: index == 0 ? null : () => onChanged(_options[index - 1]),
        ),
        SizedBox(
          width: 48,
          child: Text(
            seconds == 0 ? 'Off' : '${seconds}s',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: index == _options.length - 1
              ? null
              : () => onChanged(_options[index + 1]),
        ),
      ],
    );
  }
}
