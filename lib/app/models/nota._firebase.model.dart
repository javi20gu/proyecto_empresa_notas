import 'package:meta/meta.dart';

/// Modelo - Obtiene una nota de firestore
class GetNotaModelFirebase {
  final int idNota;
  final String idNotaFirebase;
  final String autorNota;
  final String tituloNota;
  final String descripcionNota;
  final int isFavorito;
  final String fechaModificacion;
  final String fechaCreacion;
  final String fechaDeRecordatorio;

  GetNotaModelFirebase({
    this.idNota,
    this.autorNota,
    this.idNotaFirebase,
    @required this.tituloNota,
    @required this.descripcionNota,
    this.isFavorito = 0,
    this.fechaModificacion,
    this.fechaCreacion,
    this.fechaDeRecordatorio,
  });

  Map<String, dynamic> toMap() => {
        'titulo_nota': tituloNota,
        'descripcion_nota': descripcionNota,
        'is_favorite': isFavorito == 1 ? true : false,
        'fecha_de_modificacion': fechaModificacion,
        'fecha_de_creacion': fechaCreacion,
      };

  factory GetNotaModelFirebase.fromMapWithId(
          {String idNotaFirebase, Map<String, dynamic> json}) =>
      GetNotaModelFirebase(
        idNota: json['id_nota'],
        idNotaFirebase: idNotaFirebase,
        autorNota: json['autor_nota'],
        tituloNota: json['titulo_nota'],
        descripcionNota: json['descripcion_nota'],
        isFavorito: json['is_favorite'] ? 1 : 0,
        fechaModificacion: json['fecha_de_modificacion'],
        fechaCreacion: json['fecha_de_creacion'],
        fechaDeRecordatorio: json['fecha_de_recordatorio'],
      );
}

/// Modelo - Añade una nota a firestore
class AddNotaModelFirebase {
  final String autorNota;
  final int idNota;
  final String tituloNota;
  final String descripcionNota;
  final int favorito;
  final String fechaDeCreacion;
  final String fechaDeModificacion;
  final String fechaDeRecordatorio;

  const AddNotaModelFirebase({
    @required this.idNota,
    @required this.autorNota,
    @required this.tituloNota,
    @required this.descripcionNota,
    this.favorito = 0,
    @required this.fechaDeCreacion,
    @required this.fechaDeModificacion,
    @required this.fechaDeRecordatorio,
  });

  Map<String, dynamic> toMap() => {
        'id_nota': idNota,
        'titulo_nota': tituloNota,
        'autor_nota': autorNota,
        'descripcion_nota': descripcionNota,
        'is_favorite': favorito == 1 ? true : false,
        'fecha_de_creacion': fechaDeCreacion,
        'fecha_de_modificacion': fechaDeModificacion,
        'fecha_de_recordatorio': fechaDeRecordatorio,
      };
}

/// Modelo - Edita una nota a favborita o no, de firestore
class EditFavoriteNoteFirebase {
  final int isFavorito;

  const EditFavoriteNoteFirebase({@required this.isFavorito});

  Map<String, bool> toMap() => {
        'is_favorite': isFavorito == 1 ? true : false,
      };
}

/// Modelo - Edita una nota de firestore
class EditNoteFirebase {
  final String tituloNota;
  final String descripcionNota;
  final String fechaRecordatorio;

  const EditNoteFirebase({
    @required this.tituloNota,
    @required this.descripcionNota,
    @required this.fechaRecordatorio,
  });

  Map<String, dynamic> toMap() =>
      {'titulo_nota': tituloNota, 'descripcion_nota': descripcionNota};
}

enum AccesoNota {
  add,
  edit,
}
