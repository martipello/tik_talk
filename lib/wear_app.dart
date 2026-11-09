import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_notifier.dart';
import 'features/timer/presentation/wear_timer_screen.dart';

class TikTalkWearApp extends ConsumerWidget {
  const TikTalkWearApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final accentColor = settings.dialAccentColor.value;

    return MaterialApp(
      title: 'TikTalk Wear',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark(accentColor),
      darkTheme: AppTheme.dark(accentColor),
      // Horizontal swipe-paging (Timer/History/Settings) got dropped: on
      // device it kept losing the gesture to Wear OS's own back handling,
      // which treats a lot of horizontal drags as "leave the app" rather
      // than "change page," with no reliable way to tell it not to. Timer
      // is the only home now; History/Settings are ordinary pushed routes
      // reached by tapping an icon on it, and the system's edge-swipe
      // gesture becomes a normal (and this time actually reliable) back
      // instead of fighting it.
      home: const WearTimerScreen(),
    );
  }
}
