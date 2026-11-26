import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/providers.dart';
import '../features/reminders/reminder_scheduler.dart';

/// Reschedules reminders on app open, on resume, at midnight, and after any
/// change to the routine, reminders or sessions. Features never need to ask.
/// Also keeps `todayProvider` current.
class AppEvents extends ConsumerStatefulWidget {
  const AppEvents({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppEvents> createState() => _AppEventsState();
}

class _AppEventsState extends ConsumerState<AppEvents> {
  late final AppLifecycleListener _lifecycle;
  late final StreamSubscription<void> _changes;
  Timer? _midnight;
  bool _initialised = false;
  bool _busy = false;
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    final db = ref.read(databaseProvider);
    _changes = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.routineItems,
            db.reminders,
            db.reminderItems,
            db.sessions,
            db.sessionItems,
          ]),
        )
        .listen((_) => _reschedule());
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _armMidnight();
    // After the first frame the navigator exists, so a notification that
    // launched the app can open a session.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;
    await _guard(ref.read(reminderSchedulerProvider).init);
    _initialised = true;
    await _reschedule();
  }

  /// The date or time zone may have changed.
  void _refresh() {
    ref.invalidate(todayProvider);
    ref.invalidate(nextUpProvider);
    _armMidnight();
    _reschedule();
  }

  void _armMidnight() {
    _midnight?.cancel();
    final now = ref.read(clockProvider)();
    final next = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    _midnight = Timer(next.difference(now), _refresh);
  }

  /// Runs one reschedule at a time; requests made meanwhile cause one rerun.
  Future<void> _reschedule() async {
    _pending = true;
    if (!_initialised || _busy) return;
    _busy = true;
    while (_pending && mounted) {
      _pending = false;
      await _guard(ref.read(reminderSchedulerProvider).reschedule);
    }
    _busy = false;
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'reminders',
        ),
      );
    }
  }

  @override
  void dispose() {
    _changes.cancel();
    _lifecycle.dispose();
    _midnight?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
