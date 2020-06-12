import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import 'app/app.dart';
import 'app/util/shared_preferend.util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Configuramos las notificaciones, hacemos énfasis en android
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ///Establecemos el icono que se mostrará explicitamente en las notificaciones
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_notification');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);

  ///*********************************************************************
  ///Cambiamos el color del status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark));

  ///*********************************************************************
  /// Inicializamos SharedPreferend
  final SharedPreferend sharedPreferend = SharedPreferend();
  await sharedPreferend.initDb();

  ///*********************************************************************
  /// Hacemos uso de firebase crashlytics
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  ///*********************************************************************

  runApp(FootNote());
}

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

/// Recibe el [payload] de la notificación correspondiente
Future<void> selectNotification(String payload) async {
  if (payload != null) {
    selectNotificationSubject.add(payload);
  }
}
