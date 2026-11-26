import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/app/app.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/reminders/reminder_scheduler.dart';
import 'package:limbloop/features/session/session_launcher.dart';
import 'package:material_ui/material_ui.dart';

import '../support/test_support.dart';

class _FakeScheduler implements ReminderScheduler {
  _FakeScheduler(this.ref);

  @override
  final Ref ref;
  final calls = <String>[];

  @override
  Future<void> init() async => calls.add('init');

  @override
  Future<void> reschedule() async => calls.add('reschedule');
}

void main() {
  testWidgets('shell shows tabs and reschedules on open, edit and resume', (
    tester,
  ) async {
    final db = testDatabase();
    late _FakeScheduler scheduler;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          documentsDirectoryProvider.overrideWithValue(Directory.systemTemp),
          bundledExercisesProvider.overrideWith((ref) => const <Exercise>[]),
          reminderSchedulerProvider.overrideWith(
            (ref) => scheduler = _FakeScheduler(ref),
          ),
        ],
        child: const LimbloopApp(),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Today', 'Library', 'Routine', 'Reminders']) {
      expect(find.widgetWithText(NavigationDestination, label), findsOne);
    }
    expect(scheduler.calls, ['init', 'reschedule']);

    Future<int> rescheduled(Future<void> Function() action) async {
      scheduler.calls.clear();
      await action();
      await tester.pumpAndSettle();
      return scheduler.calls.length;
    }

    final routine = RoutineRepository(db);
    late int id;
    expect(await rescheduled(() async => id = (await routine.add('x')).id), 1);
    expect(
      await rescheduled(
        () async => ReminderRepository(db).save(const Reminder()),
      ),
      1,
    );
    expect(
      await rescheduled(
        () async => SessionRepository(db, DateTime.now).record([id]),
      ),
      1,
    );
    expect(await rescheduled(() => SettingsRepository(db).setSound(false)), 0);
    expect(
      await rescheduled(() async {
        for (final state in [
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
      }),
      1,
    );

    // The session seam works without a context.
    openSession([id]);
    await tester.pumpAndSettle();
    expect(find.text('Unknown exercise'), findsOne);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
