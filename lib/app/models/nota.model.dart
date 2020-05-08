import 'package:meta/meta.dart';

class NotaModel {
  final String idNota;
  final String tituloNota;
  final String autorNota;
  final bool favorito;
  final String descripcionNota;

  NotaModel({
    @required this.idNota,
    @required this.tituloNota,
    @required this.autorNota,
    @required this.favorito,
    @required this.descripcionNota,
  });

  factory NotaModel.fromMap(String idNota, Map<String, dynamic> json) =>
      NotaModel(
        idNota: idNota,
        tituloNota: json["titulo_nota"],
        autorNota: json["autor_nota"],
        favorito: json["favorito"],
        descripcionNota: json["descripcion_nota"],
      );
}

class AddNoteFirebase {
  final String nombreCompleto;
  final String tituloNota;
  final String descripcionNota;
  final DateTime fechaCreacion;
  final bool favorito;

  const AddNoteFirebase({
    @required this.nombreCompleto,
    @required this.tituloNota,
    @required this.descripcionNota,
    @required this.fechaCreacion,
    this.favorito = false,
  });

  Map<String, dynamic> toMap() => {
        "autor_nota": nombreCompleto,
        "descripcion_nota": descripcionNota,
        "favorito": favorito,
        "titulo_nota": tituloNota,
        "fecha_creacion": fechaCreacion,
      };
}

class EditFavoriteNoteFirebase {
  final bool isFavorito;

  const EditFavoriteNoteFirebase({@required this.isFavorito});

  Map<String, bool> toMap() => {
        "favorito": isFavorito,
  };

}

class EditNoteFirebase {
  final String tituloNota;
  final String descripcionNota;

  const EditNoteFirebase({
    @required this.tituloNota,
    @required this.descripcionNota,
  });

  Map<String, dynamic> toMap() {
    if (tituloNota.isEmpty && descripcionNota.isEmpty)
      return {};
    else if (tituloNota.isNotEmpty && descripcionNota.isEmpty)
      return {"titulo_nota": tituloNota};
    else if (tituloNota.isEmpty && descripcionNota.isNotEmpty)
      return {"descripcion_nota": descripcionNota};
    else if (tituloNota.isNotEmpty && descripcionNota.isNotEmpty)
      return {"titulo_nota": tituloNota, "descripcion_nota": descripcionNota};
    else {
      return {};
    }
  }
}

enum AccesoNota {
  Add,
  Edit,
}
