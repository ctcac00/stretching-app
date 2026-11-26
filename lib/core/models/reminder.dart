enum ReminderType { interval, times }

/// Which routine items a reminder starts.
enum ReminderScope { nextUp, all, chosen }

const reminderIntervals = [30, 60, 90, 120, 180, 240];

/// A reminder with its chosen subset. All times are minutes since midnight.
class Reminder {
  const Reminder({
    this.id,
    this.type = ReminderType.times,
    this.intervalMinutes = 120,
    this.startMinute = 9 * 60,
    this.endMinute = 18 * 60,
    this.times = const [9 * 60],
    this.scope = ReminderScope.nextUp,
    this.itemIds = const {},
    this.enabled = true,
  });

  /// Null until saved.
  final int? id;
  final ReminderType type;

  /// Used when [type] is interval.
  final int intervalMinutes;
  final int startMinute;
  final int endMinute;

  /// Used when [type] is times.
  final List<int> times;
  final ReminderScope scope;

  /// Routine item ids, used when [scope] is chosen.
  final Set<int> itemIds;
  final bool enabled;

  /// The times of day this reminder fires, sorted and distinct. Empty if it has
  /// no set times, or if the interval window starts after it ends.
  List<int> get fireTimes {
    if (type == ReminderType.times) return times.toSet().toList()..sort();
    return [
      if (intervalMinutes > 0)
        for (var m = startMinute; m <= endMinute; m += intervalMinutes) m,
    ];
  }

  /// "Next up", "Whole routine" or "N chosen exercises".
  String get scopeLabel => switch (scope) {
    ReminderScope.nextUp => 'Next up',
    ReminderScope.all => 'Whole routine',
    ReminderScope.chosen =>
      '${itemIds.length} chosen exercise${itemIds.length == 1 ? '' : 's'}',
  };

  Reminder copyWith({
    ReminderType? type,
    int? intervalMinutes,
    int? startMinute,
    int? endMinute,
    List<int>? times,
    ReminderScope? scope,
    Set<int>? itemIds,
    bool? enabled,
  }) => Reminder(
    id: id,
    type: type ?? this.type,
    intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    times: times ?? this.times,
    scope: scope ?? this.scope,
    itemIds: itemIds ?? this.itemIds,
    enabled: enabled ?? this.enabled,
  );
}
