import 'package:flutter/material.dart';

/// Servicio - Comprueba si se va mostrar el recordatorio o no
class CheckForm extends ChangeNotifier {
  bool isActived = false;
  String titulo = '';
  String descripcion = '';

  bool _recorder = false;
  set recorder(bool recorder) {
    _recorder = recorder;
    notifyListeners();
  }

  get recorder => _recorder;
  void get checkActivated {
    if (titulo.isNotEmpty && descripcion.isNotEmpty) {
      isActived = true;
      notifyListeners();
    } else {
      isActived = false;
      notifyListeners();
    }
  }
}
