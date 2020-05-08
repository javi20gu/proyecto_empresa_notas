import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_empresas_notas/app/models/nota.model.dart';
import 'package:proyecto_empresas_notas/app/models/usuario.model.dart';
import 'package:proyecto_empresas_notas/app/util/shared_preferend.util.dart';

class NoteService with ChangeNotifier {
  final Firestore _firestore = Firestore.instance;
  List<NotaModel> notas = [];
  List<NotaModel> notasFavoritas = [];
  final _sharedPreferences = SharedPreferend().sharedPreferences;

  bool _isLoanding = true;

  bool get isLoanding => _isLoanding;

  NoteService() {
    initNotes();
  }

  initNotes() async {
    QuerySnapshot datosFirebaseStore = await _firestore
        .collection("users")
        .document(_sharedPreferences.getUsuario().uidUsuario)
        .collection("notas")
        .orderBy("fecha_creacion", descending: true)
        .getDocuments();
    final notasBase = datosFirebaseStore.documents.map((document) =>
      NotaModel.fromMap(document.documentID, document.data)).toList();
    notas = notasBase.where((nota) => nota.favorito == false).toList();
    notasFavoritas = notasBase.where((nota) => nota.favorito == true).toList();
    _isLoanding = false;
    notifyListeners();
  }

  addNotas(
      {@required AddNoteFirebase notaFirebase,
      @required UserSignInModel userSignInModel}) async {
    _isLoanding = true;
    notifyListeners();
    final Map<String, dynamic> notaFirebaseMap = notaFirebase.toMap();
    await _firestore
        .collection('users')
        .document(userSignInModel.uidUsuario)
        .collection('notas')
        .add(notaFirebaseMap);
    await initNotes();
    notifyListeners();
  }

  editFavoriteNote({@required String idNota, @required EditFavoriteNoteFirebase editFavoriteNoteFirebase}) async{
    _isLoanding = true;
    notifyListeners();
    final usuario = _sharedPreferences.getUsuario();
    final favoritoNotaMap = editFavoriteNoteFirebase.toMap();
    await _firestore
        .collection('users')
        .document(usuario.uidUsuario)
        .collection('notas')
        .document(idNota)
        .updateData(favoritoNotaMap);
    await initNotes();
  }

  editNotes(
      {@required String idNota,
      @required EditNoteFirebase editNoteFirebase,
      @required UserSignInModel userSignInModel}) async {
    _isLoanding = true;
    notifyListeners();
    final Map<String, dynamic> notaFirebaseMap = editNoteFirebase.toMap();
    await _firestore
        .collection('users')
        .document(userSignInModel.uidUsuario)
        .collection('notas')
        .document(idNota)
        .updateData(notaFirebaseMap);
    await initNotes();
  }

  deleteNotas({String idNota}) async {
    _isLoanding = true;
    notifyListeners();
    final String uidUsuario = _sharedPreferences.getUsuario().uidUsuario;
    await _firestore
        .collection('users')
        .document(uidUsuario)
        .collection('notas')
        .document(idNota)
        .delete();
    await initNotes();
  }
}
