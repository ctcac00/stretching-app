// The only file that talks to the notification plugins.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' show TZDateTime;

/// Thin seam over the platform, faked in tests.
abstract class NotificationGateway {
  /// Sets up the plugin. [onTap] gets the payload of a notification tapped
  /// while the app is alive. Returns the payload of the notification that
  /// launched the app, or null.
  Future<String?> init(void Function(String? payload) onTap);

  /// IANA name of the device time zone, read afresh on every call.
  Future<String> localTimeZone();

  /// Cancels scheduled notifications; delivered ones stay and remain tappable.
  Future<void> cancelPending();

  Future<void> schedule(int id, TZDateTime when, String payload);

  Future<bool> isEnabled();

  /// Shows the system prompt if the platform still allows one.
  Future<void> requestPermission();
}

class PluginNotificationGateway implements NotificationGateway {
  final _plugin = FlutterLocalNotificationsPlugin();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<String?> init(void Function(String? payload) onTap) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is asked later, when the first reminder is saved.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) => onTap(response.payload),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch != null && launch.didNotificationLaunchApp
        ? launch.notificationResponse?.payload
        : null;
  }

  @override
  Future<String> localTimeZone() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;

  @override
  Future<void> cancelPending() => _plugin.cancelAllPendingNotifications();

  @override
  Future<void> schedule(int id, TZDateTime when, String payload) =>
      _plugin.zonedSchedule(
        id: id,
        title: 'Limbloop',
        body: 'Time to stretch',
        scheduledDate: when,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          // Also shown, with sound, while the app is in the foreground.
          iOS: DarwinNotificationDetails(
            presentBanner: true,
            presentList: true,
            presentSound: true,
            presentBadge: false,
          ),
        ),
      );

  @override
  Future<bool> isEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return (await _ios?.checkPermissions())?.isEnabled ?? false;
    }
    return await _android?.areNotificationsEnabled() ?? false;
  }

  @override
  Future<void> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _ios?.requestPermissions(alert: true, sound: true);
    } else {
      await _android?.requestNotificationsPermission();
    }
  }
}

/// Null where there are no notifications: under `flutter test` (override with a
/// fake to test them) and on platforms other than iOS and Android.
final notificationGatewayProvider = Provider<NotificationGateway?>(
  (ref) =>
      (Platform.isIOS || Platform.isAndroid) &&
          !Platform.environment.containsKey('FLUTTER_TEST')
      ? PluginNotificationGateway()
      : null,
);
