import 'package:after_layout/after_layout.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/nota._firebase.model.dart';
import '../../models/nota_db.model.dart';
import '../../services/check_form.service.dart';
import '../../services/notas.service.dart';
import '../../util/db.util.dart';
import '../../util/ids_tutorial.util.dart';
import '../../util/notificaction.util.dart';
import '../../util/shared_preferend.util.dart';

class UiNota extends StatefulWidget {
  @override
  _UiNotaState createState() => _UiNotaState();
}

class _UiNotaState extends State<UiNota> with AfterLayoutMixin {
  FocusNode _focusNode;

  DateTime _recordatorio;
  List _accesoNota;
  final SharedPreferences _sharedPreferend =
      SharedPreferend().sharedPreferences;

  final TextEditingController _controllerTitulo = TextEditingController();
  final TextEditingController _controllerNota = TextEditingController();

  FlutterLocalNotificationsPlugin get _flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    CheckForm serviceCheckNote = Provider.of<CheckForm>(context, listen: false);
    _controllerNota.addListener(() {
      serviceCheckNote.descripcion = _controllerNota.text;
      serviceCheckNote.checkActivated;
    });
    _controllerTitulo.addListener(() {
      serviceCheckNote.titulo = _controllerTitulo.text;
      serviceCheckNote.checkActivated;
    });
    _focusNode = FocusNode();
    if (_sharedPreferend.getUsuario().isNewUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FeatureDiscovery.discoverFeatures(
          context,
          <String>{
            IdsTutorial.icon_guardar_nota.toString(),
          },
        );
      });
      _sharedPreferend.setUsuario(
          isNewUser: false,
          email: _sharedPreferend.getUsuario().email,
          fotoPerfil: _sharedPreferend.getUsuario().fotoPerfil,
          nombreCompleto: _sharedPreferend.getUsuario().nombreCompleto,
          uidUsuario: _sharedPreferend.getUsuario().uidUsuario);
    }
  }

  @override
  void dispose() {
    _controllerNota.dispose();
    _controllerTitulo.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _guardarNota(AccesoNota accesoNota) async {
    final String tituloNota = _controllerTitulo.text;
    final String descripcionNota = _controllerNota.text;
    switch (accesoNota) {
      case AccesoNota.add:
        final AddNotaModel notaModal = AddNotaModel(
          tituloNota: tituloNota,
          descripcionNota: descripcionNota,
          fechaDeRecordatorio: _recordatorio?.toString(),
        );
        Provider.of<NoteService>(context, listen: false).addNotas(
            notaModel: notaModal,
            tituloNotaActual: tituloNota,
            descripcionNotaActual: descripcionNota,
            recordatorio: _recordatorio);
        break;
      case AccesoNota.edit:
        if (_accesoNota[1]['titulo'] == tituloNota &&
            _accesoNota[1]['descripcion'] == descripcionNota) {
          if (_recordatorio != null) {
            await DBNotas.db
                .updateDeleteRecordatorioNota(_accesoNota[1]['id_nota']);
            await _flutterLocalNotificationsPlugin
                .cancel(_accesoNota[1]['id_nota']);
            addRecordatorioNota(
              id: _accesoNota[1]['id_nota'],
              tituloNota: tituloNota,
              descripcionNota: descripcionNota,
              recordatorioNota: _recordatorio,
              flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
            );
            await Provider.of<NoteService>(context, listen: false)
                .updateDeleteRecordatorioNota(
                    idNota: _accesoNota[1]['id_nota'],
                    fechaRecordatorio: _recordatorio.toString(),
                    update: true);
            return Navigator.of(context).pop();
          }
        }
        final EditNotaModel editNoteFirebase = EditNotaModel(
          tituloNota: tituloNota,
          descripcionNota: descripcionNota,
          fechaDeRecordatorio: _recordatorio.toString(),
        );
        Provider.of<NoteService>(context, listen: false).updateNoteById(
            idNota: _accesoNota[1]['id_nota'],
            editNote: editNoteFirebase,
            recordatorio: _recordatorio);
        break;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                _buildAppBar(_accesoNota),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18.0, horizontal: 20),
                        child: _buildFormulario(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  SliverAppBar _buildAppBar(List _accesoNota) => SliverAppBar(
        actions: <Widget>[
          DescribedFeatureOverlay(
            featureId: IdsTutorial.icon_guardar_nota.toString(),
            title: const Text('Guardar Nota'),
            description: _describedFeatureGuardarNota(context),
            tapTarget: const Icon(Icons.done),
            child: IconButton(
              icon: const Icon(Icons.done),
              onPressed:
                  (Provider.of<CheckForm>(context, listen: false).isActived)
                      ? () => _guardarNota(_accesoNota[0])
                      : null,
            ),
          )
        ],
      );

  Column _describedFeatureGuardarNota(BuildContext context) => Column(
        children: <Widget>[
          const Text('Aquí podrás guardar la nota,'
              ' una vez que termines de completar,'
              ' tanto el título, como la nota,'
              ' ambos obligatorios.'),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
          Row(
            children: <Widget>[
              OutlineButton(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                onPressed: () => FeatureDiscovery.completeCurrentStep(context),
                child: Text('CERRAR',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white)),
              ),
            ],
          ),
        ],
      );

  Widget _buildFormulario(BuildContext context) {
    _accesoNota = ModalRoute.of(context).settings.arguments;
    final serviceCheckForm = Provider.of<CheckForm>(context);
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.sentences,
            controller: _controllerTitulo,
            onFieldSubmitted: (String texto) {
              FocusScope.of(context).requestFocus(_focusNode);
            },
            textInputAction: TextInputAction.next,
            style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 27),
            decoration: const InputDecoration.collapsed(hintText: 'Título'),
          ),
          TextFormField(
            textCapitalization: TextCapitalization.sentences,
            controller: _controllerNota,
            focusNode: _focusNode,
            autofocus: true,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              color: Color.fromRGBO(50, 50, 50, 1),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
            decoration: const InputDecoration.collapsed(
                hintText: 'Nota', hintStyle: TextStyle(color: Colors.black45)),
          ),
          if ((!serviceCheckForm.isActived && !serviceCheckForm.recorder) ||
              serviceCheckForm.isActived && !serviceCheckForm.recorder)
            Builder(
              builder: (BuildContext context1) => ActionChip(
                tooltip: 'Recordartorio de Nota',
                avatar: const Icon(
                  Icons.add_alarm,
                  size: 22,
                  color: Colors.white,
                ),
                backgroundColor: Colors.redAccent,
                label: const Text(
                  'Añadir Recordatorio',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => _addRecorder(context1),
              ),
            ),
          if (serviceCheckForm.recorder)
            Chip(
              label: Text(
                  '${_recordatorio.hour}:${_recordatorio.minute} ${_recordatorio.day}-${_recordatorio.month}-${_recordatorio.year}'),
              deleteIcon: Icon(
                Icons.cancel,
                color: Colors.black.withOpacity(0.75),
              ),
              onDeleted: () async {
                Provider.of<CheckForm>(context, listen: false).recorder = false;
                _recordatorio = null;
                if (_accesoNota[0] == AccesoNota.edit) {
                  await _flutterLocalNotificationsPlugin
                      .cancel(_accesoNota[1]['id_nota']);
                  Provider.of<NoteService>(context, listen: false)
                      .updateDeleteRecordatorioNota(
                          idNota: _accesoNota[1]['id_nota']);
                }
              },
            )
        ],
      ),
    );
  }

  Future<void> _addRecorder(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 1));
    if (date == null) {
      return;
    }
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) {
      Scaffold.of(context).showSnackBar(
          const SnackBar(content: Text('Se ha cancelado el recordatorio.')));
      return;
    }
    _recordatorio =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    Provider.of<CheckForm>(context, listen: false).recorder = true;
    Scaffold.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio creado correctamente.')));
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    _accesoNota = ModalRoute.of(context).settings.arguments;
    final serviceProvider = Provider.of<CheckForm>(context, listen: false);
    serviceProvider.recorder = false;
    serviceProvider.isActived = false;

    if (_accesoNota[0] == AccesoNota.edit) {
      final String recorderOtraVista =
          _accesoNota[1]['fecha_de_recordatorio'] ?? null;

      _controllerTitulo.text = _accesoNota[1]['titulo'];
      _controllerNota.text = _accesoNota[1]['descripcion'];
      FocusScope.of(context).requestFocus(FocusNode());
      // Comprobar si hay Notificaciones
      var notificacionesPendientes =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

      notificacionesPendientes = notificacionesPendientes
          .where((element) => element.payload == '${_accesoNota[1]['id_nota']}')
          .toList();

      if (recorderOtraVista == null) {
        serviceProvider.recorder = false;
      } else {
        if (notificacionesPendientes.isEmpty) {
          await Provider.of<NoteService>(context, listen: false)
              .updateDeleteRecordatorioNota(idNota: _accesoNota[1]['id_nota']);
          serviceProvider.recorder = false;
        } else {
          serviceProvider.recorder = true;
          _recordatorio = DateTime.parse(recorderOtraVista);
        }
      }
    }
  }
}
