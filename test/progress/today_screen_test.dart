import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/progress/today_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../session/harness.dart';

void main() {
  late Harness h;

  Future<List<int>> open(WidgetTester tester, DateTime now) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    h = Harness(now);
    final ids = [
      for (final id in ['a', 'b', 'a', 'b']) (await h.routine.add(id)).id,
    ];
    await h.pump(tester, home: const TodayScreen());
    return ids;
  }

  bool enabled(WidgetTester tester, String label) => tester
      .widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      )
      .enabled;

  testWidgets('completion counts distinct current items done today', (
    tester,
  ) async {
    final ids = await open(tester, DateTime(2026, 11, 26, 9));
    expect(find.text('0 of 4 done'), findsOne);
    expect(find.text('Nothing yet.'), findsOne);

    await h.sessions.record([ids[0]]);
    await h.sessions.record([ids[0], ids[1]]);
    await tester.pumpAndSettle();
    expect(find.text('2 of 4 done'), findsOne);
    expect(find.text('50%'), findsOne);
    expect(find.text('09:00 · 1 exercise'), findsOne);
    expect(find.text('09:00 · 2 exercises'), findsOne);

    // Removed items stay in the history but no longer count.
    await h.routine.delete(ids[0]);
    await tester.pumpAndSettle();
    expect(find.text('1 of 3 done'), findsOne);
    await h.close(tester);
  });

  testWidgets('midnight starts a new day', (tester) async {
    await open(tester, DateTime(2026, 11, 26, 23, 59, 59));
    await tester.tap(find.text('Mark routine done'));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOne);
    expect(find.text('23:59 · 4 exercises'), findsOne);
    await h.reminders.save(const Reminder(times: [12 * 60]));
    await tester.pumpAndSettle();
    expect(find.text('Tomorrow 12:00 · Next up'), findsOne);
    expect(enabled(tester, 'All done for today'), false);
    expect(enabled(tester, 'Mark routine done'), false);

    await h.advance(tester, const Duration(seconds: 1));
    expect(find.text('0 of 4 done'), findsOne);
    expect(find.text('Nothing yet.'), findsOne);
    expect(enabled(tester, 'Start next 2'), true);
    await h.close(tester);
  });

  testWidgets('next up and next reminder follow the clock', (tester) async {
    await open(tester, DateTime(2026, 11, 26, 9));
    expect(find.text('None set.'), findsOne);
    await h.reminders.save(const Reminder(times: [12 * 60, 15 * 60]));
    await tester.pumpAndSettle();
    expect(find.text('Start next 2'), findsOne);
    expect(find.text('12:00 · Next up'), findsOne);

    await h.advance(tester, const Duration(hours: 3));
    expect(find.text('Start next 2'), findsOne);
    expect(find.text('15:00 · Next up'), findsOne);
    await h.advance(tester, const Duration(hours: 3));
    expect(find.text('Start next 4'), findsOne);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.text('Start next 1'), findsOne);
    expect((await h.settings.get()).perSession, 1);
    await h.close(tester);
  });

  testWidgets('starts picked items in routine order', (tester) async {
    await open(tester, DateTime(2026, 11, 26, 9));
    await tester.tap(find.byType(ListTile).at(3));
    await tester.tap(find.byType(ListTile).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start 2 selected'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsOne);
    expect(find.text('Alpha'), findsOne);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Start next 4'), findsOne);
    await h.close(tester);
  });

  testWidgets('empty routine', (tester) async {
    h = Harness(DateTime(2026, 11, 26, 9));
    await h.pump(tester, home: const TodayScreen());
    expect(enabled(tester, 'Routine is empty'), false);
    await h.close(tester);
  });
}
