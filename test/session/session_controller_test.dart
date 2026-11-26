import 'package:flutter_test/flutter_test.dart';
import 'package:limbloop/core/db/database.dart';
import 'package:limbloop/core/models/routine_values.dart';
import 'package:limbloop/features/session/session_controller.dart';

import '../support/test_support.dart';

RoutineItem item(
  int id, {
  ExerciseMode mode = ExerciseMode.time,
  int value = 30,
  Sides sides = Sides.single,
}) => RoutineItem(
  id: id,
  position: id,
  exerciseId: 'x',
  mode: mode,
  value: value,
  sides: sides,
);

void main() {
  late TestClock clock;
  late List<List<int>> records;
  var cues = 0;

  SessionController start(List<RoutineItem> items) => SessionController(
    items: items,
    clock: clock.call,
    onCue: () => cues++,
    record: (ids) async => records.add(ids),
  );

  void advance(SessionController c, int milliseconds) {
    clock.now = clock.now.add(Duration(milliseconds: milliseconds));
    c.tick();
  }

  setUp(() {
    clock = TestClock(DateTime(2026, 11, 26, 9));
    records = [];
    cues = 0;
  });

  test('countdown: 5 s get ready, then the hold, then finished', () {
    final c = start([item(1)]);
    expect(c.phase, SessionPhase.ready);
    expect(c.secondsLeft, 5);
    expect(cues, 0);
    advance(c, 4001);
    expect(c.phase, SessionPhase.ready);
    expect(c.secondsLeft, 1);
    advance(c, 999);
    expect(c.phase, SessionPhase.work);
    expect(c.secondsLeft, 30);
    advance(c, 29999);
    expect(c.completed, isEmpty);
    advance(c, 1);
    expect(c.phase, SessionPhase.finished);
    expect(records, [
      [1],
    ]);
    expect(cues, 2);
  });

  test('timer lag does not add up, a long gap is dropped', () {
    final c = start([item(1)]);
    advance(c, 5200);
    expect(c.remaining, const Duration(milliseconds: 29800));

    final late = start([item(1)]);
    advance(late, 60000);
    expect(late.remaining, const Duration(seconds: 30));
  });

  test('side switch: get ready again, counted only after both sides', () {
    final c = start([item(1, sides: Sides.leftRight)]);
    c.next();
    advance(c, 30000);
    expect((c.phase, c.side), (SessionPhase.ready, 1));
    expect(c.secondsLeft, 5);
    expect(c.completed, isEmpty);
    advance(c, 5000);
    expect((c.phase, c.side), (SessionPhase.work, 1));
    advance(c, 30000);
    expect(c.completed, [1]);
  });

  test('closing between sides records only completed items, once', () async {
    final c = start([item(1), item(2, sides: Sides.leftRight)]);
    c
      ..next()
      ..next() // item 1 done
      ..next()
      ..next(); // first side of item 2 done
    await c.close();
    await c.close();
    c
      ..next()
      ..next();
    expect(records, [
      [1],
    ]);
  });

  test('skip leaves the whole item uncounted', () {
    final c = start([item(1, sides: Sides.leftRight), item(2)]);
    c
      ..next()
      ..next() // second side of item 1
      ..skip();
    expect((c.index, c.side, c.phase), (1, 0, SessionPhase.ready));
    c.skip();
    expect(c.phase, SessionPhase.finished);
    expect(records, [<int>[]]);
  });

  test('reps wait for Done', () {
    final c = start([item(1, mode: ExerciseMode.reps, value: 10)]);
    advance(c, 5000);
    expect(c.phaseSeconds, isNull);
    advance(c, 3600000);
    expect(c.phase, SessionPhase.work);
    c.next();
    expect(c.completed, [1]);
  });

  test('pause freezes the countdown', () {
    final c = start([item(1)]);
    advance(c, 2000);
    c.togglePause();
    advance(c, 60000);
    expect((c.phase, c.secondsLeft), (SessionPhase.ready, 3));
    c.togglePause();
    advance(c, 2999);
    expect(c.phase, SessionPhase.ready);
    advance(c, 1);
    expect(c.phase, SessionPhase.work);
  });

  test('a long absence ends only the current phase', () {
    final c = start([item(1, sides: Sides.leftRight), item(2)]);
    advance(c, 600000);
    expect((c.phase, c.secondsLeft), (SessionPhase.work, 30));
    advance(c, 600000);
    expect((c.phase, c.side, c.secondsLeft), (SessionPhase.ready, 1, 5));
    expect(c.completed, isEmpty);
  });
}
