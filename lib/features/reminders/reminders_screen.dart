import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import 'notification_gateway.dart';
import 'reminder_editor_screen.dart';
import 'reminder_labels.dart';
import 'reminder_scheduler.dart';

final _notificationsEnabledProvider = FutureProvider.autoDispose<bool>(
  (ref) async =>
      await ref.watch(notificationGatewayProvider)?.isEnabled() ?? true,
);

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The user may come back from the system settings.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(_notificationsEnabledProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _edit(Reminder reminder) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReminderEditorScreen(reminder)),
    );
    if (saved != true || !mounted) return;
    final gateway = ref.read(notificationGatewayProvider);
    if (gateway == null) return;
    // The system only prompts while the user has not decided.
    await gateway.requestPermission();
    if (!mounted) return;
    ref.invalidate(_notificationsEnabledProvider);
    await ref.read(reminderSchedulerProvider).reschedule();
  }

  Future<void> _setEnabled(int id, bool enabled) async {
    try {
      await ref.read(reminderRepositoryProvider).setEnabled(id, enabled);
    } on ReminderException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(problemText(e.problem))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider).value;
    // A saved reminder means permission was asked, so "off" means refused.
    final off =
        reminders != null &&
        reminders.isNotEmpty &&
        ref.watch(_notificationsEnabledProvider).value == false;
    final settings = Theme.of(context).platform == TargetPlatform.iOS
        ? 'iOS Settings > Notifications > Limbloop'
        : 'Android Settings > Apps > Limbloop > Notifications';
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: reminders == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (off)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_off),
                      title: const Text('Notifications are off'),
                      subtitle: Text('Turn them on in $settings.'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${distinctTimes(reminders).length} of $maxPending '
                    'notification slots used',
                  ),
                ),
                if (reminders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('No reminders.'),
                  ),
                for (final r in reminders)
                  Card(
                    child: ListTile(
                      title: Text(reminderTitle(r)),
                      subtitle: Text(r.scopeLabel),
                      onTap: () => _edit(r),
                      trailing: Switch(
                        value: r.enabled,
                        onChanged: (on) => _setEnabled(r.id!, on),
                      ),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: () => _edit(const Reminder()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add reminder'),
                ),
              ],
            ),
    );
  }
}
