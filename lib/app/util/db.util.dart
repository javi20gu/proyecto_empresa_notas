import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/nota_db.model.dart';

/// Base de Datos Local
class DBNotas {
  static Database _database;
  static const String dbTableName = 'Notas';
  static final DBNotas db = DBNotas._();

  DBNotas._();

  Future<Database> get database async =>
      (_database != null) ? _database : _database = await _initDB();

  /// Inicializa las base de datos, solo pasará una vez
  Future<Database> _initDB() async {
    final Directory directorioDocumentos =
        await getApplicationDocumentsDirectory();
    final String path = join(directorioDocumentos.path, 'FootNote.db');
    return await openDatabase(path,
        version: 1,
        onOpen: (db) => {},
        onCreate: (db, version) async => await db.execute('CREATE TABLE Notas ('
            ' id_nota INTEGER PRIMARY KEY AUTOINCREMENT,'
            ' id_nota_firebase TEXT NULL,'
            ' titulo_nota VARCHAR(150) NOT NULL,'
            ' descripcion_nota TEXT NOT NULL,'
            ' is_favorite BIT DEFAULT 0,'
            ' fecha_de_recordatorio DATETIME NULL,'
            " fecha_de_modificacion DATE DEFAULT (datetime('now','localtime')),"
            " fecha_de_creacion DATE DEFAULT (datetime('now','localtime'))"
            ')'));
  }

  /// Crea un Registro en la base de datos
  ///
  /// Requiere el parametro de tipo [AddNotaModel] y devuelve un [int]
  Future<int> crearNota(AddNotaModel notaModel) async =>
      (await database).insert(dbTableName, notaModel.toMap());

  /// Obtiene una nota especifica
  ///
  /// Requiere el parametro [idNota] de tipo [int], devuelve [GetNotasModel] y sino hubiera [null]
  Future<GetNotasModel> getNotaById(int idNota) async {
    final nota = (await (await database)
            .query(dbTableName, where: 'id_nota = ?', whereArgs: <int>[idNota]))
        .first;
    return nota.isNotEmpty ? GetNotasModel.fromMap(nota) : null;
  }

  /// Obtiene todas las notas
  ///
  /// Devuelve [List<GetNotasModel>] y sino hubiera [List]
  Future<List<GetNotasModel>> getNotas() async {
    final List<Map<String, dynamic>> notas =
        (await (await database).query(dbTableName));
    return notas.isNotEmpty
        ? notas.map((nota) => GetNotasModel.fromMap(nota)).toList()
        : [];
  }

  /// Actualiza una nota con nuevos datos
  ///
  /// Requiere el parametro [notaModel] de tipo [NotaModel], devuelve un [int]
  Future<int> updateNota(int idNota, EditNotaModel notaModel) async =>
      (await database).update(dbTableName, notaModel.toMap(),
          where: 'id_nota = ?', whereArgs: <int>[idNota]);

  /// Actualiza el campo 'si esta en firebase'
  ///
  /// Requiere el parametro [idNota] de tipo [int] y el [isUploadFirebase] de tipo [bool], devuelve un [int]
  Future<int> updateNotaByIsFirebase(
      {@required int idNota, @required bool isUploadFirebase}) async {
    int isInFirebase = isUploadFirebase ? 1 : 0;
    return (await database).update(
        dbTableName, <String, int>{'is_in_firebase': isInFirebase},
        where: 'id = ?', whereArgs: <int>[idNota]);
  }

  /// Actualiza el campo 'si esta en favoritos'
  ///
  /// Requiere el paramatro [idNota] de tipo [int] y el [isFavorite] de tipo [bool], devuleve un [int]
  updateNotaByIsFavorite(
      {@required int idNota, @required bool isFavorite}) async {
    int favorite = isFavorite ? 1 : 0;
    return (await database).update(
        dbTableName, <String, int>{'is_favorite': favorite},
        where: 'id_nota = ?', whereArgs: <int>[idNota]);
  }

  /// Elimina una Nota
  ///
  /// Requiere el parametro [idNota] de tipo [int], devuleve un [int]
  Future<int> deleteNotaById(int idNota) async => (await database)
      .delete(dbTableName, where: 'id_nota = ?', whereArgs: <int>[idNota]);

  /// Elimina todas las notas existentes
  Future deleteNotas() async => (await database).delete(dbTableName);

  // Actualiza para que aparezca eliminada la fecha de recordar
  Future<int> updateDeleteRecordatorioNota(int idNota,
          {bool update = false, String fechaRecordatorio}) async =>
      (await database).update(dbTableName,
          {'fecha_de_recordatorio': update ? fechaRecordatorio : null},
          where: 'id_nota = ?', whereArgs: [idNota]);

  /// Actualiza el id de la nota guardada en firestore a la base de datos local
  Future updateIdFirebase(
          {@required String idNotaFirebase, @required int idNota}) async =>
      (await database).update(
          dbTableName,
          {
            'id_nota_firebase': idNotaFirebase,
          },
          where: 'id_nota = ?',
          whereArgs: [idNota]);
}
