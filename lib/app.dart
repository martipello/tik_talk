import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_notifier.dart';

class TikTalkApp extends ConsumerWidget {
  const TikTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TikTalk',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light(settings.dialAccentColor.value),
      darkTheme: AppTheme.dark(settings.dialAccentColor.value),
      routerConfig: router,
    );
  }
}
