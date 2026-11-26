import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/providers.dart';

/// Sound, haptics and theme settings, shown at the bottom of the Today screen.
class SettingsCard extends ConsumerWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const SizedBox.shrink();
    final repository = ref.read(settingsRepositoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Sound cue'),
              value: settings.sound,
              onChanged: repository.setSound,
            ),
            SwitchListTile(
              title: const Text('Haptic cue'),
              value: settings.haptics,
              onChanged: repository.setHaptics,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemePreference>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ThemePreference.auto,
                      label: Text('Auto'),
                    ),
                    ButtonSegment(
                      value: ThemePreference.light,
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemePreference.dark,
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {settings.theme},
                  onSelectionChanged: (s) => repository.setTheme(s.single),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
