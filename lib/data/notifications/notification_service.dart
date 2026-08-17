import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _settingsChannel = MethodChannel('io.robert.note/notifications');
  static const _openSettingsMethod = 'openNotificationSettings';

  static const _channelId = 'event_reminders';
  static const _channelName = 'Event reminders';
  static const _channelDescription = 'Reminders for events from the calendar';
  static const _androidIcon = '@mipmap/ic_launcher';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _isInitialised = false;

  Future<void> init() async {
    if (_isInitialised) {
      return;
    }

    tz_data.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    _isInitialised = true;
  }

  Future<bool> areEnabled() async {
    final android = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    if (android != null) {
      return android;
    }

    final ios = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();

    return ios?.isEnabled ?? false;
  }

  Future<bool> requestPermissions() async {
    final android = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (android != null) {
      return android;
    }

    final ios = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return ios ?? false;
  }

  /// Whether reminders can land to the minute rather than in a window.
  ///
  /// The app does not hold `USE_EXACT_ALARM` - Play keeps that one for alarm
  /// clocks - so on Android 13 and up this is false until the user grants
  /// `SCHEDULE_EXACT_ALARM` themselves. True everywhere the question does not
  /// arise, including iOS and older Androids.
  Future<bool> canScheduleExactReminders() async {
    try {
      final android = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.canScheduleExactNotifications();

      return android ?? true;
    } on PlatformException catch (error, stackTrace) {
      logSevere('Asking about exact alarms failed', error, stackTrace);

      return false;
    }
  }

  /// Sends the user to the system screen where exact alarms are granted. What
  /// they chose is only known once they come back, so this hands back nothing
  /// and the caller re-reads [canScheduleExactReminders] on resume.
  Future<void> requestExactReminders() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } on PlatformException catch (error, stackTrace) {
      logSevere('Requesting exact alarms failed', error, stackTrace);
    }
  }

  Future<bool> openSystemSettings() async {
    try {
      return await _settingsChannel.invokeMethod<bool>(_openSettingsMethod) ?? false;
    } on PlatformException catch (error, stackTrace) {
      logSevere('Opening the notification settings failed', error, stackTrace);

      return false;
    } on MissingPluginException catch (error, stackTrace) {
      logSevere('The platform does not answer $_openSettingsMethod', error, stackTrace);

      return false;
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required DateTime remindAt,
    String? body,
  }) async {
    await cancelReminder(id);

    if (!remindAt.isAfter(DateTime.now())) {
      logInfo('Skipping a reminder in the past for event $id');

      return;
    }

    // To the minute if the user allowed exact alarms, and in a window if not.
    // The app deliberately does not hold USE_EXACT_ALARM - see the manifest -
    // so being turned down here is the ordinary case, not a fault.
    if (await _schedule(id: id, title: title, body: body, remindAt: remindAt, isExact: true)) {
      return;
    }

    await _schedule(id: id, title: title, body: body, remindAt: remindAt, isExact: false);
  }

  /// False when Android refused the alarm, which is what an inexact retry is
  /// for. Anything else is logged and swallowed: a reminder that could not be
  /// set must not take the event down with it.
  Future<bool> _schedule({
    required int id,
    required String title,
    required String? body,
    required DateTime remindAt,
    required bool isExact,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(remindAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: isExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );

      return true;
    } on PlatformException catch (error, stackTrace) {
      if (isExact) {
        logInfo('Exact alarms are not permitted, falling back to an inexact reminder for event $id');

        return false;
      }

      logSevere('Scheduling a reminder failed for event $id', error, stackTrace);

      return true;
    }
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id: id);
}
