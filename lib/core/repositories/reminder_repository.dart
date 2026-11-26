import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/reminder.dart';
import '../schedule.dart';

/// Thrown when a reminder cannot be saved or enabled.
class ReminderException implements Exception {
  const ReminderException(this.problem);

  final ReminderProblem problem;

  @override
  String toString() => 'ReminderException(${problem.name})';
}

class ReminderRepository {
  ReminderRepository(this._db);

  final AppDatabase _db;

  JoinedSelectStatement<HasResultSet, dynamic> get _joined =>
      _db.select(_db.reminders).join([
        leftOuterJoin(
          _db.reminderItems,
          _db.reminderItems.reminderId.equalsExp(_db.reminders.id),
        ),
      ])..orderBy([OrderingTerm(expression: _db.reminders.id)]);

  List<Reminder> _group(List<TypedResult> rows) {
    final reminders = <int, ReminderRow>{};
    final items = <int, Set<int>>{};
    for (final row in rows) {
      final reminder = row.readTable(_db.reminders);
      reminders[reminder.id] = reminder;
      final link = row.readTableOrNull(_db.reminderItems);
      final set = items.putIfAbsent(reminder.id, () => {});
      if (link != null) set.add(link.routineItemId);
    }
    return [
      for (final r in reminders.values)
        Reminder(
          id: r.id,
          type: r.type,
          intervalMinutes: r.intervalMinutes,
          startMinute: r.startMinute,
          endMinute: r.endMinute,
          times: r.times,
          scope: r.scope,
          itemIds: items[r.id]!,
          enabled: r.enabled,
        ),
    ];
  }

  /// All reminders, oldest first. Emits when reminders or subsets change.
  Stream<List<Reminder>> watchAll() => _joined.watch().map(_group);

  Future<List<Reminder>> getAll() async => _group(await _joined.get());

  /// Inserts (id null) or replaces a reminder and returns its id. The subset is
  /// kept only for the chosen scope, and only for existing routine items.
  /// Throws [ReminderException].
  Future<int> save(Reminder reminder) => _db.transaction(() async {
    var itemIds = <int>{};
    if (reminder.scope == ReminderScope.chosen) {
      final existing = {
        for (final item in await _db.select(_db.routineItems).get()) item.id,
      };
      itemIds = reminder.itemIds.intersection(existing);
    }
    final clean = reminder.copyWith(
      itemIds: itemIds,
      times: reminder.times.toSet().toList()..sort(),
    );
    final problem = reminderProblem(clean, await getAll());
    if (problem != null) throw ReminderException(problem);

    final row = RemindersCompanion.insert(
      type: clean.type,
      intervalMinutes: clean.intervalMinutes,
      startMinute: clean.startMinute,
      endMinute: clean.endMinute,
      times: clean.times,
      scope: clean.scope,
      enabled: clean.enabled,
    );
    var id = clean.id;
    if (id == null) {
      id = await _db.into(_db.reminders).insert(row);
    } else {
      final changed = await (_db.update(
        _db.reminders,
      )..where((t) => t.id.equals(clean.id!))).write(row);
      if (changed == 0) throw StateError('No reminder with id $id');
      await (_db.delete(
        _db.reminderItems,
      )..where((t) => t.reminderId.equals(clean.id!))).go();
    }
    for (final itemId in itemIds) {
      await _db
          .into(_db.reminderItems)
          .insert(
            ReminderItemsCompanion.insert(
              reminderId: id,
              routineItemId: itemId,
            ),
          );
    }
    return id;
  });

  /// Enabling throws [ReminderException] if the reminder has no times or no
  /// exercises (empty subset or empty routine), or exceeds the limit.
  Future<void> setEnabled(int id, bool enabled) => _db.transaction(() async {
    if (enabled) {
      final all = await getAll();
      final reminder = all.firstWhere((r) => r.id == id);
      var problem = reminderProblem(reminder, all);
      final routine = await (_db.select(_db.routineItems)..limit(1)).get();
      if (routine.isEmpty) problem ??= ReminderProblem.noExercises;
      if (problem != null) throw ReminderException(problem);
    }
    await (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(enabled: Value(enabled)),
    );
  });

  Future<void> delete(int id) async {
    await (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();
  }
}
