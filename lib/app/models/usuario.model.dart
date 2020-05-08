import 'dart:convert';

import 'package:meta/meta.dart';

class UserSignInModel {
  final String uidUsuario;
  final String nombreCompleto;
  final String email;
  final String fotoPerfil;

  const UserSignInModel({
    @required this.uidUsuario,
    @required this.nombreCompleto,
    @required this.email,
    @required this.fotoPerfil,
  });

  factory UserSignInModel.fromJson(String str) =>
      UserSignInModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserSignInModel.fromMap(Map<String, dynamic> json) => UserSignInModel(
        uidUsuario: json["uidUsuario"],
        nombreCompleto: json["nombre_completo"],
        email: json["email"],
        fotoPerfil: json["foto_perfil"],
      );

  Map<String, dynamic> toMap() => {
        "uidUsuario": uidUsuario,
        "nombre_completo": nombreCompleto,
        "email": email,
        "foto_perfil": fotoPerfil,
      };
}

enum UserSignIn {
  sign_out,
}
