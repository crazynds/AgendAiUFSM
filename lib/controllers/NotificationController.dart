import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationPopup {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  NotificationPopup({required this.id, this.title, this.body, this.payload});
}

enum ChannelNotification {
  avisos(name: 'avisos', importance: Importance.low, priority: Priority.low),
  erro(name: 'erro', importance: Importance.high, priority: Priority.max),
  lembrete(
      name: 'lembrete', importance: Importance.high, priority: Priority.high);

  final String id;
  final String name;
  final Importance importance;
  final Priority priority;

  const ChannelNotification(
      {required this.name, required this.importance, required this.priority})
      : id = '${name}_id';
}

class NotificationController {
  static NotificationController instance = NotificationController();

  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidDetails;

  NotificationController() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  setup() async {
    await _initTimezone();
    await _initNotifications();
  }

  _initTimezone() async {
    tz.initializeTimeZones();
    final String timezoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));
  }

  _initNotifications() async {
    print("Iniciado");
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: android,
      ),
      onDidReceiveBackgroundNotificationResponse: _actionNotification,
    );
  }

  static _actionNotification(NotificationResponse? resp) {
    if (resp == null) return;
  }

  showNotification(ChannelNotification channel, NotificationPopup not) {
    androidDetails = AndroidNotificationDetails(channel.id, channel.name,
        priority: channel.priority,
        importance: channel.importance,
        enableVibration: true);
    localNotificationsPlugin.show(
      not.id,
      not.title,
      not.body,
      NotificationDetails(android: androidDetails),
      payload: not.payload,
    );
  }

  checkForNotifications() async {
    final details =
        await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      _actionNotification(details.notificationResponse);
    }
  }
}
