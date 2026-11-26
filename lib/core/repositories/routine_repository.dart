import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/reminder.dart';
import '../models/routine_values.dart';

class RoutineRepository {
  RoutineRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$RoutineItemsTable, RoutineItem> get _ordered =>
      _db.select(_db.routineItems)..orderBy([
        (t) => OrderingTerm(expression: t.position),
        (t) => OrderingTerm(expression: t.id),
      ]);

  /// The routine in order.
  Stream<List<RoutineItem>> watchAll() => _ordered.watch();

  Future<List<RoutineItem>> getAll() => _ordered.get();

  Future<RoutineItem?> get(int id) => (_db.select(
    _db.routineItems,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Appends an item and returns it. [value] defaults per [mode] and is clamped.
  Future<RoutineItem> add(
    String exerciseId, {
    ExerciseMode mode = ExerciseMode.time,
    int? value,
    Sides sides = Sides.single,
  }) => _db.transaction(() async {
    final last = _db.routineItems.position.max();
    final query = _db.selectOnly(_db.routineItems)..addColumns([last]);
    final position = ((await query.getSingle()).read(last) ?? -1) + 1;
    return _db
        .into(_db.routineItems)
        .insertReturning(
          RoutineItemsCompanion.insert(
            position: position,
            exerciseId: exerciseId,
            mode: mode,
            value: clampValue(mode, value ?? defaultValue(mode)),
            sides: sides,
          ),
        );
  });

  /// Saves mode, value and sides. Order is changed only by [reorder].
  Future<void> update(RoutineItem item) async {
    await (_db.update(
      _db.routineItems,
    )..where((t) => t.id.equals(item.id))).write(
      RoutineItemsCompanion(
        mode: Value(item.mode),
        value: Value(clampValue(item.mode, item.value)),
        sides: Value(item.sides),
      ),
    );
  }

  /// [ids] is the whole routine in its new order.
  Future<void> reorder(List<int> ids) => _db.transaction(() async {
    for (final (position, id) in ids.indexed) {
      await (_db.update(_db.routineItems)..where((t) => t.id.equals(id))).write(
        RoutineItemsCompanion(position: Value(position)),
      );
    }
  });

  /// Removes an item, also from reminder subsets. A reminder whose chosen subset
  /// becomes empty is disabled.
  Future<void> delete(int id) => _db.transaction(() async {
    final links = _db.reminderItems;
    final affected = [
      for (final row in await (_db.select(
        links,
      )..where((t) => t.routineItemId.equals(id))).get())
        row.reminderId,
    ];
    await (_db.delete(links)..where((t) => t.routineItemId.equals(id))).go();
    await (_db.delete(_db.routineItems)..where((t) => t.id.equals(id))).go();
    for (final reminderId in affected) {
      final remaining = await (_db.select(
        links,
      )..where((t) => t.reminderId.equals(reminderId))).get();
      if (remaining.isNotEmpty) continue;
      await (_db.update(_db.reminders)..where(
            (t) =>
                t.id.equals(reminderId) &
                t.scope.equalsValue(ReminderScope.chosen),
          ))
          .write(const RemindersCompanion(enabled: Value(false)));
    }
  });

  /// Removes every item using [exerciseId], with the same cleanup as [delete].
  Future<void> deleteExercise(String exerciseId) => _db.transaction(() async {
    final items = await (_db.select(
      _db.routineItems,
    )..where((t) => t.exerciseId.equals(exerciseId))).get();
    for (final item in items) {
      await delete(item.id);
    }
  });
}
