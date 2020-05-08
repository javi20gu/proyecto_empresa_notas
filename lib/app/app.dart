import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_empresas_notas/app/routes/routes.dart';
import 'package:proyecto_empresas_notas/app/services/notas.service.dart';
import 'package:proyecto_empresas_notas/app/util/shared_preferend.util.dart';

class FootNote extends StatelessWidget {
  final SharedPreferend sharedPreferences = SharedPreferend();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FootNote',
        theme: ThemeData(
            primaryTextTheme:
                TextTheme(headline6: TextStyle(color: Colors.black87)),
            scaffoldBackgroundColor: Colors.white,
            cursorColor: Colors.redAccent,
            primarySwatch: Colors.red,
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(color: Colors.black87),
              elevation: 0,
              brightness: Brightness.dark,
              color: Colors.white,
            )),
        routes: routes,
        initialRoute: initialRoute,
      ),
    );
  }

  get initialRoute => sharedPreferences.sharedPreferences.getUsuario() != null
      ? "inicio"
      : "presentacion";
}
