import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oc_liquid_glass/oc_liquid_glass.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/build_flavor.dart';
import 'core/services/shared_preferences_provider.dart';

Future<void> bootstrap(BuildFlavor flavor, Widget app) async {
  AppConfig.flavor = flavor;
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  await OCLiquidGlassGroup.precacheShader();

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: app,
    ),
  );
}
