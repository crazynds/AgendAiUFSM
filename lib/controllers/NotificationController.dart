
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tz;

// class Notification{
//   final int id;
//   final String? title;
//   final String? body;
//   final String? payload;

//   Notification({required this.id,this.title,this.body,this.payload});
// }

// enum ChannelNotification{
//   avisos('avisos',Importance.low,Priority.low),
//   lembrete('lembrete',Importance.high,Priority.high);

//   final String id;
//   final String name;
//   final Importance importance;
//   final Priority priority;

//   const ChannelNotification(String title,Importance imp, Priority prio):id = '${title}_id',name = title,importance = imp,priority = prio;

// }


// class NotificationController{
//   late FlutterLocalNotificationsPlugin localNotificationsPlugin;
//   late AndroidNotificationDetails androidDetails;

//   NotificationController(){
//     localNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     _setupNotifications();
//   }
  
//   _setupNotifications() async{
//     await _initTimezone();
//     await _initNotifications();
//   }
  
//   _initTimezone() async{
//     tz.initializeTimeZones();
//     final String timezoneName = await FlutterNativeTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(timezoneName));
//   }
  
//   _initNotifications() async{
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');

//     await localNotificationsPlugin.initialize(
//       const InitializationSettings(
//         android: android,
//       )
//     );
//   }

//   showNotification(ChannelNotification channel,Notification not){
//     androidDetails = AndroidNotificationDetails(
//       channel.id, 
//       channel.name,
//       priority: channel.priority,
//       importance: channel.importance
//       );
//     localNotificationsPlugin.show(
//       not.id, 
//       not.title, 
//       not.body, 
//       NotificationDetails(android: androidDetails),
//       payload: not.payload
//       );
//   }



// }