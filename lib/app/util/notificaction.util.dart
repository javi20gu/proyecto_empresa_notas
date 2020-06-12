import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';

Future<void> addRecordatorioNota(
    {@required
        int id,
    @required
        String tituloNota,
    @required
        String descripcionNota,
    @required
        DateTime recordatorioNota,
    @required
        FlutterLocalNotificationsPlugin
            flutterLocalNotificationsPlugin}) async {
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0', 'FootNote', 'App de Notas',
      importance: Importance.Max,
      priority: Priority.Max,
      ticker: 'nota',
      visibility: NotificationVisibility.Private,
      styleInformation: BigTextStyleInformation(''));
  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(id, tituloNota,
      descripcionNota, recordatorioNota, platformChannelSpecifics,
      payload: "$id", androidAllowWhileIdle: true);
}
