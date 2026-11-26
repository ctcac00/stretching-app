import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/app/tabs.dart';
import 'package:limbloop/core/providers.dart';
import 'package:limbloop/features/routine/routine_hooks.dart';
import 'package:limbloop/features/routine/routine_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../support/test_support.dart';

void main() {
  late AppDatabase db;
  late RoutineRepository routine;

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          documentsDirectoryProvider.overrideWithValue(Directory.systemTemp),
          bundledExercisesProvider.overrideWith(
            (ref) async => const [
              Exercise(id: 'a', name: 'Alpha'),
              Exercise(id: 'b', name: 'Bravo'),
              Exercise(id: 'c', name: 'Charlie'),
            ],
          ),
        ],
        child: const MaterialApp(home: RoutineScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await db.close();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  String shownValue(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('routine-value'))).data!;

  setUp(() {
    db = testDatabase();
    routine = RoutineRepository(db);
  });

  testWidgets('empty routine leads to the library; added items appear', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(
      find.text('Routine empty. Add stretches from the library.'),
      findsOne,
    );

    await tap(tester, find.text('+ Add from library'));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RoutineScreen)),
    );
    expect(container.read(selectedTabProvider), AppTab.library);

    // What the library does on "Add to routine", including a duplicate.
    await routine.add('a');
    final second = await routine.add('a');
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsNWidgets(2));
    expect(find.text('60 s'), findsNWidgets(2));

    openRoutineItemEditor(
      tester.element(find.byType(RoutineScreen)),
      second.id,
    );
    await tester.pumpAndSettle();
    expect(find.text('Remove from routine'), findsOne);
    expect(shownValue(tester), '60');
    await finish(tester);
  });

  testWidgets('edits mode, value and sides, saved only on Save', (
    tester,
  ) async {
    final id = (await routine.add('a')).id;
    await pumpScreen(tester);

    await tap(tester, find.text('Alpha'));
    await tap(tester, find.byTooltip('Increase'));
    expect(shownValue(tester), '65');
    await tap(tester, find.text('Close'));
    expect((await routine.get(id))!.value, 60);

    await tap(tester, find.text('Alpha'));
    await tap(tester, find.text('Reps'));
    expect(shownValue(tester), '10');
    await tap(tester, find.byTooltip('Decrease'));
    await tap(tester, find.text('Left / right'));
    expect(find.text('Reps per side'), findsOne);
    await tap(tester, find.text('Save'));

    final saved = (await routine.get(id))!;
    expect(saved.mode, ExerciseMode.reps);
    expect(saved.value, 9);
    expect(saved.sides, Sides.leftRight);
    expect(find.text('9 reps · left + right'), findsOne);

    // Back to duration restores the default; the minimum holds.
    await tap(tester, find.text('Alpha'));
    await tap(tester, find.text('Duration'));
    expect(shownValue(tester), '60');
    for (var i = 0; i < 13; i++) {
      await tap(tester, find.byTooltip('Decrease'));
    }
    expect(shownValue(tester), '5');
    await finish(tester);
  });

  testWidgets('dragging the handle reorders', (tester) async {
    final a = (await routine.add('a')).id;
    final b = (await routine.add('b')).id;
    final c = (await routine.add('c')).id;
    await pumpScreen(tester);

    final handles = find.byIcon(Icons.drag_indicator);
    final distance =
        tester.getCenter(handles.at(2)).dy - tester.getCenter(handles.at(0)).dy;
    final gesture = await tester.startGesture(tester.getCenter(handles.at(0)));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(Offset(0, (distance + 20) / 10));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect([for (final i in await routine.getAll()) i.id], [b, c, a]);
    double top(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(top('Bravo'), lessThan(top('Charlie')));
    expect(top('Charlie'), lessThan(top('Alpha')));
    await finish(tester);
  });

  testWidgets('removing cleans reminder subsets and disables emptied ones', (
    tester,
  ) async {
    final reminders = ReminderRepository(db);
    final a = (await routine.add('a')).id;
    final b = (await routine.add('b')).id;
    for (final ids in [
      {a},
      {a, b},
    ]) {
      await reminders.save(Reminder(scope: ReminderScope.chosen, itemIds: ids));
    }
    await pumpScreen(tester);

    await tap(tester, find.text('Alpha'));
    await tap(tester, find.text('Remove from routine'));

    expect(find.text('Alpha'), findsNothing);
    expect([for (final i in await routine.getAll()) i.id], [b]);
    final saved = await reminders.getAll();
    expect(saved.map((r) => r.itemIds), [
      <int>{},
      {b},
    ]);
    expect(saved.map((r) => r.enabled), [false, true]);
    await finish(tester);
  });
}
