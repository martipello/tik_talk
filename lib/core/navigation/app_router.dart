import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/history/presentation/history_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/timer/presentation/timer_page.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/timer',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/timer', builder: (context, state) => const TimerPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/history', builder: (context, state) => const HistoryPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/settings', builder: (context, state) => const SettingsPage())],
          ),
        ],
      ),
    ],
  );
}
