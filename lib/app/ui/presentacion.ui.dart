import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, FirebaseAuth, FirebaseUser, GoogleAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;
import 'package:proyecto_empresas_notas/app/util/shared_preferend.util.dart';
import 'package:proyecto_empresas_notas/app/widgets/button_google.widget.dart';

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class UiPresentation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: <Widget>[
          _titulo(),
          Image(
            height: 150,
            image: AssetImage("assets/images/bloc-de-notas.png"),
          ),
          _botonGoogle(context),
        ],
      ),
    ));
  }

  Expanded _botonGoogle(BuildContext context) {
    return Expanded(
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: ButtonGoogleSignIn(onPressed: () => _signIn(context)),
            ),
          ),
        );
  }

  Widget _titulo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: Center(
        child: Text("FootNote",
            style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontFamily: "Roboto Black",
                color: Colors.black87)),
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    final SharedPreferences _sharedPreferend =
        SharedPreferend().sharedPreferences;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
      "email",
      "profile",
    ]);
    try {
      assert (true == false);
      await _googleSignIn.signOut();
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      _sharedPreferend.setUsuario(
          uidUsuario: user.uid,
          email: user.email,
          nombreCompleto: user.displayName,
          fotoPerfil: user.photoUrl);
      await Navigator.of(context).pushReplacementNamed("inicio");
    } catch (error) {
      await showDialog(context: context, child: _dialogoAlert(error, context));
    }
  }

  AlertDialog _dialogoAlert(error, BuildContext context) {
    return AlertDialog(
      title: Text("Error: ", style: TextStyle(
        color: Colors.black,
        fontSize: 25,
        fontWeight: FontWeight.w600
      ),),
      content: Text(error.toString(), style: TextStyle(color: Colors.black54, fontSize: 17),textAlign: TextAlign.justify,),
      actions: <Widget>[
        FlatButton(onPressed: ()=> Navigator.pop(context), child: Text("CERRAR", style: TextStyle(fontSize: 20),))
      ],
    );
  }
}
