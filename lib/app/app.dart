import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/providers.dart';
import 'app_events.dart';
import 'navigation.dart';
import 'root_shell.dart';
import 'theme.dart';

class LimbloopApp extends ConsumerWidget {
  const LimbloopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider).value?.theme;
    return MaterialApp(
      title: 'Limbloop',
      navigatorKey: navigatorKey,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: switch (theme) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.auto || null => ThemeMode.system,
      },
      home: const AppEvents(child: RootShell()),
    );
  }
}
