import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../models/nota._firebase.model.dart';
import 'shared_preferend.util.dart';

class DBFirebaseNota {
  static final Firestore _firestore = Firestore.instance;
  static final String _uidUsuario =
      SharedPreferend().sharedPreferences.getUsuario().uidUsuario;

  static CollectionReference get _getCollectionNotas =>
      _firestore.collection('users').document(_uidUsuario).collection('notas');

  static Future<GetNotaModelFirebase> getNotabyId(String idNotaFirebase) async {
    final nota = await _getCollectionNotas.document(idNotaFirebase).get();
    if (nota.data != null) {
      return GetNotaModelFirebase.fromMapWithId(
        idNotaFirebase: idNotaFirebase,
        json: nota.data,
      );
    }
    return null;
  }

  static Future<List<GetNotaModelFirebase>> getNotas() async {
    final QuerySnapshot datosFirebaseStore = await _getCollectionNotas
        .orderBy('fecha_de_modificacion', descending: true)
        .getDocuments();
    return datosFirebaseStore.documents
        .map((document) => GetNotaModelFirebase.fromMapWithId(
            idNotaFirebase: document.documentID, json: document.data))
        .toList();
  }

  static Future<DocumentReference> addNotas(
          {@required AddNotaModelFirebase notaFirebase}) async =>
      await _getCollectionNotas.add(notaFirebase.toMap());

  static Future<void> editNotaFavoriteById(
          {@required String idNota,
          @required EditFavoriteNoteFirebase editFavoriteNoteFirebase}) async =>
      await _getCollectionNotas
          .document(idNota)
          .updateData(editFavoriteNoteFirebase.toMap());

  static Future<void> editRecordatorioNota(
          {@required String idNota, @required String recordatorio}) async =>
      await _getCollectionNotas
          .document(idNota)
          .updateData({'fecha_de_recordatorio': recordatorio});

  static Future<void> editNota(
          {@required String idNota,
          @required EditNoteFirebase editNoteFirebase}) async =>
      await _getCollectionNotas
          .document(idNota)
          .updateData(editNoteFirebase.toMap());

  static Future<void> deleteNotaById({String idNota}) async =>
      await _getCollectionNotas.document(idNota).delete();
}
