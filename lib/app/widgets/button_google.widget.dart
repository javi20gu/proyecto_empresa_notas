import 'package:flutter/material.dart';

class ButtonGoogleSignIn extends StatelessWidget {
  final dynamic Function() onPressed;

  const ButtonGoogleSignIn({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: Color.fromRGBO(220, 222, 226, 1))),
      onPressed: onPressed,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        children: <Widget>[
          const Image(
            image: AssetImage("assets/logos/google.png"),
            height: (18 * 2.0),
          ),
          const SizedBox(width: 10),
          const Text(
            "Iniciar sesión con Google",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: "Roboto",
              color: Color.fromRGBO(95, 99, 104, 1),
            ),
          )
        ],
      ),
    );
  }
}
