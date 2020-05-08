import 'package:flutter/material.dart';
import 'package:proyecto_empresas_notas/app/ui/nota/nota.ui.dart';
import 'package:proyecto_empresas_notas/app/ui/presentacion.ui.dart';
import 'package:proyecto_empresas_notas/app/ui/principal.ui.dart';



Map<String, WidgetBuilder> routes = {
  'presentacion': (_) => UiPresentation(),
  'inicio': (_) => UiPrincipal(),
  'nota': (_) => UiNota(),
};