import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.model.dart';

class SharedPreferend {
  SharedPreferend._();

  static final SharedPreferend _singleton = SharedPreferend._();

  factory SharedPreferend() => _singleton;

  SharedPreferences sharedPreferences;

  Future<SharedPreferences> initDb() async =>
      sharedPreferences = await SharedPreferences.getInstance();
}

extension NoteSharedPreferences on SharedPreferences {
  UserSignInModel getUsuario() {
    final String valor = this.getString('usuario');
    return (valor == null) ? null : UserSignInModel.fromJson(valor);
  }

  Future<bool> setUsuario({
    @required String uidUsuario,
    @required bool isNewUser,
    @required String email,
    @required String nombreCompleto,
    @required String fotoPerfil,
  }) {
    final String usuarioJson = UserSignInModel(
            uidUsuario: uidUsuario,
            isNewUser: isNewUser,
            email: email,
            nombreCompleto: nombreCompleto,
            fotoPerfil: fotoPerfil)
        .toJson();
    return this.setString('usuario', usuarioJson);
  }
}
