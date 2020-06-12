import 'package:after_layout/after_layout.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart' show selectNotificationSubject;
import '../models/nota._firebase.model.dart';
import '../models/nota_db.model.dart';
import '../models/usuario.model.dart';
import '../routes/routes.dart';
import '../services/notas.service.dart';
import '../util/db.util.dart';
import '../util/enum_radio_list_tile.util.dart';
import '../util/ids_tutorial.util.dart';
import '../util/shared_preferend.util.dart';
import '../widgets/card.widget.dart';

class UiPrincipal extends StatefulWidget {
  @override
  _UiPrincipalState createState() => _UiPrincipalState();
}

class _UiPrincipalState extends State<UiPrincipal>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final SharedPreferences _sharedPreferend =
      SharedPreferend().sharedPreferences;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    "email",
    "profile",
  ]);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    selectNotificationSubject.stream.listen((String payload) async {
      final nota = await DBNotas.db.getNotaById(int.parse(payload));
      await Navigator.pushNamed(context, RoutesNames.NOTA, arguments: [
        AccesoNota.edit,
        {
          'id_nota': int.parse(payload),
          'titulo': nota.tituloNota,
          'descripcion': nota.descripcionNota,
          'fecha_de_recordatorio': nota.fechaDeRecordatorio,
        }
      ]);
    });
    if (_sharedPreferend.getUsuario().isNewUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FeatureDiscovery.discoverFeatures(
          context,
          <String>{
            IdsTutorial.floating_action_button.toString(),
            IdsTutorial.icon_filtro.toString(),
            IdsTutorial.icon_perfil.toString(),
          },
        );
      });
    }
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  DescribedFeatureOverlay _buildFloatingActionButton(BuildContext context) =>
      DescribedFeatureOverlay(
        featureId: IdsTutorial.floating_action_button.toString(),
        title: const Text('Añadir Notas'),
        description: _describedFeatureOverlayFloatingButton(context),
        overflowMode: OverflowMode.extendBackground,
        tapTarget: const Icon(Icons.add),
        child: FloatingActionButton(
          tooltip: "Añadir Nota",
          onPressed: () async => await Navigator.of(context)
              .pushNamed(RoutesNames.NOTA, arguments: [AccesoNota.add]),
          child: const Icon(Icons.add),
        ),
      );

  Column _describedFeatureOverlayFloatingButton(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Aquí podrás añadir tus propias notas.'),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
          Row(
            children: <Widget>[
              OutlineButton(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                onPressed: () => FeatureDiscovery.completeCurrentStep(context),
                child: Text('SIGUIENTE',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white)),
              ),
              FlatButton(
                onPressed: () => FeatureDiscovery.dismissAll(context),
                child: Text('SALTAR TUTORIAL',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white)),
              )
            ],
          )
        ],
      );

  Widget _buildBody(BuildContext context) {
    final bool isLoanding = Provider.of<NoteService>(context).isLoanding;
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            leading: DescribedFeatureOverlay(
              featureId: IdsTutorial.icon_filtro.toString(),
              title: const Text('Filtra tus Notas'),
              tapTarget: const Icon(Icons.filter_list),
              description: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                      'Podrás filtrar e ordenar tus notas, según tu necesidad.'),
                  Row(
                    children: <Widget>[
                      OutlineButton(
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.5)),
                        onPressed: () =>
                            FeatureDiscovery.completeCurrentStep(context),
                        child: Text('SIGUIENTE',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white)),
                      ),
                      FlatButton(
                        onPressed: () => FeatureDiscovery.dismissAll(context),
                        child: Text('SALTAR TUTORIAL',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white)),
                      )
                    ],
                  )
                ],
              ),
              child: _popupMenuButtonFiltros,
            ),
            floating: true,
            centerTitle: true,
            title: Text(
              'FootNote',
              style: TextStyle(color: Colors.black.withOpacity(0.80)),
            ),
            actions: <Widget>[
              FutureBuilder(
                  future: _buildPopupMenuButton(context),
                  builder: (_, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.hasData) {
                      return asyncSnapshot.data;
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
              const SizedBox(
                width: 6,
              )
            ],
          ),
          !isLoanding
              ? _buildPagina(context)
              : const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
        ],
      ),
    );
  }

  PopupMenuButton<int> get _popupMenuButtonFiltros {
    final NoteService filtrosNotasService = Provider.of<NoteService>(context);
    return PopupMenuButton<int>(
      child: const Icon(Icons.filter_list),
      tooltip: 'Filtro',
      itemBuilder: (BuildContext _) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 2,
          height: 0,
          child: StatefulBuilder(
            builder: (BuildContext context, setStateParent) => ExpansionTile(
              title: const Text('Organizar Notas'),
              children: <Widget>[
                const PopupMenuDivider(),
                RadioListTile<FiltroOrdenar>(
                  value: FiltroOrdenar.descendente,
                  groupValue: filtrosNotasService.filtroOrdenar,
                  onChanged: (FiltroOrdenar nuevoValor) async {
                    setStateParent(() {});
                    await filtrosNotasService.setfiltroOrdenar(nuevoValor);
                  },
                  title: const Text('Descendente'),
                ),
                RadioListTile<FiltroOrdenar>(
                  value: FiltroOrdenar.ascendente,
                  groupValue: filtrosNotasService.filtroOrdenar,
                  onChanged: (FiltroOrdenar nuevoValor) async {
                    setStateParent(() {});
                    await filtrosNotasService.setfiltroOrdenar(nuevoValor);
                  },
                  title: const Text('Ascendiente'),
                )
              ],
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: StatefulBuilder(
            builder: (BuildContext context, setStateParent) => ExpansionTile(
              title: const Text('Filtrar Notas'),
              children: <Widget>[
                const PopupMenuDivider(),
                CheckboxListTile(
                  value: filtrosNotasService.isFavoriteCheckBox,
                  onChanged: (bool nuevoValor) async {
                    setStateParent(() {});
                    await filtrosNotasService.setIsFavoriteCheckBox(nuevoValor);
                  },
                  title: const Text(
                    'Favoritas',
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverPadding _buildPagina(BuildContext context) {
    final List<GetNotasModel> notas = Provider.of<NoteService>(context).notas;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      sliver: notas.length > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext buildContext, int index) => _Nota(
                        idNota: notas[index].idNota,
                        tituloNota: notas[index].tituloNota,
                        descripcionNota: notas[index].descripcionNota,
                        isFavorite:
                            (notas[index].isFavorite == 1) ? true : false,
                        fechaRecordatorio: notas[index].fechaDeRecordatorio,
                        fechaModificacion: notas[index].fechaDeModificacion,
                      ),
                  childCount: notas.length))
          : SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.announcement,
                    size: 60,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No hay Notas',
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
            ),
    );
  }

  Future<PopupMenuButton<UserSignIn>> _buildPopupMenuButton(
          BuildContext context) async =>
      PopupMenuButton<UserSignIn>(
        tooltip: _sharedPreferend.getUsuario().nombreCompleto,
        icon: DescribedFeatureOverlay(
          featureId: IdsTutorial.icon_perfil.toString(),
          tapTarget: _imagenPerfil,
          title: const Text('Perfil'),
          description: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Al tocar el botón podrás cerrar sesión,'
                ' además si mantienes tocando el botón unos'
                ' segundos, te dirá tu nombre, asociado a tu cuenta.',
                textAlign: TextAlign.justify,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              OutlineButton(
                onPressed: () => FeatureDiscovery.completeCurrentStep(context),
                child: Text('FINALIZAR TUTORIAL',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white)),
              )
            ],
          ),
          child: _imagenPerfil,
        ),
        onSelected: (UserSignIn result) async {
          if (result == UserSignIn.sign_out) {
            await _sharedPreferend.clear();
            await _googleSignIn.disconnect();
            await _auth.signOut();
            await Navigator.of(context).pushNamedAndRemoveUntil(
                RoutesNames.PRESENTACION, (Route<dynamic> route) => false);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<UserSignIn>>[
          const PopupMenuItem<UserSignIn>(
            value: UserSignIn.sign_out,
            child: Text('Cerrar Sesión'),
          ),
        ],
      );

  CachedNetworkImage get _imagenPerfil => CachedNetworkImage(
        imageUrl: _sharedPreferend.getUsuario().fotoPerfil,
        imageBuilder: (_, imagenProvider) => CircleAvatar(
          child: ClipRRect(
            child: Image(image: imagenProvider),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(
          backgroundColor: Colors.white54,
        ),
        errorWidget: (context, _, error) => Icon(Icons.error),
      );

  @override
  bool get wantKeepAlive => true;

  @override
  void afterFirstLayout(BuildContext context) async {
    final bool isNewUser = ModalRoute.of(context).settings.arguments;
    final notasDb = await DBNotas.db.getNotas();
    if (isNewUser != null && notasDb.isEmpty) {
      // Comprobareos que no sea el usuario nuevo
      if (!isNewUser) {
        Provider.of<NoteService>(context, listen: false).getNotasBackup();
      }
    }
  }
}

class _Nota extends StatelessWidget {
  final int idNota;
  final String tituloNota;
  final String descripcionNota;
  final bool isFavorite;
  final String fechaModificacion;
  final String fechaRecordatorio;

  const _Nota(
      {@required this.idNota,
      @required this.tituloNota,
      @required this.descripcionNota,
      @required this.isFavorite,
      @required this.fechaRecordatorio,
      @required this.fechaModificacion});

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          FadeIn(
            duration: Duration(milliseconds: 500),
            child: CardWidget(
              idNota: idNota,
              tituloNota: tituloNota,
              descripcionNota: descripcionNota,
              isFavorite: isFavorite,
              fechaDeRecordatorio: fechaRecordatorio,
              fechaModificacion: fechaModificacion,
            ),
          ),
        ],
      );
}
