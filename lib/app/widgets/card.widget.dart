import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_empresas_notas/app/models/nota.model.dart';

import 'package:proyecto_empresas_notas/app/services/notas.service.dart';

class CardWidget extends StatefulWidget {
  final String idNota;
  final String nombreAutor;
  final String tituloNota;
  final String descripcionNota;
  bool isFavorite;

  CardWidget(
      {Key key,
      this.idNota,
      this.nombreAutor,
      this.tituloNota,
      this.descripcionNota,
      this.isFavorite = false})
      : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.05)),
            borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.nombreAutor.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "WorkSans",
                        color: Color.fromRGBO(35, 47, 52, 1),
                      ),
                    ),
                    IconButton(
                        color: Colors.red[600],
                        icon: widget.isFavorite
                            ? Icon(Icons.star)
                            : Icon(Icons.star_border),
                        onPressed: ()=>
                          Provider.of<NoteService>(context, listen: false).editFavoriteNote(idNota: widget.idNota, editFavoriteNoteFirebase: EditFavoriteNoteFirebase(isFavorito: !widget.isFavorite)),
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  widget.tituloNota,
                  style: TextStyle(
                      fontFamily: "WorkSans Bold",
                      fontSize: 21,
                      color: Color.fromRGBO(35, 47, 52, 1)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12),
                child: Text(
                  widget.descripcionNota,
                  style: TextStyle(
                      fontSize: 17,
                      fontFamily: "WorkSans",
                      color: Color.fromRGBO(35, 47, 52, 1)),
                  textAlign: TextAlign.justify,
                ),
              ),
              Row(
                children: <Widget>[
                  FlatButton(
                    splashColor: Color.fromRGBO(255, 170, 170, 1),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            "nota", ModalRoute.withName("inicio"),
                            arguments: [
                          AccesoNota.Edit,
                          widget.idNota,
                          {
                            "titulo": widget.tituloNota,
                            "descripcion": widget.descripcionNota
                          }
                        ]),
                    child: Text(
                      "EDITAR",
                      style: TextStyle(fontSize: 19, color: Colors.red),
                    ),
                  ),
                  FlatButton(
                    splashColor: Colors.redAccent[100],
                    onPressed: () {
                      Provider.of<NoteService>(context, listen: false)
                          .deleteNotas(idNota: widget.idNota);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "BORRAR",
                      style: TextStyle(fontSize: 19, color: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
}
