import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:proyecto_empresas_notas/app/util/notificaction.util.dart';

import '../models/nota._firebase.model.dart';
import '../models/nota_db.model.dart';
import '../util/db.util.dart';
import '../util/db_firebase.util.dart';
import '../util/enum_radio_list_tile.util.dart';
import '../util/notificaction.util.dart';
import '../util/shared_preferend.util.dart';

class NoteService with ChangeNotifier {
  List<GetNotasModel> notas = [];

  bool isFavoriteCheckBox = false;

  FlutterLocalNotificationsPlugin get _flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  Future<void> setIsFavoriteCheckBox(bool check) async {
    isFavoriteCheckBox = check;
    await _initNotes();
  }

  bool isFavorite = false;

  FiltroOrdenar filtroOrdenar = FiltroOrdenar.descendente;

  setfiltroOrdenar(FiltroOrdenar filtroOrdenarP) async {
    filtroOrdenar = filtroOrdenarP;
    await _initNotes();
  }

  bool _isLoanding = true;

  bool get isLoanding => _isLoanding;

  NoteService() {
    _initNotes();
  }

  Future _initNotes() async {
    List<GetNotasModel> baseNotas = await DBNotas.db.getNotas();

    if (isFavoriteCheckBox) {
      baseNotas = baseNotas.where((nota) => nota.isFavorite == 1).toList();
    }

    if (filtroOrdenar == FiltroOrdenar.descendente) {
      baseNotas.sort((a, b) => DateTime.parse(b.fechaDeModificacion)
          .compareTo(DateTime.parse(a.fechaDeModificacion)));
    } else {
      baseNotas.sort((a, b) => DateTime.parse(a.fechaDeModificacion)
          .compareTo(DateTime.parse(b.fechaDeModificacion)));
    }

    notas = baseNotas;
    _isLoanding = false;
    notifyListeners();
  }

  Future getNotasBackup() async {
    _isLoanding = true;
    notifyListeners();
    final listaNotasFirebase = await DBFirebaseNota.getNotas();
    final db = await DBNotas.db.database;
    final batch = db.batch();
    listaNotasFirebase.forEach((notaFirebase) {
      batch.insert(
          DBNotas.dbTableName,
          AddNotaModel(
            idNotaFirebase: notaFirebase.idNotaFirebase,
            tituloNota: notaFirebase.tituloNota,
            descripcionNota: notaFirebase.descripcionNota,
            isFavorite: notaFirebase.isFavorito,
            fechaDeRecordatorio: notaFirebase.fechaDeRecordatorio,
          ).toMap());
    });
    batch.commit(noResult: true);
    await _initNotes();
  }

  addNotas(
      {@required AddNotaModel notaModel,
      @required String tituloNotaActual,
      @required String descripcionNotaActual,
      @required DateTime recordatorio}) async {
    _isLoanding = true;
    notifyListeners();
    final int id = await DBNotas.db.crearNota(notaModel);
    final checkConexion = await Connectivity().checkConnectivity();
    if (checkConexion == ConnectivityResult.wifi ||
        checkConexion == ConnectivityResult.mobile) {
      final autorNota =
          SharedPreferend().sharedPreferences.getUsuario().nombreCompleto;
      final datosBdLocal = await DBNotas.db.getNotaById(id);
      final idFirebase = await DBFirebaseNota.addNotas(
          notaFirebase: AddNotaModelFirebase(
        idNota: id,
        autorNota: autorNota,
        tituloNota: tituloNotaActual,
        descripcionNota: descripcionNotaActual,
        fechaDeCreacion: datosBdLocal.fechaDeCreacion,
        fechaDeModificacion: datosBdLocal.fechaDeModificacion,
        fechaDeRecordatorio: recordatorio.toString(),
      ));
      DBNotas.db
          .updateIdFirebase(idNotaFirebase: idFirebase.documentID, idNota: id);
    }

    if (recordatorio != null) {
      await addRecordatorioNota(
        id: id,
        tituloNota: tituloNotaActual,
        descripcionNota: descripcionNotaActual,
        recordatorioNota: recordatorio,
        flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      );
    }

    await _initNotes();
    notifyListeners();
  }

  updateNoteById(
      {@required int idNota,
      @required DateTime recordatorio,
      @required EditNotaModel editNote}) async {
    _isLoanding = true;
    notifyListeners();
    await DBNotas.db.updateNota(idNota, editNote);
    final checkConexion = await Connectivity().checkConnectivity();

    if (checkConexion == ConnectivityResult.wifi ||
        checkConexion == ConnectivityResult.mobile) {
      final nota = await DBNotas.db.getNotaById(idNota);
      if (await DBFirebaseNota.getNotabyId(nota.idNotaFirebase) == null) {
        final autorNota =
            SharedPreferend().sharedPreferences.getUsuario().nombreCompleto;

        final notaFirebase = await DBFirebaseNota.addNotas(
            notaFirebase: AddNotaModelFirebase(
          idNota: idNota,
          autorNota: autorNota,
          tituloNota: editNote.tituloNota,
          descripcionNota: editNote.descripcionNota,
          fechaDeRecordatorio: editNote.fechaDeRecordatorio,
          fechaDeCreacion: nota.fechaDeCreacion,
          fechaDeModificacion: nota.fechaDeModificacion,
        ));
        DBNotas.db.updateIdFirebase(
            idNotaFirebase: notaFirebase.documentID, idNota: idNota);
      } else {
        DBFirebaseNota.editNota(
            idNota: nota.idNotaFirebase,
            editNoteFirebase: EditNoteFirebase(
                tituloNota: editNote.tituloNota,
                descripcionNota: editNote.descripcionNota,
                fechaRecordatorio: recordatorio.toString()));
      }
    }
    if (recordatorio != null) {
      await _flutterLocalNotificationsPlugin.cancel(idNota);
      await addRecordatorioNota(
        id: idNota,
        tituloNota: editNote.tituloNota,
        descripcionNota: editNote.descripcionNota,
        recordatorioNota: recordatorio,
        flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      );
    }
    await _initNotes();
  }

  updateIsFavorite({@required int idNota, @required bool favorite}) async {
    _isLoanding = true;
    notifyListeners();
    await DBNotas.db
        .updateNotaByIsFavorite(idNota: idNota, isFavorite: favorite);
    final checkConexion = await Connectivity().checkConnectivity();
    if (checkConexion == ConnectivityResult.wifi ||
        checkConexion == ConnectivityResult.mobile) {
      final nota = await DBNotas.db.getNotaById(idNota);
      if (await DBFirebaseNota.getNotabyId(nota.idNotaFirebase) == null) {
        final autorNota =
            SharedPreferend().sharedPreferences.getUsuario().nombreCompleto;

        final notaFirebase = await DBFirebaseNota.addNotas(
            notaFirebase: AddNotaModelFirebase(
          idNota: idNota,
          autorNota: autorNota,
          tituloNota: nota.tituloNota,
          descripcionNota: nota.descripcionNota,
          fechaDeRecordatorio: nota.fechaDeRecordatorio,
          fechaDeCreacion: nota.fechaDeCreacion,
          fechaDeModificacion: nota.fechaDeModificacion,
          favorito: favorite ? 1 : 0,
        ));
        DBNotas.db.updateIdFirebase(
            idNotaFirebase: notaFirebase.documentID, idNota: idNota);
      } else {
        DBFirebaseNota.editNotaFavoriteById(
            idNota: nota.idNotaFirebase,
            editFavoriteNoteFirebase: EditFavoriteNoteFirebase(
              isFavorito: favorite ? 1 : 0,
            ));
      }
    }
    await _initNotes();
  }

  updateDeleteRecordatorioNota(
      {@required int idNota,
      bool update = false,
      String fechaRecordatorio}) async {
    _isLoanding = true;
    notifyListeners();
    await DBNotas.db.updateDeleteRecordatorioNota(idNota,
        update: update, fechaRecordatorio: fechaRecordatorio);
    final checkConexion = await Connectivity().checkConnectivity();
    if (checkConexion == ConnectivityResult.wifi ||
        checkConexion == ConnectivityResult.mobile) {
      final nota = await DBNotas.db.getNotaById(idNota);
      DBFirebaseNota.editRecordatorioNota(
          idNota: nota.idNotaFirebase, recordatorio: fechaRecordatorio);
    }
    await _initNotes();
  }

  deleteNota({String idNotaFirebase, @required int idNota}) async {
    _isLoanding = true;
    notifyListeners();
    final nota = await DBNotas.db.getNotaById(idNota);
    await DBNotas.db.deleteNotaById(idNota);
    final checkConexion = await Connectivity().checkConnectivity();
    if (checkConexion == ConnectivityResult.wifi ||
        checkConexion == ConnectivityResult.mobile) {
      DBFirebaseNota.deleteNotaById(idNota: nota.idNotaFirebase);
    }
    await _initNotes();
  }
}
