import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/build_flavor.dart';
import 'core/services/shared_preferences_provider.dart';

Future<void> bootstrap(BuildFlavor flavor) async {
  AppConfig.flavor = flavor;
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const TikTalkApp(),
    ),
  );
}
