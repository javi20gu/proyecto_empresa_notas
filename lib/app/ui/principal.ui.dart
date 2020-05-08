import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_empresas_notas/app/models/nota.model.dart';
import 'package:proyecto_empresas_notas/app/models/usuario.model.dart';
import 'package:proyecto_empresas_notas/app/services/notas.service.dart';
import 'package:proyecto_empresas_notas/app/util/shared_preferend.util.dart';
import 'package:proyecto_empresas_notas/app/widgets/card.widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiPrincipal extends StatefulWidget {
  @override
  _UiPrincipalState createState() => _UiPrincipalState();
}

class _UiPrincipalState extends State<UiPrincipal>
    with AutomaticKeepAliveClientMixin {
  final SharedPreferences _sharedPreferend =
      SharedPreferend().sharedPreferences;

  int paginaActual = 0;

  final UserSignInModel _sharedPreferendUsuario =
      SharedPreferend().sharedPreferences.getUsuario();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () =>
          Navigator.of(context).pushNamed("nota", arguments: [AccesoNota.Add]),
      child: Icon(Icons.add),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: paginaActual,
      onTap: (paginaNueva) {
        setState(() {
          paginaActual = paginaNueva;
        });
      },
      backgroundColor: Colors.white,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.note), title: Text("Notas")),
        BottomNavigationBarItem(
            icon: Icon(Icons.star), title: Text("Favoritos"))
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
   
    final bool isLoanding = Provider.of<NoteService>(context).isLoanding;
    return SafeArea(
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            centerTitle: true,
            title: Text("FootNote"),
            actions: <Widget>[_buildPopupMenuButton(context)],
          ),
          !isLoanding
              ? paginaActual == 0
                  ? buildPagina1(context)
                  : buildPagina2(context)
              : SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
        ],
      ),
    );
  }

  SliverPadding buildPagina1(BuildContext context) {
     final List<NotaModel> notas = Provider.of<NoteService>(context).notas;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      sliver: notas.length > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext buildContext, int index) => _Nota(
                        idNota: notas[index].idNota,
                        tituloNota: notas[index].tituloNota,
                        descripcionNota: notas[index].descripcionNota,
                        isFavorite: notas[index].favorito,
                      ),
                  childCount: notas.length),
            )
          : SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "No hay Notas",
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
            ),
    );
  }

  SliverPadding buildPagina2(BuildContext context) {
    final List<NotaModel> notasFavoritos = Provider.of<NoteService>(context).notasFavoritas;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      sliver: notasFavoritos.length > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext buildContext, int index) => _Nota(
                        idNota: notasFavoritos[index].idNota,
                        tituloNota: notasFavoritos[index].tituloNota,
                        descripcionNota: notasFavoritos[index].descripcionNota,
                        isFavorite: notasFavoritos[index].favorito,
                      ),
                  childCount: notasFavoritos.length),
            )
          : SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.star_border,
                    size: 60,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "No hay Notas Favoritas",
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ),
            ),
    );
  }

  PopupMenuButton<UserSignIn> _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton<UserSignIn>(
      tooltip: _sharedPreferendUsuario.nombreCompleto,
      icon: CachedNetworkImage(
        imageUrl: _sharedPreferendUsuario.fotoPerfil,
        imageBuilder: (_, imagenProvider) => ClipOval(
          child: Image(image: imagenProvider),
        ),
        placeholder: (context, url) => CircularProgressIndicator(
          backgroundColor: Colors.white54,
        ),
        errorWidget: (context, _, error) => Icon(Icons.error),
      ),
      onSelected: (UserSignIn result) async {
        if (result == UserSignIn.sign_out) {
          _sharedPreferend.clear();
          _auth.signOut();
          Navigator.of(context).pushNamedAndRemoveUntil(
              'presentacion', (Route<dynamic> route) => false);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<UserSignIn>>[
        PopupMenuItem<UserSignIn>(
          value: UserSignIn.sign_out,
          child: Text('Cerrar Sesión'),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Nota extends StatelessWidget {
  final UserSignInModel _sharedPreferendUsuario =
      SharedPreferend().sharedPreferences.getUsuario();

  final String idNota;
  final String tituloNota;
  final String descripcionNota;
  final bool isFavorite;

  _Nota(
      {@required this.idNota,
      @required this.tituloNota,
      @required this.descripcionNota,
      @required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        FadeIn(
          duration: Duration(milliseconds: 1250),
          child: CardWidget(
            idNota: idNota,
            nombreAutor: _sharedPreferendUsuario.nombreCompleto,
            tituloNota: tituloNota,
            descripcionNota: descripcionNota,
            isFavorite: isFavorite,
          ),
        ),
      ],
    );
  }
}
