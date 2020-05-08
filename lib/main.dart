import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_empresas_notas/app/app.dart';
import 'package:proyecto_empresas_notas/app/util/shared_preferend.util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark));
  final SharedPreferend sharedPreferend = SharedPreferend();
  await sharedPreferend.initDb();
  runApp(FootNote());
}
