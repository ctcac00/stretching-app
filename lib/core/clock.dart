/// Injected everywhere "now" matters; override `clockProvider` in tests.
typedef Clock = DateTime Function();

/// The local calendar date as `yyyy-MM-dd`.
String localDate(DateTime time) {
  final t = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)}';
}

/// Minutes since local midnight.
int minuteOfDay(DateTime time) {
  final t = time.toLocal();
  return t.hour * 60 + t.minute;
}

/// `HH:mm` for minutes since midnight.
String formatMinute(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:'
    '${(minute % 60).toString().padLeft(2, '0')}';
