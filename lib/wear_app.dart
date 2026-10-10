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

    return MaterialApp(
      title: 'TikTalk Wear',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark(settings.dialTheme),
      darkTheme: AppTheme.dark(settings.dialTheme),
      home: const WearTimerScreen(),
    );
  }
}
