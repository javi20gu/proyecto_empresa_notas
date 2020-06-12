import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/nota._firebase.model.dart';
import '../routes/routes.dart';
import '../services/notas.service.dart';

class CardWidget extends StatefulWidget {
  final int idNota;
  final String tituloNota;
  final String descripcionNota;
  final bool isFavorite;
  final String fechaModificacion;
  final String fechaDeRecordatorio;

  const CardWidget({
    Key key,
    @required this.idNota,
    @required this.tituloNota,
    @required this.descripcionNota,
    this.isFavorite = false,
    @required this.fechaDeRecordatorio,
    @required this.fechaModificacion,
  }) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool _isExpanded = false;

  String get _fechaModificacion {
    final now = new DateTime.now();
    final DateTime fechaModificacion =
        DateTime.parse(widget.fechaModificacion).toLocal();
    final difference = now.difference(fechaModificacion);
    final List<String> convertirTiempo =
        timeago.format(now.subtract(difference), locale: 'es').split(' ');
    return '${convertirTiempo[0]} ${convertirTiempo[1]} ${convertirTiempo[2][0].toUpperCase()}${convertirTiempo[2].substring(1)}';
  }

  FlutterLocalNotificationsPlugin get _flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.04)),
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 13.5, horizontal: 16),
                child: Text(
                  '${widget.tituloNota[0].toUpperCase()}${widget.tituloNota.substring(1)}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                      fontFamily: 'WorkSans Bold',
                      fontSize: 21,
                      color: Color.fromRGBO(35, 47, 52, 1)),
                )),
            const Divider(
              height: 0,
            ),
            (widget.descripcionNota.length > 100)
                ? ExpansionTile(
                    onExpansionChanged: (bool valor) {
                      setState(() {
                        _isExpanded = valor;
                      });
                    },
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        widget.descripcionNota,
                        overflow: (_isExpanded)
                            ? TextOverflow.clip
                            : TextOverflow.ellipsis,
                        maxLines: (_isExpanded) ? null : 3,
                        style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'WorkSans',
                            color: Color.fromRGBO(35, 47, 52, 1)),
                        textAlign: TextAlign.justify,
                      ),
                    ))
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text(
                      widget.descripcionNota,
                      style: const TextStyle(
                          fontSize: 17,
                          fontFamily: 'WorkSans',
                          color: Color.fromRGBO(35, 47, 52, 1)),
                      textAlign: TextAlign.justify,
                    )),
            const Divider(
              height: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async => await Navigator.of(context)
                            .pushNamedAndRemoveUntil(RoutesNames.NOTA,
                                ModalRoute.withName(RoutesNames.INICIO),
                                arguments: [
                              AccesoNota.edit,
                              {
                                'id_nota': widget.idNota,
                                'titulo': widget.tituloNota,
                                'descripcion': widget.descripcionNota,
                                'fecha_de_recordatorio':
                                    widget.fechaDeRecordatorio,
                              }
                            ]),
                        tooltip: 'Editar Nota',
                        color: Colors.black.withOpacity(0.55),
                      ),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            int valor = 0;
                            await showDialog(
                              context: context,
                              child: AlertDialog(
                                title: Text(
                                  'Borrar nota',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                content: Text(
                                  '¿Estás seguro que quieres eliminar esta nota?',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.7)),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'CANCELAR',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    textColor: Colors.red,
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      valor = 1;
                                    },
                                    child: const Text(
                                      'ELIMINAR',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    textColor: Colors.red,
                                  ),
                                ],
                              ),
                            );
                            if (valor == 1) {
                              await _flutterLocalNotificationsPlugin
                                  .cancel(widget.idNota);
                              await Provider.of<NoteService>(context,
                                      listen: false)
                                  .deleteNota(idNota: widget.idNota);
                            }
                          },
                          tooltip: 'Eliminar Nota',
                          color: Colors.black.withOpacity(0.55)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${_fechaModificacion[0].toUpperCase()}${_fechaModificacion.substring(1)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.25),
                      fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: IconButton(
                      icon: widget.isFavorite
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red[400],
                            )
                          : const Icon(Icons.favorite_border),
                      onPressed: () async {
                        await Provider.of<NoteService>(context, listen: false)
                            .updateIsFavorite(
                          idNota: widget.idNota,
                          favorite: !widget.isFavorite,
                        );
                      },
                      color: Colors.black.withOpacity(0.55)),
                )
              ],
            )
          ],
        ),
      );
}
