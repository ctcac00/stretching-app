import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/library/library_screen.dart';
import '../features/progress/today_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/routine/routine_screen.dart';
import 'tabs.dart';

class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: tab.index,
        // Same order as AppTab.
        children: const [
          TodayScreen(),
          LibraryScreen(),
          RoutineScreen(),
          RemindersScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (i) =>
            ref.read(selectedTabProvider.notifier).select(AppTab.values[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.swap_vert), label: 'Routine'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Reminders'),
        ],
      ),
    );
  }
}
