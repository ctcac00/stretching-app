import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/reminders/notification_gateway.dart';
import 'package:limbloop/features/reminders/reminder_scheduler.dart';
import 'package:limbloop/features/session/session_launcher.dart';
import 'package:limbloop/features/session/session_player_screen.dart';

import '../reminders/support.dart';
import 'harness.dart';

void main() {
  testWidgets('merged tap during a session skips what it completed', (
    tester,
  ) async {
    final h = Harness(DateTime(2026, 11, 26, 9));
    final gateway = FakeGateway();
    final ids = [
      for (final exercise in ['a', 'b', 'a'])
        (await h.routine.add(exercise)).id,
    ];
    await h.settings.setPerSession(1);
    final next = await h.reminders.save(const Reminder());
    final chosen = await h.reminders.save(
      Reminder(scope: ReminderScope.chosen, itemIds: {ids[2]}),
    );
    await h.pump(
      tester,
      overrides: [notificationGatewayProvider.overrideWithValue(gateway)],
    );
    await ProviderScope.containerOf(tester.element(find.text('home')))
        .read(reminderSchedulerProvider)
        .init();

    openSession([ids[0], ids[1]]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start now'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pump();

    gateway.onTap!('$next,$chosen');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SessionPlayerScreen>(find.byType(SessionPlayerScreen))
          .itemIds,
      [ids[1], ids[2]],
    );
    await h.close(tester);
  });
}
