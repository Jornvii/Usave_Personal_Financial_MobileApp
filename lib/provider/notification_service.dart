import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';


class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  final bool _initialized = false;
  bool get isInitialized => _initialized;

  // initialize the notification service
  Future<void> initNotification() async {
    if (_initialized) return;

//initialize the timezone
    tz.initializeTimeZones();
    final String cuurentTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(cuurentTimezone));

    // initialize for android
    const initSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    //init setting
    const initSettings = InitializationSettings(android: initSettingsAndroid);

//final init settings
    await notificationPlugin.initialize(initSettings);

// Notification Details
    NotificationDetails notificationDetails() {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      );
    }
  }

  // show normal notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return await notificationPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  // show notification by schedule
  Future<void> schaduleNotification({
    int id = 1,
    required String? title,
    required String? body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    //create a date/time for today at the specified time
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    //schedule the notification
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      // const NotificationDetails(
      //   android: AndroidNotificationDetails(
      //     'channel id',
      //     'channel name',
      //     importance: Importance.max,
      //     priority: Priority.high,
      //     playSound: true,
      //     enableVibration: true,
      //     enableLights: true,
      //     styleInformation: BigTextStyleInformation(''),
      //   ),
      // ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      // make notification repeat daily at the same time
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print("Notification schaduled");
  }

//  notifications from transactions 

  // Future<void> financialNotification() async {
  //   final db = NotificationDB();
  //   final notifications = await db.getNotifications();

  //   for (var notification in notifications) {
  //     final int? timestamp = notification['timestamp'];
  //     final String message = notification['message'];

  //     if (timestamp != null) {
  //       final scheduledTime =
  //           tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, timestamp);
  //       final int hour = scheduledTime.hour;
  //       final int minute = scheduledTime.minute;

  //       await schaduleNotification(
  //         id: notification['id'],
  //         title: "Financial Alert",
  //         body: message,
  //         hour: hour,
  //         minute: minute,
  //       );
  //     }
  //   }
  //   print("Financial notifications fetched");
  // }

  //cancel notification all
  Future<void> cancelAllNotification() async {
    await notificationPlugin.cancelAll();
  }
}
