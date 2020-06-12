import 'package:meta/meta.dart';

/// Modelo - Obtiene las notas de la base de datos local
class GetNotasModel {
  final int idNota;
  final String idNotaFirebase;
  final String tituloNota;
  final String descripcionNota;
  final int isFavorite;
  final String fechaDeRecordatorio;
  final String fechaDeModificacion;
  final String fechaDeCreacion;

  const GetNotasModel({
    @required this.idNota,
    @required this.idNotaFirebase,
    @required this.tituloNota,
    @required this.descripcionNota,
    @required this.isFavorite,
    @required this.fechaDeRecordatorio,
    @required this.fechaDeModificacion,
    @required this.fechaDeCreacion,
  });

  factory GetNotasModel.fromMap(Map<String, dynamic> json) => GetNotasModel(
        idNota: json['id_nota'],
        idNotaFirebase: json['id_nota_firebase'],
        tituloNota: json['titulo_nota'],
        descripcionNota: json['descripcion_nota'],
        isFavorite: json['is_favorite'],
        fechaDeRecordatorio: json['fecha_de_recordatorio'],
        fechaDeModificacion: json['fecha_de_modificacion'],
        fechaDeCreacion: json['fecha_de_creacion'],
      );
}

/// Modelo - Añade notas a la base de datos
class AddNotaModel {
  final String tituloNota;
  final String descripcionNota;
  final String fechaDeRecordatorio;
  final String idNotaFirebase;
  final int isFavorite;

  const AddNotaModel(
      {this.idNotaFirebase,
      @required this.tituloNota,
      @required this.descripcionNota,
      @required this.fechaDeRecordatorio,
      this.isFavorite = 0});

  Map<String, dynamic> toMap() => {
        'id_nota_firebase': idNotaFirebase,
        'titulo_nota': tituloNota,
        'descripcion_nota': descripcionNota,
        'is_favorite': isFavorite,
        'fecha_de_recordatorio': fechaDeRecordatorio,
      };
}

/// Modelo - Edita la nota de firestore
class EditNotaModel {
  final String tituloNota;
  final String descripcionNota;
  final String fechaDeRecordatorio;

  EditNotaModel({
    this.tituloNota,
    this.descripcionNota,
    this.fechaDeRecordatorio,
  });

  Map<String, String> toMap() => {
        'titulo_nota': tituloNota,
        'descripcion_nota': descripcionNota,
        'fecha_de_recordatorio': fechaDeRecordatorio,
        'fecha_de_modificacion': DateTime.now().toString(),
      };
}
