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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id: id);
}
