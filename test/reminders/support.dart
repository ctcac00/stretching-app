import 'package:limbloop/features/reminders/notification_gateway.dart';
import 'package:timezone/timezone.dart';

class FakeGateway implements NotificationGateway {
  String zone = 'UTC';
  String? launchPayload;
  bool granted = false;

  /// What the user answers to the permission prompt.
  bool answer = false;
  int requests = 0;
  void Function(String? payload)? onTap;
  final pending = <int, ({TZDateTime when, String payload})>{};

  @override
  Future<String?> init(void Function(String? payload) onTap) async {
    this.onTap = onTap;
    return launchPayload;
  }

  @override
  Future<String> localTimeZone() async => zone;

  @override
  Future<void> cancelPending() async => pending.clear();

  @override
  Future<void> schedule(int id, TZDateTime when, String payload) async {
    if (pending.containsKey(id)) throw StateError('duplicate id $id');
    pending[id] = (when: when, payload: payload);
  }

  @override
  Future<bool> isEnabled() async => granted;

  @override
  Future<void> requestPermission() async {
    requests++;
    granted = answer;
  }
}
