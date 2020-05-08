
import 'package:proyecto_empresas_notas/app/models/usuario.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferend {
  SharedPreferend._();

  static final SharedPreferend _singleton = SharedPreferend._();

  factory SharedPreferend() => _singleton;

  SharedPreferences sharedPreferences;

  Future<void> initDb() async => sharedPreferences = await SharedPreferences.getInstance();
}

extension NoteSharedPreferences on SharedPreferences {
  UserSignInModel getUsuario() {
    dynamic valor = this.getString("usuario");
    return (valor == null) ? null : UserSignInModel.fromJson(valor);
  }

  Future<bool> setUsuario({
    String uidUsuario,
    String email,
    String nombreCompleto,
    String fotoPerfil,
  }) {
    final String usuarioJson = UserSignInModel(
        uidUsuario: uidUsuario,
        email: email,
        nombreCompleto: nombreCompleto,
        fotoPerfil: fotoPerfil).toJson();
    return this.setString("usuario", usuarioJson);
  }
}
