import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

import '../ui/nota/nota.ui.dart';
import '../ui/presentacion.ui.dart';
import '../ui/principal.ui.dart';

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  'presentacion': (_) => UiPresentation(),
  'inicio': (_) => FeatureDiscovery(child: UiPrincipal()),
  'nota': (_) => FeatureDiscovery(child: UiNota()),
};

class RoutesNames {
  static const String PRESENTACION = "presentacion";
  static const String INICIO = "inicio";
  static const String NOTA = "nota";

  const RoutesNames();
}
