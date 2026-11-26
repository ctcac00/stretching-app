/// Session timing. Pure Dart: no Flutter imports.
library;

import '../../core/clock.dart';
import '../../core/db/database.dart';
import '../../core/models/routine_values.dart';

/// "Get ready" before each exercise and before the second side.
const readySeconds = 5;

enum SessionPhase { ready, work, finished }

/// Plays [items] in order. Time left comes from the wall clock, so it is right
/// after backgrounding; the caller only has to call [tick] while in the
/// foreground.
///
/// One [tick] ends at most the current phase (as in the mockup): a countdown
/// that ran out while backgrounded counts as done, and the next phase starts in
/// full at the time of the tick. A tick that is on time starts the next phase
/// where the last one ended, so timer lag does not add up.
class SessionController {
  SessionController({
    required this.items,
    required this.clock,
    required this.onCue,
    required this.record,
  }) : assert(items.isNotEmpty) {
    _getReady();
  }

  final List<RoutineItem> items;
  final Clock clock;

  /// Called on every phase change after the first.
  final void Function() onCue;

  /// Called exactly once, with the completed item ids, when the session
  /// finishes or is closed.
  final Future<void> Function(List<int> itemIds) record;

  /// Items with all sides completed.
  final completed = <int>[];

  SessionPhase get phase => _phase;
  SessionPhase _phase = SessionPhase.ready;

  /// Position in [items].
  int get index => _index;
  int _index = 0;

  /// 0, or 1 for the second side.
  int get side => _side;
  int _side = 0;

  DateTime? _end;
  DateTime? _anchor;
  Duration? _paused;
  Future<void>? _recorded;
  bool _closed = false;

  RoutineItem get item => items[_index];
  bool get isPaused => _paused != null;

  /// Length of the current countdown; null when there is none (reps).
  int? get phaseSeconds => switch (_phase) {
    SessionPhase.ready => readySeconds,
    SessionPhase.work when item.mode == ExerciseMode.time => item.value,
    _ => null,
  };

  Duration get remaining {
    final left = _paused ?? _end?.difference(clock()) ?? Duration.zero;
    return left.isNegative ? Duration.zero : left;
  }

  int get secondsLeft => (remaining.inMilliseconds / 1000).ceil();

  bool get _over => _closed || _phase == SessionPhase.finished;

  /// Ends the current countdown if its time is up.
  void tick() {
    final end = _end;
    if (isPaused || end == null || clock().isBefore(end)) return;
    if (clock().difference(end) < const Duration(seconds: 1)) _anchor = end;
    next();
    _anchor = null;
  }

  /// "Start now" while getting ready, otherwise "Done".
  void next() {
    if (_over) return;
    if (_phase == SessionPhase.ready) {
      _phase = SessionPhase.work;
      _countDown(phaseSeconds);
      onCue();
    } else if (item.sides == Sides.leftRight && _side == 0) {
      _side = 1;
      _getReady();
      onCue();
    } else {
      completed.add(item.id);
      _advance();
    }
  }

  /// Leaves the current item uncounted.
  void skip() {
    if (!_over) _advance();
  }

  void togglePause() {
    if (_over || _end == null) return;
    if (_paused == null) {
      _paused = remaining;
    } else {
      _end = clock().add(_paused!);
      _paused = null;
    }
  }

  /// Stops the session and records it. Safe to call repeatedly.
  Future<void> close() {
    _closed = true;
    return _recorded ??= record(List.of(completed));
  }

  void _advance() {
    _side = 0;
    if (_index + 1 < items.length) {
      _index++;
      _getReady();
    } else {
      _phase = SessionPhase.finished;
      _countDown(null);
      _recorded ??= record(List.of(completed));
    }
    onCue();
  }

  void _getReady() {
    _phase = SessionPhase.ready;
    _countDown(readySeconds);
  }

  void _countDown(int? seconds) {
    _paused = null;
    _end = seconds == null
        ? null
        : (_anchor ?? clock()).add(Duration(seconds: seconds));
  }
}
