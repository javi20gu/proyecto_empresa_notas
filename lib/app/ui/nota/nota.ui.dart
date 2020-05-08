import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_empresas_notas/app/models/nota.model.dart';
import 'package:proyecto_empresas_notas/app/models/usuario.model.dart';
import 'package:proyecto_empresas_notas/app/services/notas.service.dart';
import 'package:proyecto_empresas_notas/app/util/shared_preferend.util.dart';

class UiNota extends StatefulWidget {
  @override
  _UiNotaState createState() => _UiNotaState();
}

class _UiNotaState extends State<UiNota> {
  FocusNode _focusNode;

  List _accesoNota;

  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerNota = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controllerNota.dispose();
    _controllerTitulo.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _guardarNota(AccesoNota accesoNota) async {
    final SharedPreferend sharedPreferend = SharedPreferend();
    final UserSignInModel usuario =
        sharedPreferend.sharedPreferences.getUsuario();

    switch (accesoNota) {
      case AccesoNota.Add:
        final notaFirebase = AddNoteFirebase(
            fechaCreacion: DateTime.now().toUtc(),
            nombreCompleto: usuario.nombreCompleto,
            tituloNota: _controllerTitulo.text,
            descripcionNota: _controllerNota.text);
        Provider.of<NoteService>(context, listen: false)
            .addNotas(userSignInModel: usuario, notaFirebase: notaFirebase);
        break;
      case AccesoNota.Edit:
        final EditNoteFirebase editNoteFirebase = EditNoteFirebase(
          tituloNota: _controllerTitulo.text,
          descripcionNota: _controllerNota.text,
        );
        Provider.of<NoteService>(context, listen: false).editNotes(
            idNota: _accesoNota[1],
            editNoteFirebase: editNoteFirebase,
            userSignInModel: usuario);
        break;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _accesoNota = ModalRoute.of(context).settings.arguments;
    if (_accesoNota[0] == AccesoNota.Edit) {
      _controllerTitulo.text = _accesoNota[2]["titulo"];
      _controllerNota.text = _accesoNota[2]["descripcion"];
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.done),
                onPressed: () => _guardarNota(_accesoNota[0]))
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _controllerTitulo,
                      onFieldSubmitted: (String texto) {
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 27),
                      decoration: InputDecoration.collapsed(hintText: "Título"),
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _controllerNota,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        color: Color.fromRGBO(50, 50, 50, 1),
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration.collapsed(
                          hintText: "Nota",
                          hintStyle: TextStyle(color: Colors.black45)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
