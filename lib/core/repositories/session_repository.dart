import 'package:drift/drift.dart';

import '../clock.dart';
import '../db/database.dart';
import '../schedule.dart';
import 'reminder_repository.dart';
import 'routine_repository.dart';
import 'settings_repository.dart';

/// A recorded session and the routine items completed in it (possibly including
/// items since removed from the routine).
class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.date,
    required this.minute,
    required this.itemIds,
  });

  final int id;

  /// Local calendar date, `yyyy-MM-dd`.
  final String date;

  /// Local time, minutes since midnight.
  final int minute;
  final Set<int> itemIds;
}

class SessionRepository {
  SessionRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Records completed routine items at [at] (default: now). Returns the session
  /// id, or null without writing anything if [itemIds] is empty.
  Future<int?> record(Iterable<int> itemIds, {DateTime? at}) async {
    final ids = itemIds.toSet();
    if (ids.isEmpty) return null;
    final time = at ?? _clock();
    return _db.transaction(() async {
      final sessionId = await _db
          .into(_db.sessions)
          .insert(
            SessionsCompanion.insert(
              date: localDate(time),
              minute: minuteOfDay(time),
            ),
          );
      for (final id in ids) {
        await _db
            .into(_db.sessionItems)
            .insert(
              SessionItemsCompanion.insert(
                sessionId: sessionId,
                routineItemId: id,
              ),
            );
      }
      return sessionId;
    });
  }

  /// Records a session containing the whole current routine.
  Future<int?> markRoutineDone() => _db.transaction(() async {
    final items = await RoutineRepository(_db).getAll();
    return record(items.map((i) => i.id));
  });

  JoinedSelectStatement<HasResultSet, dynamic> _day(String date) =>
      _db.select(_db.sessions).join([
          innerJoin(
            _db.sessionItems,
            _db.sessionItems.sessionId.equalsExp(_db.sessions.id),
          ),
        ])
        ..where(_db.sessions.date.equals(date))
        ..orderBy([
          OrderingTerm(expression: _db.sessions.minute),
          OrderingTerm(expression: _db.sessions.id),
        ]);

  List<SessionRecord> _group(List<TypedResult> rows) {
    final sessions = <int, SessionRecord>{};
    for (final row in rows) {
      final s = row.readTable(_db.sessions);
      sessions
          .putIfAbsent(
            s.id,
            () => SessionRecord(
              id: s.id,
              date: s.date,
              minute: s.minute,
              itemIds: {},
            ),
          )
          .itemIds
          .add(row.readTable(_db.sessionItems).routineItemId);
    }
    return sessions.values.toList();
  }

  /// Sessions of a local date, earliest first.
  Stream<List<SessionRecord>> watchDay(String date) =>
      _day(date).watch().map(_group);

  Future<List<SessionRecord>> getDay(String date) async =>
      _group(await _day(date).get());

  JoinedSelectStatement<HasResultSet, dynamic> _done(String date) =>
      _db.select(_db.sessionItems).join([
        innerJoin(
          _db.sessions,
          _db.sessions.id.equalsExp(_db.sessionItems.sessionId),
        ),
        innerJoin(
          _db.routineItems,
          _db.routineItems.id.equalsExp(_db.sessionItems.routineItemId),
        ),
      ])..where(_db.sessions.date.equals(date));

  Set<int> _ids(List<TypedResult> rows) => {
    for (final row in rows) row.readTable(_db.sessionItems).routineItemId,
  };

  /// Distinct current routine items completed on a local date.
  Stream<Set<int>> watchDoneIds(String date) => _done(date).watch().map(_ids);

  Future<Set<int>> getDoneIds(String date) async =>
      _ids(await _done(date).get());

  /// The next-up items as of now. Call when a session starts.
  Future<List<RoutineItem>> loadNextUp() => _db.transaction(() async {
    final now = _clock();
    return nextUp(
      routine: await RoutineRepository(_db).getAll(),
      doneIds: await getDoneIds(localDate(now)),
      reminders: await ReminderRepository(_db).getAll(),
      perSession: (await SettingsRepository(_db).get()).perSession,
      now: now,
    );
  });
}
