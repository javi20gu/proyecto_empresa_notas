import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/routes.dart';
import 'services/check_form.service.dart';
import 'services/notas.service.dart';
import 'util/shared_preferend.util.dart';

class FootNote extends StatelessWidget {
  /// Creamos una instancia de SharedPreferend
  final SharedPreferend _sharedPreferences = SharedPreferend();

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NoteService()),
          ChangeNotifierProvider(create: (_) => CheckForm())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FootNote',
          theme: _buildThemeData,
          routes: routes,
          initialRoute: _initialRoute,
        ),
      );

  static ThemeData get _buildThemeData => ThemeData(
      primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.black87)),
      scaffoldBackgroundColor: Colors.white,
      cursorColor: Colors.redAccent,
      primarySwatch: Colors.red,
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0,
        brightness: Brightness.dark,
        color: Colors.white,
      ));

  /// Comprobamos si contiene datos del usuario registrado, para mandarle una ruta o a otra.
  String get _initialRoute =>
      _sharedPreferences.sharedPreferences.getUsuario() != null
          ? RoutesNames.INICIO
          : RoutesNames.PRESENTACION;
}
