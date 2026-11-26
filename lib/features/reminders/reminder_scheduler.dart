// Notification service entry point. `AppEvents` (app layer) calls it; other
// features never need to. Keep the class name, provider and method signatures.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/providers.dart';
import '../session/session_launcher.dart';
import 'notification_gateway.dart';
import 'reminder_occurrences.dart';

class ReminderScheduler {
  ReminderScheduler(this.ref);

  final Ref ref;
  bool _initialised = false;
  Future<void> _queue = Future.value();

  /// Called once after the first frame, before the first [reschedule]. Set up
  /// the plugin and tap handling here, including the notification that launched
  /// the app (`openSession` / `openNextUpSession`).
  Future<void> init() async {
    final gateway = ref.read(notificationGatewayProvider);
    if (gateway == null || _initialised) return;
    _initialised = true;
    tz_data.initializeTimeZones();
    final launched = await gateway.init(_open);
    await _open(launched);
  }

  /// Replaces all pending notifications from the current database state. Calls
  /// are queued: `AppEvents` and the permission prompt may both ask.
  Future<void> reschedule() {
    final run = _queue.then((_) => _reschedule());
    _queue = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<void> _reschedule() async {
    final gateway = ref.read(notificationGatewayProvider);
    if (gateway == null) return;
    final location = tz.getLocation(await gateway.localTimeZone());
    final clock = ref.read(clockProvider);
    final now = clock();
    final routine = await ref.read(routineRepositoryProvider).getAll();
    final occurrences = upcomingOccurrences(
      reminders: await ref.read(reminderRepositoryProvider).getAll(),
      routineIds: {for (final item in routine) item.id},
      doneIds: await ref
          .read(sessionRepositoryProvider)
          .getDoneIds(localDate(now)),
      location: location,
      now: now,
    );
    await gateway.cancelPending();
    for (final occurrence in occurrences) {
      final when = occurrence.when;
      // The plugin rejects past times, and this one may have just passed.
      if (!when.isAfter(clock())) continue;
      // Minutes since 1970: unique, so a delivered notification is not reused.
      try {
        await gateway.schedule(
          when.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute,
          when,
          encodePayload(occurrence.reminderIds),
        );
      } catch (error, stack) {
        // One failure must not leave all later reminders unscheduled.
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stack),
        );
      }
    }
  }

  /// Opens the session for a tapped notification, from current data. All wins;
  /// otherwise the chosen subsets plus next-up items, in routine order.
  Future<void> _open(String? payload) async {
    final ids = decodePayload(payload);
    if (ids.isEmpty) return;
    final reminders = [
      for (final r in await ref.read(reminderRepositoryProvider).getAll())
        if (ids.contains(r.id)) r,
    ];
    // Also covers a notification whose reminders have all been deleted.
    if (reminders.every((r) => r.scope == ReminderScope.nextUp)) {
      return openNextUpSession();
    }
    final routine = await ref.read(routineRepositoryProvider).getAll();
    final all = reminders.any((r) => r.scope == ReminderScope.all);
    final wanted = {
      for (final r in reminders)
        if (r.scope == ReminderScope.chosen) ...r.itemIds,
    };
    if (!all && reminders.any((r) => r.scope == ReminderScope.nextUp)) {
      // What a running session completed must not be chosen again.
      await endRunningSession();
      final next = await ref.read(sessionRepositoryProvider).loadNextUp();
      wanted.addAll(next.map((item) => item.id));
    }
    await openSession([
      for (final item in routine)
        if (all || wanted.contains(item.id)) item.id,
    ]);
  }
}

final reminderSchedulerProvider = Provider(ReminderScheduler.new);
