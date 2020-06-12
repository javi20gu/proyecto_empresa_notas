import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import '../routes/routes.dart';
import '../util/shared_preferend.util.dart';
import '../widgets/button_google.widget.dart';

class UiPresentation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.05;
    final subtitle = Theme.of(context).textTheme.subtitle1.apply(
          color: Colors.black54,
        );
    return Scaffold(body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constrains) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constrains.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    _titulo(context),
                    Text(
                      'Guarde y administre sus notas personales\n'
                      'De forma simple, sencilla y cómoda\n'
                      'Para empezar solo tendrás que iniciar sesión\n'
                      'Para así sincronizar tus notas en la nube\n'
                      '¡Y nunca perderlas!',
                      style: subtitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: height,
                    ),
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.white12, BlendMode.luminosity),
                      child: Image(
                        height: _getSizeImage(context),
                        image: AssetImage('assets/images/bloc-de-notas.png'),
                      ),
                    ),
                    if (MediaQuery.of(context).orientation ==
                        Orientation.landscape)
                      const SizedBox(
                        height: 100,
                      ),
                    _botonGoogle(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ));
  }

  double _getSizeImage(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height <= 592.0) {
      return 225;
    }
    return 275;
  }

  Expanded _botonGoogle(BuildContext context) => Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: ButtonGoogleSignIn(onPressed: () => _signIn(context)),
          ),
        ),
      );

  Widget _titulo(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.08;
    return Padding(
      padding: EdgeInsets.only(top: height, bottom: height * 0.25),
      child: const Center(
        child: Text('FootNote',
            style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                fontFamily: 'Roboto Black',
                color: Color.fromRGBO(32, 33, 36, 1))),
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    final SharedPreferences _sharedPreferend =
        SharedPreferend().sharedPreferences;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
      'email',
      'profile',
    ]);
    final isInternet = await (Connectivity().checkConnectivity());
    if (isInternet == ConnectivityResult.none) {
      await showDialog(
          context: context,
          child: _dialogoAlert(
              'No dispones de Internet, verifique su internet', context,
              isNotInternet: true));
    } else {
      try {
        await _auth.signOut();
        await _googleSignIn.signOut();
        final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final AuthResult authResult =
            await _auth.signInWithCredential(credential);
        final bool isNewUser = authResult.additionalUserInfo.isNewUser;
        _sharedPreferend.setUsuario(
            uidUsuario: authResult.user.uid,
            isNewUser: isNewUser,
            email: authResult.user.email,
            nombreCompleto: authResult.user.displayName,
            fotoPerfil: authResult.user.photoUrl);
        await Navigator.of(context)
            .pushReplacementNamed(RoutesNames.INICIO, arguments: isNewUser);
      } on NoSuchMethodError catch (_) {} catch (error) {
        await showDialog(
            context: context,
            child: _dialogoAlert(error, context, isNotInternet: false));
      }
    }
  }

  AlertDialog _dialogoAlert(dynamic error, BuildContext context,
      {bool isNotInternet}) {
    final size = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: const Text(
        'Error: ',
        style: TextStyle(
            color: Colors.black, fontSize: 25, fontWeight: FontWeight.w600),
      ),
      content: Text(
        error.toString(),
        style: TextStyle(color: Colors.black54, fontSize: 17),
      ),
      actions: <Widget>[
        if (isNotInternet)
          RaisedButton(
              color: Colors.red,
              onPressed: () => AppSettings.openWIFISettings(),
              child: Text(
                'COMPROBAR INTERNET',
                style: TextStyle(
                    fontSize: (size <= 360.0) ? 14 : 15, color: Colors.white),
              )),
        FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'VOLVER',
              style: TextStyle(fontSize: (size <= 360.0) ? 16 : 18),
            ))
      ],
    );
  }
}
